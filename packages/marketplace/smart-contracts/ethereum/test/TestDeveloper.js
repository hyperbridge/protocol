const MarketplaceStorage = artifacts.require("MarketplaceStorage");
const Developer = artifacts.require("Developer");

contract('Developer', function(accounts) {
    const blankAddress = 0x0000000000000000000000000000000000000000;

    let developerContract;
    let marketplaceStorage;

    before(async () => {
        developerContract = await Developer.deployed();
        marketplaceStorage = await MarketplaceStorage.deployed();
        await marketplaceStorage.registerContract("Developer", blankAddress, developerContract.address);
        await developerContract.initialize();
    });

    it("should deploy the developer contract", async () => {
        try {
            assert.ok(developerContract.address);
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("should be able to create a developer", async () => {
        const developerName = "Hyperbridge";
        const developerAddress = accounts[0];
        const expectedDeveloperId = 1;
        let developerId;

        try {
            let watcher = developerContract.DeveloperCreated().watch(function (error, result) {
                if (!error) {
                    developerId = result.args.developerId.toNumber();
                }
            });

            await developerContract.createDeveloper(developerName, { from: developerAddress });

            watcher.stopWatching();

            const createdDeveloper = await developerContract.getDeveloper(developerId);

            assert.notEqual(createdDeveloper[0].toNumber(), 0, "Developer ID 0 is reserved.");
            assert.equal(createdDeveloper[0].toNumber(), expectedDeveloperId, "Developer ID should be 1.");
            assert.equal(createdDeveloper[0].toNumber(), developerId, "Developer ID is incorrect.");
            assert.equal(createdDeveloper[1], developerAddress, "Developer address is incorrect.");
            assert.equal(createdDeveloper[2], developerName, "Developer name is incorrect.");
            assert.equal(createdDeveloper[3].length, 0, "Developer should not own any projects upon initialization.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("should not be able to create a second developer from the same address.", async () => {
        const newDeveloperName = "Hyperbridge";

        try {
            await developerContract.createDeveloper(newDeveloperName, { from: accounts[0] });
            assert.fail();
        } catch (e) {
            console.log(e.message);
        }
    });

    it("should be able to create a second developer", async () => {
        const developerName = "Hyperbridge";
        const developerAddress = accounts[1];
        const expectedDeveloperId = 2;
        let developerId;

        try {
            let watcher = developerContract.DeveloperCreated().watch(function (error, result) {
                if (!error) {
                    developerId = result.args.developerId.toNumber();
                }
            });

            await developerContract.createDeveloper(developerName, { from: developerAddress });

            watcher.stopWatching();

            const createdDeveloper = await developerContract.getDeveloper(developerId);

            assert.equal(createdDeveloper[0].toNumber(), developerId, "Developer ID is incorrect.");
            assert.equal(createdDeveloper[0].toNumber(), expectedDeveloperId, "Developer ID is incorrect.");
            assert.equal(createdDeveloper[1], developerAddress, "Developer address is incorrect.");
            assert.equal(createdDeveloper[2], developerName, "Developer name is incorrect.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("should be able to create a third developer", async () => {
        const developerName = "Hyperbridge";
        const developerAddress = accounts[2];
        const expectedDeveloperId = 3;
        let developerId;

        try {
            let watcher = developerContract.DeveloperCreated().watch(function (error, result) {
                if (!error) {
                    developerId = result.args.developerId.toNumber();
                }
            });

            await developerContract.createDeveloper(developerName, { from: developerAddress });

            watcher.stopWatching();

            const createdDeveloper = await developerContract.getDeveloper(developerId);

            assert.equal(createdDeveloper[0].toNumber(), developerId, "Developer ID is incorrect.");
            assert.equal(createdDeveloper[0].toNumber(), expectedDeveloperId, "Developer ID is incorrect.");
            assert.equal(createdDeveloper[1], developerAddress, "Developer address is incorrect.");
            assert.equal(createdDeveloper[2], developerName, "Developer name is incorrect.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("should be able to create a forth developer", async () => {
        const developerName = "Hyperbridge";
        const developerAddress = accounts[3];
        const expectedDeveloperId = 4;
        let developerId;

        try {
            let watcher = developerContract.DeveloperCreated().watch(function (error, result) {
                if (!error) {
                    developerId = result.args.developerId.toNumber();
                }
            });

            await developerContract.createDeveloper(developerName, { from: developerAddress });

            watcher.stopWatching();

            const createdDeveloper = await developerContract.getDeveloper(developerId);

            assert.equal(createdDeveloper[0].toNumber(), developerId, "Developer ID is incorrect.");
            assert.equal(createdDeveloper[0].toNumber(), expectedDeveloperId, "Developer ID is incorrect.");
            assert.equal(createdDeveloper[1], developerAddress, "Developer address is incorrect.");
            assert.equal(createdDeveloper[2], developerName, "Developer name is incorrect.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });
});
