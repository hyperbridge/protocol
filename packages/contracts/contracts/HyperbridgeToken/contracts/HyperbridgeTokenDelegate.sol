pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/lifecycle/Pausable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/DetailedERC20.sol";
import "./TokenLib.sol";
import "./UpgradableToken.sol";

contract HyperbridgeTokenDelegate is UpgradableToken, DetailedERC20, Pausable {

    using TokenLib for address;

    address tokenStorage;

    constructor(string _name, string _symbol, uint8 _decimals, address _storage, string _version)
        DetailedERC20(_name, _symbol, _decimals) UpgradableToken(_version) public {
        setStorage(_storage);
    }

    function setTotalSupply(uint256 _totalSupply) public onlyOwner {
        tokenStorage.setTotalSupply(_totalSupply);
    }

    function setStorage(address _storage) public onlyOwner unlessUpgraded whenNotPaused {
        tokenStorage = _storage;
    }

    function totalSupply() public view returns (uint){
        return tokenStorage.totalSupply();
    }

    function mint(address _to, uint _value) public onlyOwner unlessUpgraded whenNotPaused {
        tokenStorage.mint(_to, _value);
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return tokenStorage.balanceOf(_owner);
    }

    function transfer(address _to, uint _value) public unlessUpgraded whenNotPaused returns(bool) {
        return tokenStorage.transfer(_to, _value);
    }

    function approve(address _to, uint _value) public unlessUpgraded whenNotPaused returns(bool) {
        return tokenStorage.approve(_to, _value);
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return tokenStorage.allowance(_owner, _spender);
    }

    function transferFrom(address _from, address _to, uint256 _value) public unlessUpgraded whenNotPaused returns (bool) {
        return tokenStorage.transferFrom(_from, _to, _value);
    }

    function increaseApproval(address _spender, uint256 _addedValue) public unlessUpgraded whenNotPaused returns (bool) {
        return tokenStorage.increaseApproval(_spender, _addedValue);
    }

    function decreaseApproval(address _spender, uint256 _subtractedValue) public unlessUpgraded whenNotPaused returns (bool) {
        return tokenStorage.decreaseApproval(_spender, _subtractedValue);
    }
}
