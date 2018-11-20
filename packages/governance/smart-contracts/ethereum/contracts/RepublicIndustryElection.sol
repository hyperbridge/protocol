pragma solidity ^0.4.15;

import "./NetworkAccessToken.sol";
import "./Republic.sol";

/**
 * The Republic Industry election contract:
 * - Allows NAT token holders to vote for delegates
 */
contract RepublicIndustryElection {
  modifier onlyDelegate() {
    require(msg.sender == owner || delegates[msg.sender]);
    _;
  }

  address owner;
  Republic republic;

  mapping (address => bool) delegates;
  address[11] delegateAddresses;

  mapping (address => mapping (address => uint)) nominees;
  mapping (address => uint) nomineeVotes;
  
  mapping (address => uint) registeredVoters;

  address[] registeredNominees;
  mapping (address => bool) registeredNomineeAddresses;
  uint registeredNomineeCount;

  string industry;
  bool started;
  address natAddress;
  uint nomineeLimit;

  event RepublicIndustryElectionInitRepublic();
  event RepublicIndustryElectionVote();
  event RepublicIndustryElectionSetNomineeLimit();
  event RepublicIndustryElectionRegisterAsNominee();
  event RepublicIndustryElectionUnregisterAsNominee();
  event RepublicIndustryElectionStart();
  event RepublicIndustryElectionEnd();
  
  function RepublicIndustryElection(address _natAddress, string _industry) public {
    //registeredNominees = new address[](5);
    started = false;
    owner = msg.sender;
    natAddress = _natAddress;
    industry = _industry;
    nomineeLimit = 100;
  }

  function initRepublic(address _republic) onlyDelegate public payable returns(bool res) {
    republic = Republic(_republic);
    delegateAddresses = republic.getDelegates();

    for (uint i; i < delegateAddresses.length; i++) {
      delegates[delegateAddresses[i]] = true;
    }

    RepublicIndustryElectionInitRepublic();

    return true;
  }

  function getDelegates() public view returns(address[11] res) {
    return delegateAddresses;
  }

  function vote(address _nominee) public payable returns(bool res) {
    require(started);

    // Sender should not be allowed to vote more than once
    require(nominees[_nominee][msg.sender] == 0);
    require(registeredNomineeAddresses[_nominee]);

    NetworkAccessToken token = NetworkAccessToken(natAddress);
    uint256 balance = token.balanceOf(msg.sender);

    nominees[_nominee][msg.sender] = balance;
    nomineeVotes[_nominee] += balance;

    RepublicIndustryElectionVote();

    return true;
  }

  function setNomineeLimit(uint _limit) public payable returns(bool res) {
      nomineeLimit = _limit;

      RepublicIndustryElectionSetNomineeLimit();

      return true;
  }

  function registerAsNominee() public payable returns(bool res) {
    //require (registeredNomineeCount < nomineeLimit);

    // bool found = false;
    // uint256 foundIndex = 0;

    // for (uint256 i = 0; i < registeredNominees.length; i++) {
    //     if (registeredNominees[i] == msg.sender) {
    //         found = true;
    //         foundIndex = i;
    //     }
    // }

    // if (found) {
    //     return false;
    // }

    // registeredNominees.push(msg.sender);
    // registeredNomineeAddresses[msg.sender] = true;
    // registeredNomineeCount++;

    RepublicIndustryElectionRegisterAsNominee();

    return true;
  }

  function unregesterAsNominee() public payable returns(bool res) {
      delete registeredNomineeAddresses[msg.sender];

      RepublicIndustryElectionUnregisterAsNominee();

      return true;
  }

  function start() onlyDelegate public payable returns(bool res) {
    started = true;

    RepublicIndustryElectionStart();

    return true;
  }

  function end() onlyDelegate public view returns(address res) {
    RepublicIndustryElectionEnd();
    
    return registeredNominees[0];
  }
}

