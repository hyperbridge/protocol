pragma solidity ^0.4.24;

import "../../MarketplaceStorage.sol";

library AdministrationStorageAccess {

    /*
        There is a registry of adminstrators:
            mapping(address => bool) isAdmin                                (marketplace.isAdmin)
    */

    // Getters

    function getIsAdmin(MarketplaceStorage _storage, address _address) internal view returns (bool) {
        return _storage.getBool(keccak256(abi.encodePacked("marketplace.isAdmin", _address)));
    }



    // Setters

    function setIsAdmin(MarketplaceStorage _storage, address _address, bool _isAdmin) internal {
        _storage.setBool(keccak256(abi.encodePacked("marketplace.isAdmin", _address)), _isAdmin);
    }
}
