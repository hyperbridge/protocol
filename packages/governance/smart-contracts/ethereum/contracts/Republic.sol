pragma solidity ^0.4.15;

import "./RepublicPrimaryElection.sol";
import "./User.sol";

/**
 * The Republic contract:
 * - Stores all the information about the Hyperbridge Republic
 */
contract Republic {
  modifier onlyDelegate() {
    require(msg.sender == owner || delegates[msg.sender]);
    _;
  }

  struct Delegate {
    uint version;
    string name;
    string description;
    string url;
  }

  address owner;
  address natAddress;

  mapping (address => bool) delegates;
  address[11] delegateAddresses;
  uint currentDelegateIndex;

  mapping (address => bool) elections;
  address[100] electionAddresses;
  uint currentElectionIndex;

  event RepublicAddDelegate();
  event RepublicCreateElection();
  event RepublicStartElection();
  event RepublicEndElection();

  function Republic(address _natAddress) public {
    owner = msg.sender;
    natAddress = _natAddress;
    currentElectionIndex = 0;
    currentDelegateIndex = 0;
  }

  function addDelegate(address _delegate) public payable returns(bool res) {
    delegates[_delegate] = true;
    delegateAddresses[currentDelegateIndex] = _delegate;
    currentDelegateIndex++;

    RepublicAddDelegate();
    
    return true;
  }

  function getDelegates() public view returns(address[11] res) {
    return delegateAddresses;
  }

  function createUser() public payable returns(address res) {
      User user = new User();

      return user;
  }

  function createElection() onlyDelegate public payable returns(RepublicPrimaryElection res) {
    RepublicPrimaryElection election = new RepublicPrimaryElection(natAddress);

    election.initRepublic(this);

    elections[address(election)] = true;
    electionAddresses[currentElectionIndex] = address(election);
    currentElectionIndex++;

    RepublicCreateElection();

    return election;
  }

  function getElection() public view returns(address res) {
    return electionAddresses[currentElectionIndex - 1];
  }

  function startElection() onlyDelegate public payable returns(bool res) {
    RepublicPrimaryElection currentElection = RepublicPrimaryElection(electionAddresses[currentElectionIndex - 1]);

    currentElection.start();

    RepublicStartElection();

    return true;
  }

  function endElection() onlyDelegate public payable returns(bool res) {
    RepublicPrimaryElection currentElection = RepublicPrimaryElection(electionAddresses[currentElectionIndex - 1]);

    uint electionResult = currentElection.tallyVotes();

    if (electionResult == 1) {
        // Successful election

    } else {
        // Log unsuccessful election reason

    }

    RepublicEndElection();

    return true;
  }
}
