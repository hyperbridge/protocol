pragma solidity ^0.4.24;

import "./EternalStorage.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

library TokenLib {
  using SafeMath for uint256;
  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);

  /* struct TokenStorage { address storage} */

  function transfer(address _storage, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    uint256 senderBalance = EternalStorage(_storage).getUint(keccak256(abi.encodePacked('balance', msg.sender)));
    require(_value <= senderBalance);

    uint256 receiverBalance = balanceOf(_storage, _to);
    EternalStorage(_storage).setUint(keccak256(abi.encodePacked('balance', msg.sender)), senderBalance.sub(_value));
    EternalStorage(_storage).setUint(keccak256(abi.encodePacked('balance', _to)), receiverBalance.add(_value));
    emit Transfer(msg.sender, _to, _value);

    return true;
  }

  function mint(address _storage, address _to, uint256 _value) public {
    EternalStorage(_storage).setUint(keccak256(abi.encodePacked('balance', _to)), _value);
    EternalStorage(_storage).setUint(keccak256(abi.encodePacked('totalSupply')), _value);
  }

  function setTotalSupply(address _storage, uint256 _totalSupply) public {
    EternalStorage(_storage).setUint(keccak256(abi.encodePacked('totalSupply')), _totalSupply);
  }

  function totalSupply(address _storage) public view returns (uint256) {
    return EternalStorage(_storage).getUint(keccak256(abi.encodePacked('totalSupply')));
  }


  function balanceOf(address _storage, address _owner) public view returns (uint256 balance) {
    return EternalStorage(_storage).getUint(keccak256(abi.encodePacked('balance', _owner)));
  }

  function getAllowance(address _storage, address _owner, address _spender) public view returns (uint256) {
    return EternalStorage(_storage).getUint(keccak256(abi.encodePacked('allowance', _owner, _spender)));
  }

  function setAllowance(address _storage, address _owner, address _spender, uint256 _allowance) public {
    EternalStorage(_storage).setUint(keccak256(abi.encodePacked('allowance', _owner, _spender)), _allowance);
  }

  function allowance(address _storage, address _owner, address _spender) public view  returns (uint256) {
    return getAllowance(_storage, _owner, _spender);
  }

  function transferFrom(address _storage, address _from, address _to, uint256 _value) public  returns (bool) {
    require(_to != address(0));
    require(_from != msg.sender);
    require(_value > 0);
    uint256 senderBalance = balanceOf(_storage, _from);
    require(senderBalance >= _value);

    uint256 allowanceValue = allowance(_storage, _from, msg.sender);
    require(allowanceValue >= _value);

    uint256 receiverBalance = balanceOf(_storage, _to);
    EternalStorage(_storage).setUint(keccak256(abi.encodePacked('balance', _from)), senderBalance.sub(_value));
    EternalStorage(_storage).setUint(keccak256(abi.encodePacked('balance', _to)), receiverBalance.add(_value));

    setAllowance(_storage, _from, msg.sender, allowanceValue.sub(_value));
    emit Transfer(_from, _to, _value);

    return true;
  }

  function approve(address _storage, address _spender, uint256 _value) public returns (bool) {
    require(_spender != address(0));
    require(msg.sender != _spender);

    setAllowance(_storage, msg.sender, _spender, _value);

    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  function increaseApproval(address _storage, address _spender, uint256 _addedValue) public returns (bool) {
    return approve(_storage, _spender, getAllowance(_storage, msg.sender, _spender).add(_addedValue));
  }

  function decreaseApproval(address _storage, address _spender, uint256 _subtractedValue) public returns (bool) {
    uint256 oldValue = getAllowance(_storage, msg.sender, _spender);

    if (_subtractedValue > oldValue) {
      return approve(_storage, _spender, 0);
    } else {
      return approve(_storage, _spender, oldValue.sub(_subtractedValue));
    }
  }

}
