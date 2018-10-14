var Proxy = artifacts.require("HyperbridgeToken");
var EternalStorage = artifacts.require("EternalStorage");
var HbxToken = artifacts.require("HyperbridgeTokenDelegate");
var TokenLib = artifacts.require("TokenLib");

const BigNumber = web3.BigNumber;

const should = require('chai')
.use(require('chai-as-promised'))
.use(require('chai-bignumber')(BigNumber))
.should();

contract('Token', function([owner1, owner2, owner3, randomAccount, randomAccount2]) {
    let proxy;
    let hbxToken;
    let eternalStorage;
    let tokenLib;

    before(async () => {
        proxy = await Proxy.new({from: owner1});
        eternalStorage = await EternalStorage.new({from: owner2});

        tokenLib = await TokenLib.new();

        HbxToken.link("TokenLib", tokenLib.address);

        hbxToken = await HbxToken.new(
            "Hyperbridge Token",
            "HBX",
            18,
            eternalStorage.address,
            "1.0"
            ,{from: owner3});

        hbxTokenV2 = await HbxToken.new(
            "Hyperbridge Token V2",
            "HBX",
            18,
            eternalStorage.address,
            "2.0"
            ,{from: owner3});
    });

    it("should deploy contracts", async () => {
        proxy.should.not.be.undefined;
        eternalStorage.should.not.be.undefined;
        hbxToken.should.not.be.undefined;
    });

    it("should allow eternalStorage superadmin to add HbxToken as admin", async () => {
        await eternalStorage.addAdmin(hbxToken.address, {from: owner2}).should.be.fulfilled;
    });

    it("should reject eternalStorage none superadmin to add admins", async () => {
        await eternalStorage.addAdmin(hbxToken.address, {from: randomAccount}).should.be.rejected;
    });


    it("should upgrade to new implementation by owner", async () => {
        await proxy.upgradeTo(hbxToken.address, {from: owner1}).should.be.fulfilled;
        proxy = _.extend(HbxToken.at(hbxToken.address), proxy);
    });

    it("should rejects upgrading to new implementation by none owner", async () => {
        await proxy.upgradeTo(hbxToken.address, {from: owner1}).should.be.rejected;
    });

    it("should allow owner to set totalSupply", async () => {
        await proxy.setTotalSupply(1000, {from: owner3}).should.be.fulfilled;
        totalSupply = await hbxToken.totalSupply();
        totalSupply.should.be.bignumber.equal(1000);
    });

    it("should reject non owner from setting totalSupply", async () => {
        await proxy.setTotalSupply(1000, {from: randomAccount}).should.be.rejected;
    });

    it("should allow owner to mint tokens", async () => {
        await proxy.mint(owner3, 1000, {from: owner3}).should.be.fulfilled;
        balance = await hbxToken.balanceOf(owner3);
        balance.should.be.bignumber.equal(1000);
    });

    it("should reject none owner from minting tokens", async () => {
        await proxy.mint(owner3, 1000, {from: randomAccount}).should.be.rejected;
    });

    it("should allow transfers", async () => {
        senderBalance = await proxy.balanceOf(owner3);
        receiverBalance = await proxy.balanceOf(randomAccount);

        await proxy.transfer(randomAccount, 100, {from: owner3}).should.be.fulfilled;
        newSenderBalance = await proxy.balanceOf(owner3);
        newReceiverBalance = await proxy.balanceOf(randomAccount);

        newSenderBalance.should.be.bignumber.equal(senderBalance - 100);
        newReceiverBalance.should.be.bignumber.equal(receiverBalance + 100);
    });

    it("should allow to approve funds, check allowance and use transferFrom", async () => {
        senderBalance = await proxy.balanceOf(owner3);
        receiverBalance = await proxy.balanceOf(randomAccount2);

        await proxy.approve(randomAccount, 100, {from: owner3}).should.be.fulfilled;
        allowance = await proxy.allowance(owner3, randomAccount);
        allowance.should.be.bignumber.equal(100);

        await proxy.transferFrom(owner3, randomAccount2, 100, {from: randomAccount}).should.be.fulfilled;

        newSenderBalance = await proxy.balanceOf(owner3);
        newReceiverBalance = await proxy.balanceOf(randomAccount2);

        newReceiverBalance.should.be.bignumber.equal(receiverBalance + 100);
        newSenderBalance.should.be.bignumber.equal(senderBalance - 100);

        newAllowance = await proxy.allowance(owner3, randomAccount);
        newAllowance.should.be.bignumber.equal(allowance - 100);
    });

    it("should allow to increase and decrease approval", async () => {
        old_allowance = await proxy.allowance(owner3, randomAccount);

        await proxy.increaseApproval(randomAccount, 100, {from: owner3}).should.be.fulfilled;

        increasedAllowance = await proxy.allowance(owner3, randomAccount);
        increasedAllowance.should.be.bignumber.equal(old_allowance + 100);

        await proxy.decreaseApproval(randomAccount, 100, {from: owner3}).should.be.fulfilled;

        decreasedAllowance = await proxy.allowance(owner3, randomAccount);
        decreasedAllowance.should.be.bignumber.equal(increasedAllowance - 100);
    });

    it("should migrates funds after upgradeTo a new implementation", async () => {
        oldImplementation = await proxy.implementation();
        oldContractBalance = await proxy.balanceOf(oldImplementation);

        await proxy.upgradeTo(hbxTokenV2.address, {from: owner1}).should.be.fulfilled;
        proxy = _.extend(HbxToken.at(hbxTokenV2.address), proxy);

        newImplementation = await proxy.implementation();
        newImplementation.should.be.equal(hbxTokenV2.address);

        newContractBalance = await proxy.balanceOf(newImplementation);
        newContractBalance.should.be.bignumber.equal(oldContractBalance);
    });
});
