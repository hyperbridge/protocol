pragma solidity ^0.4.24;

import "./ProductBase.sol";

contract ProductPricePlan is ProductBase {

    constructor(address _marketplaceStorage) public {
        marketplaceStorage = MarketplaceStorage(_marketplaceStorage);
    }

    function createPricePlan(uint _productId, string _code, string _name, uint _price) external onlyProductDeveloper(_productId) {
        marketplaceStorage.setProductPricePlan(_productId, _code, _name, _price);
    }

    function editPricePlan(uint _productId, string _code, string _name, uint _price) external onlyProductDeveloper(_productId) {
        marketplaceStorage.setProductPricePlan(_productId, _code, _name, _price);
    }

    function getPricePlan(uint _productId, string _code) external view returns (string code, string name, uint price) {
        ProductStorageAccess.PricePlan memory pricePlan = marketplaceStorage.getProductPricePlan(_productId, _code);

        return (pricePlan.code, pricePlan.name, pricePlan.price);
    }
}
