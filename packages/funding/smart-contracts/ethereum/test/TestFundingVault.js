const FundingVault = artifacts.require("FundingVault");
const FundingStorage = artifacts.require("FundingStorage");

const BigNumber = web3.BigNumber;

const should = require('chai')
    .use(require('chai-as-promised'))
    .use(require('chai-bignumber')(BigNumber))
    .should();


contract('FundingVault', function(accounts) {
    const blankAddress = 0x0000000000000000000000000000000000000000;

    let fundingVault;
    let fundingStorage;
    let value;
    let owner;
    let testAccount;
    let unregistedAccount;

    before(async () => {
        fundingStorage = await FundingStorage.deployed();
        await fundingStorage.registerContract("TestAccount", blankAddress, accounts[1]);
        testAccount = accounts[1];
        unregistedAccount = accounts[2];
        owner = accounts[0];

        fundingVault = await FundingVault.deployed();
        value = 1000;
    });

    it("should deploy a FundingVault contract", async () => {
        fundingVault.should.not.be.undefined;
    });

    it("should allow approved address to deposit ETH", async () => {

        await fundingVault.depositEth({value: value, from: testAccount}).should.be.fulfilled;

        const balance = await fundingVault.getBalance();
        balance.should.be.bignumber.equal(value);
    });

    it("should rejects non fundingService address from depositing ETH", async () => {

        await fundingVault.depositEth({value: value, from: unregistedAccount}).should.be.rejectedWith('revert'); //TODO add test constants such as REVERT
    });

    it("should allow fundingService contract to withdraw ETH", async () => {
        const oldBalance = await fundingVault.getBalance.call();
        await fundingVault.withdrawEth(value, testAccount, {from: testAccount}).should.be.fulfilled;

        const newBalance = await fundingVault.getBalance.call();
        newBalance.should.be.bignumber.equal(oldBalance-value);
    });

    it("should reject non fundingService address from withdrawing ETH", async () => {
        await fundingVault.withdrawEth(value, unregistedAccount, {from: unregistedAccount}).should.be.rejected;
    });

    it("should rejects the traditional(fallback) depositing of ETH", async () => {
        await fundingVault.send({value: value, from: unregistedAccount}).should.be.rejected;
    });
});
