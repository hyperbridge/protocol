pragma solidity ^0.4.2;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Republic.sol";
import "../contracts/User.sol";

contract TestRepublic {
    function setupRepublic() public payable returns (Republic res) {
        Republic republic = new Republic(DeployedAddresses.NetworkAccessToken());
        republic.addDelegate(address(this));

        return republic;
    }

    function setupElection(Republic _republic) public payable returns (RepublicPrimaryElection res) {
        RepublicPrimaryElection election = _republic.createElection();

        string[11] memory industries = [
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

        election.createIndustryElection(industries[0]);
        election.createIndustryElection(industries[1]);
        // election.createIndustryElection(industries[2]);
        // election.createIndustryElection(industries[3]);
        // election.createIndustryElection(industries[4]);
        // election.createIndustryElection(industries[5]);
        // election.createIndustryElection(industries[6]);
        // election.createIndustryElection(industries[7]);
        // election.createIndustryElection(industries[8]);
        // election.createIndustryElection(industries[9]);
        // election.createIndustryElection(industries[10]);

        return election;
    }

    function setupHighTurnoutElectionVotes(RepublicPrimaryElection _election) public payable {
        address[11] memory industryElections = _election.getIndustryElections();

        RepublicIndustryElection industryElection1 = RepublicIndustryElection(industryElections[0]);
        RepublicIndustryElection industryElection2 = RepublicIndustryElection(industryElections[1]);

        User nominee1 = new User();
        User nominee2 = new User();

        //nominee1.registerAsNominee(industryElection1);
        //nominee2.registerAsNominee(industryElection2);

        // User user1 = new User();
        // User user2 = new User();
        // User user3 = new User();
        // User user4 = new User();

        // user1.vote(industryElection1, address(nominee1));
        // user2.vote(industryElection1, address(nominee1));
        // user3.vote(industryElection2, address(nominee2));
        // user4.vote(industryElection2, address(nominee2));
    }

    function setupLowTurnoutElectionVotes(RepublicPrimaryElection _election) public payable {
        address[11] memory industryElections = _election.getIndustryElections();

        RepublicIndustryElection industryElection1 = RepublicIndustryElection(industryElections[0]);
        RepublicIndustryElection industryElection2 = RepublicIndustryElection(industryElections[1]);

        User nominee1 = new User();
        User nominee2 = new User();

        nominee1.registerAsNominee(industryElection1);
        nominee2.registerAsNominee(industryElection2);

        //User user1 = new User();
        User user2 = new User();
        //User user3 = new User();
        User user4 = new User();

        user2.vote(industryElection1, address(nominee1));
        user4.vote(industryElection2, address(nominee2));
    }

    // function testDelegates() public payable {
    //     Republic republic = setupRepublic();

    //     address expected = 0xf17f52151EbEF6C7334FAD080c5704D77216b732;

    //     republic.addDelegate(expected);

    //     Assert.equal(republic.getDelegates()[1], expected, "Delegates should be addable by the contract owner");
    // }

    function testElectionSetup() public payable {
        Republic republic = setupRepublic();

        address expected = republic.createElection();

        Assert.equal(republic.getElection(), expected, "Current election should be last created election");
    }

    function testSuccessfulElection() public payable {
        Republic republic = setupRepublic();
        RepublicPrimaryElection election = setupElection(republic);

        republic.startElection();


        address[11] memory originalDelegates = republic.getDelegates();

        //setupHighTurnoutElectionVotes(election);

        // republic.endElection();

        // address[11] memory newDelegates = republic.getDelegates();

        // bool expected = true;
        // bool changed = false;

        // for (var i = 0; i < 11; i++) {
        //     if (newDelegates[i] != originalDelegates[i]) {
        //         changed = true;
        //     }
        // }

        // Assert.equal(changed, expected, "Delegates should have changed in the election");
    }

    // Election runs for 2 weeks
    // Election must be manually finalized by a majority vote of delegates within 1 week or automatically cancelled
    // If successful, current delegates are replaced with elected delegates
    // If unsuccessful, a re-election is held, up to a maximum of 2 cancellations
    // Cancellation will be ignored the third time and current delegates will be replaced with elected delegates
    function testCanceledElection() public payable {
        // Republic republic = setupRepublic();
        // RepublicPrimaryElection election = setupElection(republic);

        // address[11] memory originalDelegates = republic.getDelegates();

        // setupLowTurnoutElectionVotes(election);

        // republic.endElection();

        // address[11] memory newDelegates = republic.getDelegates();

        // bool expected = false;
        // bool changed = false;

        // for (var i = 0; i < 11; i++) {
        //     if (newDelegates[i] != originalDelegates[i]) {
        //         changed = true;
        //     }
        // }

        // Assert.equal(changed, expected, "Delegates should not have changed in the election, due to low turnout");
    }

    // For now, nominees should be able to win more than a single industry
    // In the future, it may fall back to the runner up
    function testAllowDoubleDelegatesElection() public payable {
        // Republic republic = setupRepublic();
        // RepublicPrimaryElection election = setupElection(republic);

        // setupHighTurnoutElectionVotes(election);

        // republic.endElection();

        // address[11] memory newDelegates = republic.getDelegates();

        // bool expected = true;
        // bool duplicateFound = false;

        // for (var i = 0; i < 11; i++) {
        //     for (var j = 0; j < 11; j++) {
        //         if (i != j && newDelegates[i] == newDelegates[j]) {
        //             duplicateFound = true;
        //         }
        //     }
        // }

        // Assert.equal(duplicateFound, expected, "Delegate should be allowed as leader of multiple industries");
    }
}
