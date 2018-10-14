const FundingStorage = artifacts.require("FundingStorage");


contract('FundingStorage', function(accounts) {
    const blankAddress = 0x0000000000000000000000000000000000000000;
    const contractName = "TestContract";

    let fundingStorage;

    before(async () => {
        fundingStorage = await FundingStorage.deployed();
    });

    it("should deploy the FundingStorage contract", async () => {
        try {
            assert.ok(fundingStorage.address);
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("should be able to register and unregister a new contract", async () => {
        try {
            // accounts[0] should not be a registered address
            let isValidContract = await fundingStorage.getContractIsValid(accounts[0]);
            assert.equal(isValidContract, false, "This address should not be valid.");

            let testContractAddress = await fundingStorage.getContractAddress(contractName);
            assert.equal(testContractAddress, blankAddress, "No address should be registered to TestContract");

            // Register address[0] as a valid address
            await fundingStorage.registerContract(contractName, blankAddress, accounts[0]);

            // accounts[0] should now be a registered address
            isValidContract = await fundingStorage.getContractIsValid(accounts[0]);
            assert.equal(isValidContract, true, "This address should be valid.");

            testContractAddress = await fundingStorage.getContractAddress(contractName);
            assert.equal(testContractAddress, accounts[0], "accounts[0] should be registered to TestContract");

            // Unregister address[0]
            await fundingStorage.unregisterContract("TestContract", accounts[0]);

            // accounts[0] should not be a registered address
            isValidContract = await fundingStorage.getContractIsValid(accounts[0]);
            assert.equal(isValidContract, false, "This address should not be valid.");

            testContractAddress = await fundingStorage.getContractAddress(contractName);
            assert.equal(testContractAddress, blankAddress, "No address should be registered to TestContract");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("should be able to replace an existing contract.", async () => {
        try {
            // Register address[0] as a valid address
            await fundingStorage.registerContract(contractName, blankAddress, accounts[0]);

            // accounts[0] should now be a registered address
            let isValidContract = await fundingStorage.getContractIsValid(accounts[0]);
            assert.equal(isValidContract, true, "This address should be valid.");

            let testContractAddress = await fundingStorage.getContractAddress(contractName);
            assert.equal(testContractAddress, accounts[0], "accounts[0] should be registered to TestContract");

            // Replace "TestContract" with accounts[1]
            await fundingStorage.registerContract(contractName, accounts[0], accounts[1]);

            // accounts[0] should not be a registered address
            isValidContract = await fundingStorage.getContractIsValid(accounts[0]);
            assert.equal(isValidContract, false, "This address should be valid.");

            // accounts[1] should be a registered address
            isValidContract = await fundingStorage.getContractIsValid(accounts[1]);
            assert.equal(isValidContract, true, "This address should be valid.");

            testContractAddress = await fundingStorage.getContractAddress(contractName);
            assert.equal(testContractAddress, accounts[1], "accounts[1] should be registered to TestContract");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("should not be able to register a new contract with same name as a different contract.", async () => {
        try {
            // Register accounts[0] as "TestContract"
            await fundingStorage.registerContract(contractName, blankAddress, accounts[0]);

            // Register accounts[1] as "TestContract"
            await fundingStorage.registerContract(contractName, blankAddress, accounts[1]);

            assert.fail();
        } catch (e) {
            console.log(e.message);
        }
    });
});
