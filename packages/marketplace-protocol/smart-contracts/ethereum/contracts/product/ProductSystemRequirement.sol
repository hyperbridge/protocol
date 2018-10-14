pragma solidity ^0.4.24;

import "./ProductBase.sol";

contract ProductSystemRequirement is ProductBase {

    constructor(address _marketplaceStorage) public {
        marketplaceStorage = MarketplaceStorage(_marketplaceStorage);
    }

    function createSystemRequirement(uint _productId, string _systemInfo, string _requirementInfo) external onlyProductDeveloper(_productId) {
        marketplaceStorage.pushProductSystemRequirement(_productId, _systemInfo, _requirementInfo);
    }

    function editSystemRequirement(uint _productId, uint _index, string _systemInfo, string _requirementInfo) external onlyProductDeveloper(_productId) {
        marketplaceStorage.setProductSystemRequirement(_productId, _index, _systemInfo, _requirementInfo);
    }

    function getSystemRequirement(uint _productId, uint _index) external view returns (string systemInfo, string requirementInfo) {
        ProductStorageAccess.SystemRequirement memory requirement = marketplaceStorage.getProductSystemRequirement(_productId, _index);

        return (requirement.systemInfo, requirement.requirementInfo);
    }
}
