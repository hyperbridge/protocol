const MarketplaceStorage = artifacts.require("MarketplaceStorage");
const ProductRegistration = artifacts.require("ProductRegistration");
const ProductPricePlan = artifacts.require("ProductPricePlan");
const Developer = artifacts.require("Developer");

const blankAddress = 0x0000000000000000000000000000000000000000;
const productTitle = "BlockHub";
const productType = "BlockHub Type";
const productContent = "BlockHub Content";

const pricePlanCode1 = "Price plan code 1";
const pricePlanName1 = "Price plan name 1";
const pricePlanPrice1 = 55000000000000000;

contract('ProductPricePlan', function(accounts) {
    let marketplaceStorage;
    let productRegistrationContract;
    let productPricePlanContract;
    let developerContract;
    let developerAccount;
    let developerId;
    let productId;

    before(async () => {
        marketplaceStorage = await MarketplaceStorage.deployed();

        productRegistrationContract = await ProductRegistration.deployed();
        await marketplaceStorage.registerContract("ProductRegistration", blankAddress, productRegistrationContract.address);
        await productRegistrationContract.initialize();

        productPricePlanContract = await ProductPricePlan.deployed();
        await marketplaceStorage.registerContract("ProductPricePlan", blankAddress, productPricePlanContract.address);

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
    });

    it("should deploy the product price plan contract", async () => {
        try {
            assert.ok(productPricePlanContract.address);
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("developer should be able to add price plan to a product", async () => {
        const pricePlanCode2 = "Price plan code 2";
        const pricePlanName2 = "Price plan name 2";
        const pricePlanPrice2 = 65000000000000000;

        try {
            await productPricePlanContract.createPricePlan(productId, pricePlanCode1, pricePlanName1, pricePlanPrice1, { from: developerAccount });

            let pricePlan = await productPricePlanContract.getPricePlan(productId, pricePlanCode1);

            assert.equal(pricePlan[0], pricePlanCode1, "Code is incorrect.");
            assert.equal(pricePlan[1], pricePlanName1, "Name is incorrect.");
            assert.equal(pricePlan[2].toNumber(), pricePlanPrice1, "Price is incorrect.");

            await productPricePlanContract.createPricePlan(productId, pricePlanCode2, pricePlanName2, pricePlanPrice2, { from: developerAccount });

            pricePlan = await productPricePlanContract.getPricePlan(productId, pricePlanCode2);

            assert.equal(pricePlan[0], pricePlanCode2, "Code is incorrect.");
            assert.equal(pricePlan[1], pricePlanName2, "Name is incorrect.");
            assert.equal(pricePlan[2].toNumber(), pricePlanPrice2, "Price is incorrect.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("should be able to edit price plan", async () => {
        const newPricePlanName = "New price plan name";
        const newPricePlanPrice = 75000000000000000;

        try {
            let pricePlan = await productPricePlanContract.getPricePlan(productId, pricePlanCode1);

            assert.equal(pricePlan[0], pricePlanCode1, "Initial code is incorrect.");
            assert.equal(pricePlan[1], pricePlanName1, "Initial name is incorrect.");
            assert.equal(pricePlan[2].toNumber(), pricePlanPrice1, "Initial price is incorrect.");

            await productPricePlanContract.editPricePlan(productId, pricePlanCode1, newPricePlanName, newPricePlanPrice, { from: developerAccount });

            pricePlan = await productPricePlanContract.getPricePlan(productId, pricePlanCode1);

            assert.equal(pricePlan[0], pricePlanCode1, "Code is incorrect.");
            assert.equal(pricePlan[1], newPricePlanName, "Name is incorrect.");
            assert.equal(pricePlan[2].toNumber(), newPricePlanPrice, "Price is incorrect.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });
});
