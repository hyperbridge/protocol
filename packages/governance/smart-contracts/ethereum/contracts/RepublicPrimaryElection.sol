pragma solidity ^0.4.15;

import "./NetworkAccessToken.sol";
import "./Republic.sol";
import "./RepublicIndustryElection.sol";

/**
 * The Republic primary election contract:
 * - Allows NAT token holders to vote in the industry elections
 * - The winners the top 11 industries are given a seat as a delegate
 * - Delegates gain administrative power over the Hyperbridge ecosystem
 *   as well as having higher voting power than the average token holder
 */
contract RepublicPrimaryElection {
  modifier onlyDelegate() {
    require(msg.sender == owner || delegates[msg.sender]);
    _;
  }

  address owner;
  Republic republic;
  address natAddress;
  bool started;

  mapping (address => bool) delegates;
  address[11] delegateAddresses;

  mapping (address => bool) industryElection;
  address[11] industryElections;
  uint industryElectionIndex;
  uint industryElectionLimit;

  event RepublicPrimaryElectionCreateIndustryElection();
  event RepublicPrimaryElectionSetIndustryElections();
  event RepublicPrimaryElectionInitRepublic();
  event RepublicPrimaryElectionTallyVotes();
  event RepublicPrimaryElectionStart();
  event RepublicPrimaryElectionEnd();

  function RepublicPrimaryElection(address _natAddress) public {
    owner = msg.sender;
    natAddress = _natAddress;
    industryElectionIndex = 0;
    industryElectionLimit = 11;
    started = false;
  }

  function createIndustryElection(string _category) onlyDelegate public payable returns(bool res) {
    require(!started);
    require(industryElectionIndex < industryElectionLimit);

    RepublicIndustryElection election = new RepublicIndustryElection(natAddress, _category);
    election.initRepublic(republic);

    industryElections[industryElectionIndex] = address(election);

    industryElectionIndex++;

    RepublicPrimaryElectionCreateIndustryElection();

    return true;
  }

  function setIndustryElections(address[11] _elections) onlyDelegate public payable returns(bool res) {
    industryElections = _elections;

    RepublicPrimaryElectionSetIndustryElections();
  }

  // TODO: add onlyDelegate modifier
  function initRepublic(Republic _republic) onlyDelegate public payable returns(bool res) {
    republic = _republic;
    delegateAddresses = republic.getDelegates();

    for (uint i; i < delegateAddresses.length; i++) {
      delegates[delegateAddresses[i]] = true;
    }

    RepublicPrimaryElectionInitRepublic();

    return true;
  }

  function getDelegates() public view returns(address[11] res) {
    return delegateAddresses;
  }

  function start() onlyDelegate public payable returns(bool res) {
    require (!started);

    for (uint i; i < industryElections.length; i++) {
      if (industryElections[i] == 0) {continue;}

      RepublicIndustryElection(industryElections[i]).start();
    }

    started = true;

    RepublicPrimaryElectionStart();

    return true;
  }

  function tallyVotes() onlyDelegate public payable returns(uint256 res) {
    require (started);

    RepublicPrimaryElectionTallyVotes();

    return 1;
  }

  function end() onlyDelegate public view returns(address[] res) {
    require (started);

    address[] memory industryWinnerAddresses = new address[](11);

    // RepublicPrimaryElectionEnd the industry elections
    // Choose the top 11 industry winners as the delegates
    for (uint256 i; i < industryElections.length; i++) {
      if (industryElections[i] == 0) {continue;}
      
      address winner1 = RepublicIndustryElection(industryElections[i]).end();

      industryWinnerAddresses[i] = winner1;
    }

    RepublicPrimaryElectionEnd();

    return industryWinnerAddresses;
  }

  function getIndustryElections() public view returns(address[11] res) {
    return industryElections;
  }
}

