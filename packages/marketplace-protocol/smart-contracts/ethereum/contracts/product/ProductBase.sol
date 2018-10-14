pragma solidity ^0.4.24;

import "../MarketplaceStorage.sol";
import "../libraries/storage/ProductStorageAccess.sol";

contract ProductBase {

    using ProductStorageAccess for MarketplaceStorage;

    modifier onlyProductDeveloper(uint _productId) {
        require(msg.sender == marketplaceStorage.getProductDeveloper(_productId), "You must be the product developer to perform this action.");
        _;
    }

    enum Status { Inactive, Draft, Pending, Published, Rejected }

    MarketplaceStorage public marketplaceStorage;
}
