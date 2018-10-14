const MarketplaceStorage = artifacts.require("MarketplaceStorage");
const Administration = artifacts.require("Administration");

const blankAddress = 0x0000000000000000000000000000000000000000;

contract('Administration', function(accounts) {
    let marketplaceStorage;
    let administrationContract;
    let initialAdmin = accounts[0];

    before(async () => {
        marketplaceStorage = await MarketplaceStorage.deployed();

        administrationContract = await Administration.deployed();
        await marketplaceStorage.registerContract("Administration", blankAddress, administrationContract.address);
    });

    it("should deploy the administration contract", async () => {
        try {
            assert.ok(administrationContract.address);
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("should be able to initialize a first admin", async () => {
        try {
            assert.equal(await administrationContract.isAdministrator.call(initialAdmin), false, "Address should not be an admin.");

            await administrationContract.initialize({ from: initialAdmin });

            assert.equal(await administrationContract.isAdministrator.call(initialAdmin), true, "Address should be an admin.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("admin should be able to add a new admin", async () => {
        try {
            let newAdmin = accounts[1];

            assert.equal(await administrationContract.isAdministrator.call(newAdmin), false, "Address should not be an admin.");

            await administrationContract.registerAdministrator(newAdmin, { from: initialAdmin });

            assert.equal(await administrationContract.isAdministrator.call(newAdmin), true, "Address should be an admin.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("non-admin should not be able to add a new admin", async () => {
        try {
            let newAdmin = accounts[2];

            assert.equal(await administrationContract.isAdministrator.call(newAdmin), false, "Address should not be an admin.");

            await administrationContract.registerAdministrator(newAdmin, { from: accounts[3] });

            assert.fail();
        } catch (e) {
            console.log(e.message);
        }
    });

    it("admin should be able to renounce administration privilege", async () => {
        try {
            assert.equal(await administrationContract.isAdministrator.call(accounts[1]), true, "Address should be an admin.");

            await administrationContract.renounceAdministration({ from: accounts[1] });

            assert.equal(await administrationContract.isAdministrator.call(accounts[1]), false, "Address should not be an admin.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("admin should be able to transfer administration privilege", async () => {
        try {
            assert.equal(await administrationContract.isAdministrator.call(initialAdmin), true, "Address should be an admin.");
            assert.equal(await administrationContract.isAdministrator.call(accounts[1]), false, "Recipient address should not be an admin.");

            await administrationContract.transferAdministration(accounts[1], { from: initialAdmin });

            assert.equal(await administrationContract.isAdministrator.call(initialAdmin), false, "Address should be not an admin.");
            assert.equal(await administrationContract.isAdministrator.call(accounts[1]), true, "Recipient address should be an admin.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("non-admin should not be able to transfer administration privilege", async () => {
        try {
            assert.equal(await administrationContract.isAdministrator.call(initialAdmin), false, "Address should not be an admin.");

            await administrationContract.transferAdministration(accounts[2], { from: initialAdmin });

            assert.fail();
        } catch (e) {
            console.log(e.message);
        }
    });
});
