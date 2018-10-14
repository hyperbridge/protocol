const MarketplaceStorage = artifacts.require("MarketplaceStorage");
const ProductRegistration = artifacts.require("ProductRegistration");
const ProductVersion = artifacts.require("ProductVersion");
const Developer = artifacts.require("Developer");

const blankAddress = 0x0000000000000000000000000000000000000000;
const productTitle = "BlockHub";
const productType = "BlockHub Type";
const productContent = "BlockHub Content";

const productVersionVersion1 = "Product version 1";
const productVersionDownloadRefType1 = "Download ref type 1";
const productVersionDownloadRefSource1 = "Download ref source 1";
const productVersionChecksum1 = "Checksum 1";

contract('ProductVersion', function(accounts) {
    let marketplaceStorage;
    let productRegistrationContract;
    let productVersionContract;
    let developerContract;
    let developerAccount;
    let developerId;
    let productId;

    before(async () => {
        marketplaceStorage = await MarketplaceStorage.deployed();

        productRegistrationContract = await ProductRegistration.deployed();
        await marketplaceStorage.registerContract("ProductRegistration", blankAddress, productRegistrationContract.address);
        await productRegistrationContract.initialize();

        productVersionContract = await ProductVersion.deployed();
        await marketplaceStorage.registerContract("ProductVersion", blankAddress, productVersionContract.address);

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

    it("should deploy the product version contract", async () => {
        try {
            assert.ok(productVersionContract.address);
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("developer should be able to submit product version", async () => {
        const productVersionVersion2 = "Product version 2";
        const productVersionDownloadRefType2 = "Download ref type 2";
        const productVersionDownloadRefSource2 = "Download ref source 2";
        const productVersionChecksum2 = "Checksum 2";

        try {
            await productVersionContract.submitVersionForReview(productId, productVersionVersion1, productVersionDownloadRefType1, productVersionDownloadRefSource1, productVersionChecksum1, { from: developerAccount });

            let version = await productVersionContract.getVersion(productId, productVersionVersion1);

            assert.equal(version[0], productVersionVersion1, "Version is incorrect.");
            assert.equal(version[1], productVersionDownloadRefType1, "DL ref type is incorrect.");
            assert.equal(version[2], productVersionDownloadRefSource1, "DL ref source is incorrect.");
            assert.equal(version[3], productVersionChecksum1, "Checksum is incorrect.");

            await productVersionContract.submitVersionForReview(productId, productVersionVersion2, productVersionDownloadRefType2, productVersionDownloadRefSource2, productVersionChecksum2, { from: developerAccount });

            version = await productVersionContract.getVersion(productId, productVersionVersion2);

            assert.equal(version[0], productVersionVersion2, "Version is incorrect.");
            assert.equal(version[1], productVersionDownloadRefType2, "DL ref type is incorrect.");
            assert.equal(version[2], productVersionDownloadRefSource2, "DL ref source is incorrect.");
            assert.equal(version[3], productVersionChecksum2, "Checksum is incorrect.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("should be able to edit product version", async () => {
        try {
            await productVersionContract.submitVersionForReview(productId, productVersionVersion1, productVersionDownloadRefType1, productVersionDownloadRefSource1, productVersionChecksum1, { from: developerAccount });
            assert.fail();
        } catch (e) {
            console.log(e.message);
        }
    });
});
