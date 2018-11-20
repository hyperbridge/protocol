pragma solidity ^0.4.15;

import "./Republic.sol";
import "./RepublicIndustryElection.sol";

contract User {

  address owner;
  Republic republic;

  event UserCreated();
  
  function User() public {
    owner = msg.sender;

    UserCreated();
  }

  function setRepublic(Republic _republic) public payable returns (bool res) {
    require(msg.sender == owner);

    republic = _republic;

    return true;
  }

  function vote(RepublicIndustryElection _election, address _nominee) public payable returns (bool res) {
    require(msg.sender == owner);
    _election.vote(_nominee);
    return true;
  }

  function registerAsNominee(address _election) public payable returns (bool res) {
    RepublicIndustryElection(_election).registerAsNominee();
    return true;
  }
}