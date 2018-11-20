var NetworkAccessToken = artifacts.require("./NetworkAccessToken.sol");
var Republic = artifacts.require("./Republic.sol");
var RepublicPrimaryElection = artifacts.require("./RepublicPrimaryElection.sol");
var RepublicIndustryElection = artifacts.require("./RepublicIndustryElection.sol");
var User = artifacts.require("./User.sol");

const mineBlock = function () {
    return new Promise((resolve, reject) => {
        web3.currentProvider.sendAsync({
            jsonrpc: "2.0",
            method: "evm_mine"
        }, (err, result) => {
            if (err) { return reject(err) }
            return resolve(result)
        });
    })
}

contract('Republic', function (accounts) {
    const owner = accounts[0];

    async function setupElection(_republic) {
        await _republic.addDelegate(owner, { from: owner });
        await _republic.createElection({ from: owner });
        await mineBlock();

        var election = await _republic.getElection({ from: owner });
        
        election = await new RepublicPrimaryElection(election);

        var industries = [
            "Logistics & Supply Chain",
            "Education & Training",
            "Environmental & Transportation",
            "Agriculture & Food",
            "Medical & Healthcare",
            "AI & IoT",
            "Software & Web Technology",
            "Legal & Accounting",
            "Social & Media",
            "HR & Workforce",
            "Health & Wellness"
        ];

        await election.createIndustryElection(industries[0], { from: owner });
        await election.createIndustryElection(industries[1], { from: owner });

        return election;
    }

    async function setupHighTurnoutElectionVotes(_republic, _election) {
        var industryElections = await _election.getIndustryElections({ from: owner });

        var industryElection1 = await new RepublicIndustryElection(industryElections[0]);
        var industryElection2 = await new RepublicIndustryElection(industryElections[1]);

        var nominee1 = await _republic.createUser();//{ from: owner });
        var nominee2 = await _republic.createUser();//{ from: owner });
        nominee1 = await new User(nominee1);
        nominee2 = await new User(nominee2); 

        console.log(10, nominee1, nominee2, industryElection1);
        //await nominee1.registerAsNominee.call(industryElection1, { from: owner });
        // await nominee2.registerAsNominee.call(industryElection2, { from: owner });

        // var user1 = await new User();
        // var user2 = await new User();
        // var user3 = await new User();
        // var user4 = await new User();

        // await user1.vote(industryElection1, address(nominee1), { from: owner });
        // await user2.vote(industryElection1, address(nominee1), { from: owner });
        // await user3.vote(industryElection2, address(nominee2), { from: owner });
        // await user4.vote(industryElection2, address(nominee2), { from: owner });
    }

    it("should be a successful election with a high turnout", async function () {
        let republic = await Republic.deployed();

        let election = await setupElection(republic);

        await republic.startElection({ from: owner });

        var originalDelegates = await republic.getDelegates();

        await setupHighTurnoutElectionVotes(republic, election);

        // assert.equal(true, true, "yes!");
    });

});
