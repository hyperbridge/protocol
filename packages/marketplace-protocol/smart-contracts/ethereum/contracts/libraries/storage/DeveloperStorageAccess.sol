pragma solidity ^0.4.24;

import "../../MarketplaceStorage.sol";

library DeveloperStorageAccess {

    struct Developer {
        uint id;
        address addr;
        string name;
        mapping(uint => bool) ownsProduct; // product id => owned by this dev
        uint[] ownedProductIds; // the products belonging to this developer
    }

    /*
        Each developer (indexed by ID) stores the following data in MarketplaceStorage and accesses it through the
        associated namespace:
            address addr                                                    (developer.addr)
            string name                                                     (developer.name)
            mapping(uint (id) => bool) ownsProduct                          (developer.ownsProduct)
            uint[] ownedProductIds                                          (developer.productIds)

        In addition, there is a registry of developers:
            mapping(address => uint (id)) developerMap                      (developer.developerMap)
    */

    // Getters

    function generateNewDeveloperId(MarketplaceStorage _storage) internal returns (uint) {
        uint id = getNextDeveloperId(_storage);
        incrementNextDeveloperId(_storage);
        return id;
    }

    function getNextDeveloperId(MarketplaceStorage _storage) internal view returns (uint) {
        return _storage.getUint(keccak256("developer.nextDeveloperId"));
    }

    function getDeveloperId(MarketplaceStorage _storage, address _developerAddress) internal view returns (uint) {
        return _storage.getUint(keccak256(abi.encodePacked("developer.developerMap", _developerAddress)));
    }

    function getDeveloperAddress(MarketplaceStorage _storage, uint _developerId) internal view returns (address) {
        return _storage.getAddress(keccak256(abi.encodePacked("developer.address", _developerId)));
    }

    function getDeveloperName(MarketplaceStorage _storage, uint _developerId) internal view returns (string) {
        return _storage.getString(keccak256(abi.encodePacked("developer.name", _developerId)));
    }

    function getDeveloperOwnsProduct(MarketplaceStorage _storage, uint _developerId, uint _productId) internal view returns (bool) {
        return _storage.getBool(keccak256(abi.encodePacked("developer.ownsProduct", _developerId, _productId)));
    }

    function getDeveloperOwnedProductsLength(MarketplaceStorage _storage, uint _developerId) internal view returns (uint) {
        return _storage.getUint(keccak256(abi.encodePacked("developer.productIds.length", _developerId)));
    }

    function getDeveloperOwnedProduct(MarketplaceStorage _storage, uint _developerId, uint _index) internal view returns (uint) {
        return _storage.getUint(keccak256(abi.encodePacked("developer.productIds", _index, _developerId)));
    }

    function getDeveloperOwnedProducts(MarketplaceStorage _storage, uint _developerId) internal view returns (uint[]) {
        uint length = getDeveloperOwnedProductsLength(_storage, _developerId);

        uint[] memory ownedIds = new uint[](length);

        for (uint i = 0; i < length; i++) {
            ownedIds[i] = getDeveloperOwnedProduct(_storage, _developerId, i);
        }

        return ownedIds;
    }

    function getDeveloper(MarketplaceStorage _storage, uint _developerId) internal view returns (Developer) {
        require(getDeveloperAddress(_storage, _developerId) != address(0), "Developer does not exist."); // check that developer exists

        Developer memory developer = Developer({
            id: _developerId,
            addr: getDeveloperAddress(_storage, _developerId),
            name: getDeveloperName(_storage, _developerId),
            ownedProductIds: getDeveloperOwnedProducts(_storage, _developerId)
        });

        return developer;
    }



    // Setters

    function incrementNextDeveloperId(MarketplaceStorage _storage) internal {
        uint currentId = _storage.getUint(keccak256("developer.nextDeveloperId"));
        _storage.setUint(keccak256("developer.nextDeveloperId"), currentId + 1);
    }

    function setDeveloperId(MarketplaceStorage _storage, address _developerAddress, uint _developerId) internal {
        _storage.setUint(keccak256(abi.encodePacked("developer.developerMap", _developerAddress)), _developerId);
    }

    function setDeveloperAddress(MarketplaceStorage _storage, uint _developerId, address _address) internal {
        _storage.setAddress(keccak256(abi.encodePacked("developer.address", _developerId)), _address);
    }

    function setDeveloperName(MarketplaceStorage _storage, uint _developerId, string _name) internal {
        _storage.setString(keccak256(abi.encodePacked("developer.name", _developerId)), _name);
    }

    function setDeveloperOwnsProduct(MarketplaceStorage _storage, uint _developerId, uint _productId, bool _ownsProduct) internal {
        _storage.setBool(keccak256(abi.encodePacked("developer.ownsProduct", _developerId, _productId)), _ownsProduct);
    }

    function setDeveloperOwnedProductsLength(MarketplaceStorage _storage, uint _developerId, uint _length) internal {
        _storage.setUint(keccak256(abi.encodePacked("developer.productIds.length", _developerId)), _length);
    }

    function setDeveloperOwnedProduct(MarketplaceStorage _storage, uint _developerId, uint _index, uint _productId) internal {
        _storage.setUint(keccak256(abi.encodePacked("developer.productIds", _index, _developerId)), _productId);
    }

    function pushDeveloperOwnedProduct(MarketplaceStorage _storage, uint _developerId, uint _productId) internal {
        uint nextIndex = getDeveloperOwnedProductsLength(_storage, _developerId);
        setDeveloperOwnedProduct(_storage, _developerId, nextIndex, _productId);
        setDeveloperOwnedProductsLength(_storage, _developerId, nextIndex + 1);
    }
}
