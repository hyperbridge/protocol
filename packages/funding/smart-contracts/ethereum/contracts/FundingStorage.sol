pragma solidity ^0.4.24;

import "./openzeppelin/Ownable.sol";

contract FundingStorage is Ownable {


    /**** Storage Types *******/

    mapping(bytes32 => uint256)    private uIntStorage;
    mapping(bytes32 => string)     private stringStorage;
    mapping(bytes32 => address)    private addressStorage;
    mapping(bytes32 => bytes)      private bytesStorage;
    mapping(bytes32 => bool)       private boolStorage;
    mapping(bytes32 => int256)     private intStorage;

    /*** Modifiers ************/

     modifier onlyLatestFundingContract() {
        require(boolStorage[keccak256(abi.encodePacked("contract.address", msg.sender))]);
         _;
     }

    /**** Contract Registration ***********/

    function registerContract(string _name, address _oldContract, address _newContract) external onlyOwner {
        require((_oldContract == address(0) &&
                addressStorage[keccak256(abi.encodePacked("contract.address", _name))] == address(0))
                ||
                addressStorage[keccak256(abi.encodePacked("contract.address", _name))] == _oldContract);

        addressStorage[keccak256(abi.encodePacked("contract.address", _name))] = _newContract;
        boolStorage[keccak256(abi.encodePacked("contract.address", _oldContract))] = false;
        boolStorage[keccak256(abi.encodePacked("contract.address", _newContract))] = true;
    }

    function unregisterContract(string _name, address _contract) external onlyOwner {
        require(addressStorage[keccak256(abi.encodePacked("contract.address", _name))] == _contract);

        addressStorage[keccak256(abi.encodePacked("contract.address", _name))] = address(0);
        boolStorage[keccak256(abi.encodePacked("contract.address", _contract))] = false;
    }

    function getContractAddress(string _name) external view returns (address) {
        return addressStorage[keccak256(abi.encodePacked("contract.address", _name))];
    }

    function getContractIsValid(address _contract) external view returns (bool) {
        return boolStorage[keccak256(abi.encodePacked("contract.address", _contract))];
    }

    /**** Getters ***********/

    function getAddress(bytes32 _key) external view returns (address) {
        return addressStorage[_key];
    }

    function getUint(bytes32 _key) external view returns (uint) {
        return uIntStorage[_key];
    }

    function getString(bytes32 _key) external view returns (string) {
        return stringStorage[_key];
    }

    function getBytes(bytes32 _key) external view returns (bytes) {
        return bytesStorage[_key];
    }

    function getBool(bytes32 _key) external view returns (bool) {
        return boolStorage[_key];
    }

    function getInt(bytes32 _key) external view returns (int) {
        return intStorage[_key];
    }

    /**** Setters ***********/


    function setAddress(bytes32 _key, address _value) external onlyLatestFundingContract {
        addressStorage[_key] = _value;
    }

    function setUint(bytes32 _key, uint _value) external onlyLatestFundingContract {
        uIntStorage[_key] = _value;
    }

    function setString(bytes32 _key, string _value) external onlyLatestFundingContract {
        stringStorage[_key] = _value;
    }

    function setBytes(bytes32 _key, bytes _value) external onlyLatestFundingContract {
        bytesStorage[_key] = _value;
    }

    function setBool(bytes32 _key, bool _value) external onlyLatestFundingContract {
        boolStorage[_key] = _value;
    }

    function setInt(bytes32 _key, int _value) external onlyLatestFundingContract {
        intStorage[_key] = _value;
    }

    /**** Deletion ***********/

    function deleteAddress(bytes32 _key) external onlyLatestFundingContract {
        delete addressStorage[_key];
    }

    function deleteUint(bytes32 _key) external onlyLatestFundingContract {
        delete uIntStorage[_key];
    }

    function deleteString(bytes32 _key) external onlyLatestFundingContract {
        delete stringStorage[_key];
    }

    function deleteBytes(bytes32 _key) external onlyLatestFundingContract {
        delete bytesStorage[_key];
    }

    function deleteBool(bytes32 _key) external onlyLatestFundingContract {
        delete boolStorage[_key];
    }

    function deleteInt(bytes32 _key) external onlyLatestFundingContract {
        delete intStorage[_key];
    }
}
