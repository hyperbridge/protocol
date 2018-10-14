const FundingStorage = artifacts.require("FundingStorage");
const Developer = artifacts.require("Developer");

contract('Developer', function(accounts) {
    const blankAddress = 0x0000000000000000000000000000000000000000;

    let developerContract;
    let fundingStorage;

    before(async () => {
        developerContract = await Developer.deployed();
        fundingStorage = await FundingStorage.deployed();
        await fundingStorage.registerContract("Developer", blankAddress, developerContract.address);
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
        let developerId;

        try {
            let watcher = developerContract.DeveloperCreated().watch(function (error, result) {
                if (!error) {
                    developerId = result.args.developerId.toNumber();
                }
            });

            await developerContract.createDeveloper(developerName, { from: accounts[0] });

            watcher.stopWatching();

            const createdDeveloper = await developerContract.getDeveloper(developerId);

            assert.notEqual(createdDeveloper[0].toNumber(), 0, "Developer ID 0 is reserved.");
            assert.equal(createdDeveloper[0].toNumber(), developerId, "Developer ID is incorrect.");
            assert.equal(createdDeveloper[1], accounts[0], "Developer address is incorrect.");
            assert.equal(createdDeveloper[2], developerName, "Developer name is incorrect.");
            assert.equal(createdDeveloper[3].length, 0, "Developer should not own any projects upon initialization.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("should not be able to create a second developer from the same address.", async () => {
        const newDeveloperName = "Hyperbridge2";

        try {
            await developerContract.createDeveloper(newDeveloperName, { from: accounts[0] });
            assert.fail();
        } catch (e) {
            console.log(e.message);
        }
    });
});
