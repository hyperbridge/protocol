pragma solidity ^0.4.24;

import "./ProductBase.sol";

contract ProductLanguageSupport is ProductBase {

    constructor(address _marketplaceStorage) public {
        marketplaceStorage = MarketplaceStorage(_marketplaceStorage);
    }

    function createLanguageSupport(uint _productId, string _language, bool _closedCaptioning, bool _audioDescription) external onlyProductDeveloper(_productId) {
        marketplaceStorage.pushProductLanguageSupport(_productId, _language, _closedCaptioning, _audioDescription);
    }

    function editLanguageSupport(uint _productId, uint _index, string _language, bool _closedCaptioning, bool _audioDescription) external onlyProductDeveloper(_productId) {
        marketplaceStorage.setProductLanguageSupport(_productId, _index, _language, _closedCaptioning, _audioDescription);
    }

    function getLanguageSupport(uint _productId, uint _index) external view returns (string language, bool closedCaptioning, bool audioDescription) {
        ProductStorageAccess.LanguageSupport memory languageSupport = marketplaceStorage.getProductLanguageSupport(_productId, _index);

        return (languageSupport.language, languageSupport.closedCaptioning, languageSupport.audioDescription);
    }
}
