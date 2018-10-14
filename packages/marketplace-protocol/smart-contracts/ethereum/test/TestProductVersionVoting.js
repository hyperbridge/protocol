const MarketplaceStorage = artifacts.require("MarketplaceStorage");
const ProductRegistration = artifacts.require("ProductRegistration");
const ProductVersion = artifacts.require("ProductVersion");
const ProductVersionVoting = artifacts.require("ProductVersionVoting");
const Developer = artifacts.require("Developer");
const Administration = artifacts.require("Administration");

contract('ProductVersionVoting', function(accounts) {
    const blankAddress = 0x0000000000000000000000000000000000000000;
    const productTitle = "BlockHub";
    const productType = "BlockHub Type";
    const productContent = "BlockHub Content";

    const productVersionVersion1 = "Product version 1";
    const productVersionDownloadRefType1 = "Download ref type 1";
    const productVersionDownloadRefSource1 = "Download ref source 1";
    const productVersionChecksum1 = "Checksum 1";

    let marketplaceStorage;
    let productRegistrationContract;
    let productVersionContract;
    let productVersionVotingContract;
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
    });

    it("should deploy the product version voting contract", async () => {
        try {
            assert.ok(productVersionVotingContract.address);
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("admin should be able to vote on product version", async () => {
        try {
            let versionVoting = await productVersionVotingContract.getVersionVoting(productId, productVersionVersion1);

            assert.equal(versionVoting[0].toNumber(), 0, "Initial approval count is incorrect.");
            assert.equal(versionVoting[1].toNumber(), 0, "Initial disapproval count is incorrect.");
            assert.equal(versionVoting[2], true, "Initial isActive is incorrect.");
            assert.equal(versionVoting[3], false, "Initial hasFailed is incorrect.");

            await productVersionVotingContract.voteOnVersion(productId, productVersionVersion1, true, { from: admin1 });

            versionVoting = await productVersionVotingContract.getVersionVoting(productId, productVersionVersion1);

            assert.equal(versionVoting[0].toNumber(), 1, "Approval count is incorrect.");
            assert.equal(versionVoting[1].toNumber(), 0, "Disapproval count is incorrect.");
            assert.equal(versionVoting[2], true, "isActive is incorrect.");
            assert.equal(versionVoting[3], false, "hasFailed is incorrect.");

            await productVersionVotingContract.voteOnVersion(productId, productVersionVersion1, false, { from: admin2 });

            versionVoting = await productVersionVotingContract.getVersionVoting(productId, productVersionVersion1);

            assert.equal(versionVoting[0].toNumber(), 1, "Approval count is incorrect.");
            assert.equal(versionVoting[1].toNumber(), 1, "Disapproval count is incorrect.");
            assert.equal(versionVoting[2], true, "isActive is incorrect.");
            assert.equal(versionVoting[3], false, "hasFailed is incorrect.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("non-admin should not be able to vote on product version", async () => {
        try {
            await productVersionVotingContract.voteOnVersion(productId, productVersionVersion1, true);
            assert.fail();
        } catch (e) {
            console.log(e.message);
        }
    });

    it("should not be able to vote on inactive version voting", async () => {
        try {
            await productVersionVotingContract.voteOnVersion(productId, "Inactive voting", true, { from: admin1 });
            assert.fail();
        } catch (e) {
            console.log(e.message);
        }
    });

    it("admin should be able to finalize version voting - success", async () => {
        try {
            let latestVersion = await productVersionContract.getLatestVersion(productId);

            assert.equal(latestVersion[0], "", "Version is incorrect.");
            assert.equal(latestVersion[1], "", "DL ref type is incorrect.");
            assert.equal(latestVersion[2], "", "DL ref source is incorrect.");
            assert.equal(latestVersion[3], "", "Checksum is incorrect.");

            await productVersionVotingContract.finalizeVersionVoting(productId, productVersionVersion1, { from: developerAccount });

            let versionVoting = await productVersionVotingContract.getVersionVoting(productId, productVersionVersion1);

            assert.equal(versionVoting[0].toNumber(), 1, "Approval count is incorrect.");
            assert.equal(versionVoting[1].toNumber(), 1, "Disapproval count is incorrect.");
            assert.equal(versionVoting[2], false, "isActive is incorrect.");
            assert.equal(versionVoting[3], false, "hasFailed is incorrect.");

            latestVersion = await productVersionContract.getLatestVersion(productId);

            assert.equal(latestVersion[0], productVersionVersion1, "Version is incorrect.");
            assert.equal(latestVersion[1], productVersionDownloadRefType1, "DL ref type is incorrect.");
            assert.equal(latestVersion[2], productVersionDownloadRefSource1, "DL ref source is incorrect.");
            assert.equal(latestVersion[3], productVersionChecksum1, "Checksum is incorrect.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("admin should be able to finalize version voting - failure", async () => {
        const productVersionVersion2 = "Product version 2";
        const productVersionDownloadRefType2 = "Download ref type 2";
        const productVersionDownloadRefSource2 = "Download ref source 2";
        const productVersionChecksum2 = "Checksum 2";

        try {
            let latestVersion = await productVersionContract.getLatestVersion(productId);

            assert.equal(latestVersion[0], productVersionVersion1, "Initial version is incorrect.");
            assert.equal(latestVersion[1], productVersionDownloadRefType1, "Initial DL ref type is incorrect.");
            assert.equal(latestVersion[2], productVersionDownloadRefSource1, "Initial DL ref source is incorrect.");
            assert.equal(latestVersion[3], productVersionChecksum1, "Initial checksum is incorrect.");

            await productVersionContract.submitVersionForReview(productId, productVersionVersion2, productVersionDownloadRefType2, productVersionDownloadRefSource2, productVersionChecksum2, { from: developerAccount });

            await productVersionVotingContract.voteOnVersion(productId, productVersionVersion2, false, { from: admin1 });

            await productVersionVotingContract.finalizeVersionVoting(productId, productVersionVersion2, { from: developerAccount });

            let versionVoting = await productVersionVotingContract.getVersionVoting(productId, productVersionVersion2);

            assert.equal(versionVoting[0].toNumber(), 0, "Approval count is incorrect.");
            assert.equal(versionVoting[1].toNumber(), 1, "Disapproval count is incorrect.");
            assert.equal(versionVoting[2], false, "isActive is incorrect.");
            assert.equal(versionVoting[3], true, "hasFailed is incorrect.");

            latestVersion = await productVersionContract.getLatestVersion(productId);

            assert.equal(latestVersion[0], productVersionVersion1, "Version is incorrect.");
            assert.equal(latestVersion[1], productVersionDownloadRefType1, "DL ref type is incorrect.");
            assert.equal(latestVersion[2], productVersionDownloadRefSource1, "DL ref source is incorrect.");
            assert.equal(latestVersion[3], productVersionChecksum1, "Checksum is incorrect.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });
});
