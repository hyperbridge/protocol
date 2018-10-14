const MarketplaceStorage = artifacts.require("MarketplaceStorage");
const ProductRegistration = artifacts.require("ProductRegistration");
const ProductLanguageSupport = artifacts.require("ProductLanguageSupport");
const Developer = artifacts.require("Developer");

const blankAddress = 0x0000000000000000000000000000000000000000;
const productTitle = "BlockHub";
const productType = "BlockHub Type";
const productContent = "BlockHub Content";

const language1 = "English";
const closedCaptioning1 = true;
const audioDescription1 = true;

contract('ProductLanguageSupport', function(accounts) {
    let marketplaceStorage;
    let productRegistrationContract;
    let productLanguageSupportContract;
    let developerContract;
    let developerAccount;
    let developerId;
    let productId;

    before(async () => {
        marketplaceStorage = await MarketplaceStorage.deployed();

        productRegistrationContract = await ProductRegistration.deployed();
        await marketplaceStorage.registerContract("ProductRegistration", blankAddress, productRegistrationContract.address);
        await productRegistrationContract.initialize();

        productLanguageSupportContract = await ProductLanguageSupport.deployed();
        await marketplaceStorage.registerContract("ProductLanguageSupport", blankAddress, productLanguageSupportContract.address);

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

    it("should deploy the product language support contract", async () => {
        try {
            assert.ok(productLanguageSupportContract.address);
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("developer should be able to add language support to a product", async () => {
        const language2 = "French";
        const closedCaptioning2 = false;
        const audioDescription2 = false;

        try {
            await productLanguageSupportContract.createLanguageSupport(productId, language1, closedCaptioning1, audioDescription1, { from: developerAccount });

            let languageSupport = await productLanguageSupportContract.getLanguageSupport(productId, 0);

            assert.equal(languageSupport[0], language1, "Language is incorrect.");
            assert.equal(languageSupport[1], closedCaptioning1, "Closed captioning is incorrect.");
            assert.equal(languageSupport[2], audioDescription1, "Audio description is incorrect.");

            await productLanguageSupportContract.createLanguageSupport(productId, language2, closedCaptioning2, audioDescription2, { from: developerAccount });

            languageSupport = await productLanguageSupportContract.getLanguageSupport(productId, 1);

            assert.equal(languageSupport[0], language2, "Language is incorrect.");
            assert.equal(languageSupport[1], closedCaptioning2, "Closed captioning is incorrect.");
            assert.equal(languageSupport[2], audioDescription2, "Audio description is incorrect.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("should be able to edit language support", async () => {
        const newLanguage = "German";
        const newClosedCaptioning = false;
        const newAudioDescription = false;

        try {
            let languageSupport = await productLanguageSupportContract.getLanguageSupport(productId, 0);

            assert.equal(languageSupport[0], language1, "Initial language is not as expected.");
            assert.equal(languageSupport[1], closedCaptioning1, "Initial closed captioning is not as expected.");
            assert.equal(languageSupport[2], audioDescription1, "Initial audio description is not as expected.");

            await productLanguageSupportContract.editLanguageSupport(productId, 0, newLanguage, newClosedCaptioning, newAudioDescription, { from: developerAccount });

            languageSupport = await productLanguageSupportContract.getLanguageSupport(productId, 0);

            assert.equal(languageSupport[0], newLanguage, "Language is incorrect.");
            assert.equal(languageSupport[1], newClosedCaptioning, "Closed captioning is incorrect.");
            assert.equal(languageSupport[2], newAudioDescription, "Audio description is incorrect.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });
});
