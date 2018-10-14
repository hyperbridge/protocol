pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";

contract UpgradableToken is ERC20, Ownable {
  address public predecessor;
  address public successor;
  string public version;

  event UpgradedTo(address indexed successor);
  event UpgradedFrom(address indexed predecessor);

  modifier unlessUpgraded() {
    require (msg.sender == successor || successor == address(0));
    _;
  }

  modifier isUpgraded() {
    require (successor != address(0));
    _;
  }

  modifier hasPredecessor() {
    require (predecessor != address(0));
    _;
  }

  function isDeprecated() public view returns (bool) {
    return successor != address(0);
  }

  constructor(string _version) public {
      version = _version;
  }

  function upgradeTo(address _successor) public onlyOwner unlessUpgraded returns (bool){
    require(_successor != address(0));

    uint remainingContractBalance = balanceOf(this);

    if (remainingContractBalance > 0) {
      this.transfer(_successor, remainingContractBalance);
    }
    successor = _successor;
    emit UpgradedTo(_successor);
    return true;
  }

  function upgradedFrom(address _predecessor) public onlyOwner returns (bool) {
    require(_predecessor != address(0));

    predecessor = _predecessor;

    emit UpgradedFrom(_predecessor);

    return true;
  }
}
