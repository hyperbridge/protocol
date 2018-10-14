const MarketplaceStorage = artifacts.require("MarketplaceStorage");
const ProductRegistration = artifacts.require("ProductRegistration");
const ProductSystemRequirement = artifacts.require("ProductSystemRequirement");
const Developer = artifacts.require("Developer");

const blankAddress = 0x0000000000000000000000000000000000000000;
const productTitle = "BlockHub";
const productType = "BlockHub Type";
const productContent = "BlockHub Content";

const systemInfo1 = "System info 1";
const requirementInfo1 = "Requirement info 1";

contract('ProductSystemRequirement', function(accounts) {
    let marketplaceStorage;
    let productRegistrationContract;
    let productSystemRequirementContract;
    let developerContract;
    let developerAccount;
    let developerId;
    let productId;

    before(async () => {
        marketplaceStorage = await MarketplaceStorage.deployed();

        productRegistrationContract = await ProductRegistration.deployed();
        await marketplaceStorage.registerContract("ProductRegistration", blankAddress, productRegistrationContract.address);
        await productRegistrationContract.initialize();

        productSystemRequirementContract = await ProductSystemRequirement.deployed();
        await marketplaceStorage.registerContract("ProductSystemRequirement", blankAddress, productSystemRequirementContract.address);

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

    it("should deploy the product system requirement contract", async () => {
        try {
            assert.ok(productSystemRequirementContract.address);
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("developer should be able to add system requirement to a product", async () => {
        const systemInfo2 = "System info 2";
        const requirementInfo2 = "Requirement info 2";

        try {
            await productSystemRequirementContract.createSystemRequirement(productId, systemInfo1, requirementInfo1, { from: developerAccount });

            let systemRequirement = await productSystemRequirementContract.getSystemRequirement(productId, 0);

            assert.equal(systemRequirement[0], systemInfo1, "System info is incorrect.");
            assert.equal(systemRequirement[1], requirementInfo1, "Requirement info is incorrect.");

            await productSystemRequirementContract.createSystemRequirement(productId, systemInfo2, requirementInfo2, { from: developerAccount });

            systemRequirement = await productSystemRequirementContract.getSystemRequirement(productId, 1);

            assert.equal(systemRequirement[0], systemInfo2, "System info is incorrect.");
            assert.equal(systemRequirement[1], requirementInfo2, "Requirement info is incorrect.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("should be able to edit system requirement", async () => {
        const newSystemInfo = "New system info";
        const newRequirementInfo = "New requirement info";

        try {
            let systemRequirement = await productSystemRequirementContract.getSystemRequirement(productId, 0);

            assert.equal(systemRequirement[0], systemInfo1, "Initial system info is not as expected.");
            assert.equal(systemRequirement[1], requirementInfo1, "Initial requirement info is not as expected.");

            await productSystemRequirementContract.editSystemRequirement(productId, 0, newSystemInfo, newRequirementInfo, { from: developerAccount });

            systemRequirement = await productSystemRequirementContract.getSystemRequirement(productId, 0);

            assert.equal(systemRequirement[0], newSystemInfo, "System info is incorrect.");
            assert.equal(systemRequirement[1], newRequirementInfo, "Requirement info is incorrect.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });
});
