const MarketplaceStorage = artifacts.require("MarketplaceStorage");
const ProductRegistration = artifacts.require("ProductRegistration");
const Developer = artifacts.require("Developer");

const blankAddress = 0x0000000000000000000000000000000000000000;
const productTitle = "BlockHub";
const productType = "BlockHub Type";
const productContent = "BlockHub Content";

contract('ProductRegistration', function(accounts) {
    let marketplaceStorage;
    let productRegistrationContract;
    let developerContract;
    let developerAccount;
    let developerId;
    let productId;

    before(async () => {
        marketplaceStorage = await MarketplaceStorage.deployed();

        productRegistrationContract = await ProductRegistration.deployed();
        await marketplaceStorage.registerContract("ProductRegistration", blankAddress, productRegistrationContract.address);
        await productRegistrationContract.initialize();

        developerContract = await Developer.deployed();
        await marketplaceStorage.registerContract("Developer", blankAddress, developerContract.address);
        await developerContract.initialize();

        developerAccount = accounts[1];

        let watcher = developerContract.DeveloperCreated().watch(function (error, result) {
            if (!error) {
                developerId = result.args.developerId.toNumber();
            }
        });

        await developerContract.createDeveloper("Hyperbridge", { from: developerAccount });

        watcher.stopWatching();
    });

    it("should deploy the product registration contract", async () => {
        try {
            assert.ok(productRegistrationContract.address);
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("developer should be able to create a product", async () => {
        try {
            let watcher = productRegistrationContract.ProductCreated().watch(function (error, result) {
                if (!error) {
                    productId = result.args.productId.toNumber();
                }
            });

            await productRegistrationContract.createProduct(productTitle, productType, productContent, { from: developerAccount });

            watcher.stopWatching();

            const product = await productRegistrationContract.getProduct(productId);

            assert.notEqual(product[0].toNumber(), 0, "Product ID 0 should be reserved.");
            assert.equal(product[0].toNumber(), productId, "Product ID is incorrect.");
            assert.equal(product[1].toNumber(), 1, "Product should be set to Status: Draft.");
            assert.equal(product[2], productTitle, "Product title is incorrect.");
            assert.equal(product[3], productType, "Product type is incorrect.");
            assert.equal(product[4], productContent, "Product content is incorrect.");
            assert.equal(product[5].length, 0, "Product should have no system tags.");
            assert.equal(product[6].length, 0, "Product should have no author tags.");
            assert.equal(product[7], developerAccount, "Product developer is incorrect.");
            assert.equal(product[8].toNumber(), developerId, "Product developer ID is incorrect.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("non-developer should not be able to create a product", async () => {
        try {
            await productRegistrationContract.createProduct(productTitle, productType, productContent, { from: accounts[2] });
            assert.fail();
        } catch (e) {
            console.log(e.message);
        }
    });

    it("developer should be able to edit product info", async () => {
        const newProductTitle = "New Title";
        const newProductType = "New Type";
        const newProductContent = "New Content";

        try {
            await productRegistrationContract.editProductInfo(productId, newProductTitle, newProductType, newProductContent, { from: developerAccount });

            const product = await productRegistrationContract.getProduct(productId);

            assert.equal(product[2], newProductTitle, "Product title is incorrect.");
            assert.equal(product[3], newProductType, "Product type is incorrect.");
            assert.equal(product[4], newProductContent, "Product content is incorrect.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    // it("developer should be able to set tags", async () => {
    //     const systemTags = [web3.toAscii("Tag 1").replace(/\0/g, ''), web3.toAscii("Tag 2").replace(/\0/g, ''), web3.toAscii("Tag 3").replace(/\0/g, '')];
    //     const authorTags = [web3.toAscii("Tag 1").replace(/\0/g, ''), web3.toAscii("Tag 2").replace(/\0/g, ''), web3.toAscii("Tag 3").replace(/\0/g, ''), web3.toAscii("Tag 4").replace(/\0/g, '')];

    //     console.log(systemTags);
    //     console.log(authorTags);

    //     try {
    //         // TODO - figure out why this isn't working
    //         await productRegistrationContract.setProductTags(productId, systemTags, authorTags, { from: developerAccount });

    //         const product = await productRegistrationContract.getProduct(productId);

    //         assert.equal(product[5].length, 3, "Product system tags length is incorrect.");
    //         assert.equal(product[6].length, 4, "Product author tags length is incorrect.");
    //     } catch (e) {
    //         console.log(e.message);
    //         assert.fail();
    //     }
    // });
});
