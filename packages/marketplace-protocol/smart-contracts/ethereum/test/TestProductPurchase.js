const MarketplaceStorage = artifacts.require("MarketplaceStorage");
const ProductRegistration = artifacts.require("ProductRegistration");
const ProductVersion = artifacts.require("ProductVersion");
const ProductVersionVoting = artifacts.require("ProductVersionVoting");
const ProductPricePlan = artifacts.require("ProductPricePlan");
const ProductPurchase = artifacts.require("ProductPurchase");
const Developer = artifacts.require("Developer");
const Administration = artifacts.require("Administration");

contract('ProductPurchase', function(accounts) {
    const blankAddress = 0x0000000000000000000000000000000000000000;
    const productTitle = "BlockHub";
    const productType = "BlockHub Type";
    const productContent = "BlockHub Content";

    const productVersionVersion1 = "Product version 1";
    const productVersionDownloadRefType1 = "Download ref type 1";
    const productVersionDownloadRefSource1 = "Download ref source 1";
    const productVersionChecksum1 = "Checksum 1";

    const pricePlanCode1 = "Price plan code 1";
    const pricePlanName1 = "Price plan name 1";
    const pricePlanPrice1 = 55000000000000000;

    let marketplaceStorage;
    let productRegistrationContract;
    let productVersionContract;
    let productVersionVotingContract;
    let productPricePlanContract;
    let productPurchaseContract;
    let developerContract;
    let developerAccount;
    let developerId;
    let productId;
    let administrationContract;
    let admin1 = accounts[9];
    let admin2 = accounts[8];

    before(async () => {
        marketplaceStorage = await MarketplaceStorage.deployed();

        administrationContract = await Administration.deployed();
        await marketplaceStorage.registerContract("Administration", blankAddress, administrationContract.address);
        await administrationContract.initialize({ from: admin1 });
        await administrationContract.registerAdministrator(admin2, { from: admin1 });

        productRegistrationContract = await ProductRegistration.deployed();
        await marketplaceStorage.registerContract("ProductRegistration", blankAddress, productRegistrationContract.address);
        await productRegistrationContract.initialize();

        productVersionContract = await ProductVersion.deployed();
        await marketplaceStorage.registerContract("ProductVersion", blankAddress, productVersionContract.address);

        productPurchaseContract = await ProductPurchase.deployed();
        await marketplaceStorage.registerContract("ProductPurchase", blankAddress, productPurchaseContract.address);

        productPricePlanContract = await ProductPricePlan.deployed();
        await marketplaceStorage.registerContract("ProductPricePlan", blankAddress, productPricePlanContract.address);

        productVersionVotingContract = await ProductVersionVoting.deployed();
        await marketplaceStorage.registerContract("ProductVersionVoting", blankAddress, productVersionVotingContract.address);

        developerContract = await Developer.deployed();
        await marketplaceStorage.registerContract("Developer", blankAddress, developerContract.address);
        await developerContract.initialize();

        developerAccount = accounts[1];

        let devWatcher = developerContract.DeveloperCreated().watch(function (error, result) {
            if (!error) {
                developerId = result.args.developerId.toNumber();
            }
        });

        await developerContract.createDeveloper("Hyperbridge", { from: developerAccount });

        devWatcher.stopWatching();

        let projWatcher = productRegistrationContract.ProductCreated().watch(function (error, result) {
            if (!error) {
                productId = result.args.productId.toNumber();
            }
        });

        await productRegistrationContract.createProduct(productTitle, productType, productContent, { from: developerAccount });

        projWatcher.stopWatching();

        await productVersionContract.submitVersionForReview(productId, productVersionVersion1, productVersionDownloadRefType1, productVersionDownloadRefSource1, productVersionChecksum1, { from: developerAccount });

        await productVersionVotingContract.voteOnVersion(productId, productVersionVersion1, true, { from: admin1 });

        await productVersionVotingContract.finalizeVersionVoting(productId, productVersionVersion1, { from: developerAccount });

        await productPricePlanContract.createPricePlan(productId, pricePlanCode1, pricePlanName1, pricePlanPrice1, { from: developerAccount });
    });

    it("should deploy the product purchase contract", async () => {
        try {
            assert.ok(productPurchaseContract.address);
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("user should not be able to purchase product if value is different from price.", async () => {
        try {
            let purchaser = accounts[4];
            await productPurchaseContract.purchase(productId, pricePlanCode1, { from: purchaser, value: pricePlanPrice1 - 1 });
            assert.fail();
        } catch (e) {
            console.log(e.message);
        }
    });

    it("user should not be able to purchase product if price plan doesn't exist", async () => {
        try {
            let purchaser = accounts[4];
            await productPurchaseContract.purchase(productId, "Made up price plan code", { from: purchaser, value: pricePlanPrice1 });
            assert.fail();
        } catch (e) {
            console.log(e.message);
        }
    });

    it("user should be able to purchase product", async () => {
        try {
            let purchaser = accounts[4];
            await productPurchaseContract.purchase(productId, pricePlanCode1, { from: purchaser, value: pricePlanPrice1 });

            const initialDeveloperFunds = web3.eth.getBalance(developerAccount).toNumber();

            let order = await productPurchaseContract.getPurchaseOrder(productId, purchaser, 0);

            assert.equal(order[0].toNumber(), productId, "Product ID is incorrect.");
            assert.equal(order[1], pricePlanCode1, "Product ID is incorrect.");
            assert.equal(order[2], pricePlanPrice1, "Product ID is incorrect.");
            assert.equal(order[3], purchaser, "Product ID is incorrect.");
            assert.equal(order[4], developerAccount, "Product ID is incorrect.");

            const newDeveloperFunds = web3.eth.getBalance(developerAccount).toNumber();

            assert.closeTo(newDeveloperFunds, initialDeveloperFunds + pricePlanPrice1, 55000000000000000, "Developer balance incorrect after product purchase.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });
});
