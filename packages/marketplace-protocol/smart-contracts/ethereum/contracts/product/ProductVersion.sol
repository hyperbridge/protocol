pragma solidity ^0.4.24;

import "./ProductBase.sol";

contract ProductVersion is ProductBase {

    constructor(address _marketplaceStorage) public {
        marketplaceStorage = MarketplaceStorage(_marketplaceStorage);
    }

    function submitVersionForReview(uint _productId, string _version, string _downloadRefType, string _downloadRefSource, string _checksum) external onlyProductDeveloper(_productId) {
        // Check that version is specified
        require(bytes(_version).length > 0);
        // Check that version does not already exist
        require(bytes(marketplaceStorage.getProductVersionVersion(_productId, _version)).length == 0);

        marketplaceStorage.setProductVersion(_productId, _version, _downloadRefType, _downloadRefSource, _checksum, now);
        marketplaceStorage.setProductVersionVotingIsActive(_productId, _version, true);
    }

    function getLatestVersion(uint _productId) external view returns (string version, string downloadRefType, string downloadRefSource, string checksum, uint createdAt) {
        ProductStorageAccess.ProductVersion memory productVersion = marketplaceStorage.getProductLatestVersion(_productId);

        return (productVersion.version, productVersion.downloadRefType, productVersion.downloadRefSource, productVersion.checksum, productVersion.createdAt);
    }

    function getVersion(uint _productId, string _version) external view returns (string version, string downloadRefType, string downloadRefSource, string checksum, uint createdAt) {
        ProductStorageAccess.ProductVersion memory productVersion = marketplaceStorage.getProductVersion(_productId, _version);

        return (productVersion.version, productVersion.downloadRefType, productVersion.downloadRefSource, productVersion.checksum, productVersion.createdAt);
    }
}
