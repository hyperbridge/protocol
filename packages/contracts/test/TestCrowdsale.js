import ether from './helpers/ether';
import assertRevert from './helpers/assertRevert';
import EVMRevert from './helpers/EVMRevert';
import { advanceBlock } from './helpers/advanceToBlock';
import { increaseTimeTo, duration } from './helpers/increaseTime';
import latestTime from './helpers/latestTime';

const BigNumber = web3.BigNumber;

const should = require('chai')
.use(require('chai-as-promised'))
.use(require('chai-bignumber')(BigNumber))
.should();

var Crowdsale = artifacts.require('HyperbridgeCrowdsale');
var HyperbridgeToken = artifacts.require('HyperbridgeToken'); // still having problems making it a package
var EternalStorage = artifacts.require("EternalStorage");
var HyperbridgeTokenDelegate = artifacts.require("HyperbridgeTokenDelegate");
var TokenLib = artifacts.require("TokenLib");

contract('Crowdsale', function ([owner1, owner2, owner3, investor, wallet, tokenWallet, purchaser, alice, bob, charlie]) {
    const rate = new BigNumber(1);
    const value = ether(42);

    const cap = ether(100);
    const lessThanCap = ether(60);

    const capAlice = ether(10);
    const capBob = ether(2);
    const lessThanCapAlice = ether(6);
    const lessThanCapBoth = ether(1);

    const tokenSupply = new BigNumber('1e22');
    const tokenAllowance = new BigNumber('1e22');
    const ZERO_ADDRESS = '0x0000000000000000000000000000000000000000';

    before(async function () {
        // Advance to the next block to correctly read time in the solidity "now" function interpreted by ganache
        await advanceBlock();
    });

    beforeEach(async function () {
        this.token = await HyperbridgeToken.new({from: owner1});
        this.eternalStorage = await EternalStorage.new({from: owner2});
        this.tokenLib = await TokenLib.new();
        HyperbridgeTokenDelegate.link("TokenLib", this.tokenLib.address);

        var hbxToken = await HyperbridgeTokenDelegate.new(
            "Hyperbridge Token",
            "HBX",
            18,
            this.eternalStorage.address,
            "1.0"
            ,{from: owner3});
        await this.eternalStorage.addAdmin(hbxToken.address, {from: owner2});
        await this.token.upgradeTo(hbxToken.address, {from: owner1});
        this.token = _.extend(HyperbridgeTokenDelegate.at(hbxToken.address), this.token);
        // await this.token.setTotalSupply(tokenSupply, {from: owner3});
        await this.token.mint(tokenWallet, tokenSupply, {from: owner3});



        this.openingTime = latestTime() + duration.weeks(1);
        this.closingTime = this.openingTime + duration.weeks(1);
        this.beforeEndTime = this.closingTime - duration.hours(1);
        this.afterClosingTime = this.closingTime + duration.hours(1);

        // uint256 _rate, address _wallet, ERC20 _token, address _tokenWallet, uint256 _cap, uint256 _startTime, uint256 _endTime
        this.crowdsale = await Crowdsale.new(rate, wallet, hbxToken.address, tokenWallet, cap, this.openingTime, this.closingTime);

        await this.token.approve(this.crowdsale.address, tokenAllowance, { from: tokenWallet });
    });

    describe('individual capping', function () {
        beforeEach(async function () {
            await this.crowdsale.setUserCap(alice, capAlice);
            await this.crowdsale.setUserCap(bob, capBob);
        });


        it('should be ended only after end', async function () {
            let ended = await this.crowdsale.hasClosed();
            ended.should.equal(false);
            await increaseTimeTo(this.afterClosingTime);
            ended = await this.crowdsale.hasClosed();
            ended.should.equal(true);
        });

        describe('accepting payments', function () {
            it('should reject payments before start', async function () {
                await this.crowdsale.send(value).should.be.rejectedWith(EVMRevert);
                await this.crowdsale.buyTokens(investor, { from: purchaser, value: value }).should.be.rejectedWith(EVMRevert);
            });

            it('should accept payments within cap after start', async function () {
                await increaseTimeTo(this.openingTime);
                // await this.crowdsale.send(value).should.be.fulfilled;
                await this.crowdsale.buyTokens(alice, { value: capAlice}).should.be.fulfilled;
            });

            it('should reject within or out of cap payments after end', async function () {
                await increaseTimeTo(this.afterClosingTime);
                await this.crowdsale.send(value).should.be.rejectedWith(EVMRevert);
                await this.crowdsale.buyTokens(alice, { value: capAlice}).should.be.rejectedWith(EVMRevert);
            });
        });

        describe('accepting payments', function () {

            it('should reject payments outside cap', async function () {
                await increaseTimeTo(this.openingTime);
                await this.crowdsale.buyTokens(alice, { value: capAlice });
                await this.crowdsale.buyTokens(alice, { value: 1 }).should.be.rejectedWith(EVMRevert);
            });

            it('should reject payments that exceed cap', async function () {
                await increaseTimeTo(this.openingTime);
                await this.crowdsale.buyTokens(alice, { value: capAlice.plus(1) }).should.be.rejectedWith(EVMRevert);
                await this.crowdsale.buyTokens(bob, { value: capBob.plus(1) }).should.be.rejectedWith(EVMRevert);
            });

            it('should manage independent caps', async function () {
                await increaseTimeTo(this.openingTime);
                await this.crowdsale.buyTokens(alice, { value: lessThanCapAlice }).should.be.fulfilled;
                await this.crowdsale.buyTokens(bob, { value: lessThanCapAlice }).should.be.rejectedWith(EVMRevert);
            });

            it('should default to a cap of zero', async function () {
                await increaseTimeTo(this.openingTime);
                await this.crowdsale.buyTokens(charlie, { value: lessThanCapBoth }).should.be.rejectedWith(EVMRevert);
            });
        });

        describe('reporting state', function () {
            it('should report correct cap', async function () {
                let retrievedCap = await this.crowdsale.getUserCap(alice);
                retrievedCap.should.be.bignumber.equal(capAlice);
            });

            it('should report actual contribution', async function () {
                await increaseTimeTo(this.openingTime);
                await this.crowdsale.buyTokens(alice, { value: lessThanCapAlice });
                let retrievedContribution = await this.crowdsale.getUserContribution(alice);
                retrievedContribution.should.be.bignumber.equal(lessThanCapAlice);
            });
        });
    });

    describe('group capping', function () {
        beforeEach(async function () {
            await this.crowdsale.setGroupCap([bob, charlie], capBob);
        });

        describe('accepting payments', function () {
            it('should accept payments within cap', async function () {
                await increaseTimeTo(this.openingTime);
                await this.crowdsale.buyTokens(bob, { value: lessThanCapBoth }).should.be.fulfilled;
                await this.crowdsale.buyTokens(charlie, { value: lessThanCapBoth }).should.be.fulfilled;
            });

            it('should reject payments outside cap', async function () {
                await increaseTimeTo(this.openingTime);
                await this.crowdsale.buyTokens(bob, { value: capBob });
                await this.crowdsale.buyTokens(bob, { value: 1 }).should.be.rejectedWith(EVMRevert);
                await this.crowdsale.buyTokens(charlie, { value: capBob });
                await this.crowdsale.buyTokens(charlie, { value: 1 }).should.be.rejectedWith(EVMRevert);
            });

            it('should reject payments that exceed cap', async function () {
                await increaseTimeTo(this.openingTime);
                await this.crowdsale.buyTokens(bob, { value: capBob.plus(1) }).should.be.rejectedWith(EVMRevert);
                await this.crowdsale.buyTokens(charlie, { value: capBob.plus(1) }).should.be.rejectedWith(EVMRevert);
            });
        });

        describe('reporting state', function () {
            it('should report correct cap', async function () {
                let retrievedCapBob = await this.crowdsale.getUserCap(bob);
                retrievedCapBob.should.be.bignumber.equal(capBob)
                let retrievedCapCharlie = await this.crowdsale.getUserCap(charlie);
                retrievedCapCharlie.should.be.bignumber.equal(capBob);
            });
        });
    });


    describe('post delivery', function() {
        beforeEach(async function () {
            await this.crowdsale.setUserCap(alice, capAlice);
            await this.crowdsale.setUserCap(bob, capBob);
            await increaseTimeTo(this.openingTime);
            await this.crowdsale.buyTokens(alice, { value: capAlice}).should.be.fulfilled;
        });

        it('should not immediately assign tokens to beneficiary', async function () {
            const balance = await this.token.balanceOf(alice);
            balance.should.be.bignumber.equal(0);
        });

        it('should not allow beneficiaries to withdraw tokens before crowdsale ends', async function () {
            await this.crowdsale.withdrawTokens({ from: alice }).should.be.rejectedWith(EVMRevert);
        });

        it('should allow beneficiaries to withdraw tokens after crowdsale ends', async function () {
            await increaseTimeTo(this.afterClosingTime);
            await this.crowdsale.withdrawTokens({ from: alice }).should.be.fulfilled;
        });

        it('should return the amount of tokens bought', async function () {
            await increaseTimeTo(this.afterClosingTime);
            await this.crowdsale.withdrawTokens({ from: alice });
            const balance = await this.token.balanceOf(alice);
            balance.should.be.bignumber.equal(capAlice);
        });
    });
});
