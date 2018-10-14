pragma solidity ^0.4.24;

import "./ProductBase.sol";
import "../libraries/storage/DeveloperStorageAccess.sol";

contract ProductRegistration is ProductBase {

    using DeveloperStorageAccess for MarketplaceStorage;

    event ProductCreated(uint productId);

    constructor(address _marketplaceStorage) public {
        marketplaceStorage = MarketplaceStorage(_marketplaceStorage);
    }

    function initialize() external {
        // Reserve product ID 0
        marketplaceStorage.incrementNextProductId();
    }

    function createProduct(string _title, string _type, string _content) external {
        // Verify that sender is a developer
        uint developerId = marketplaceStorage.getDeveloperId(msg.sender);
        require(developerId != 0, "This address is not a developer.");

        uint productId = marketplaceStorage.generateNewProductId();

        marketplaceStorage.setProductTitle(productId, _title);
        marketplaceStorage.setProductStatus(productId, uint(Status.Draft));
        marketplaceStorage.setProductType(productId, _type);
        marketplaceStorage.setProductContent(productId, _content);
        marketplaceStorage.setProductDeveloper(productId, msg.sender);
        marketplaceStorage.setProductDeveloperId(productId, developerId);

        marketplaceStorage.setDeveloperOwnsProduct(developerId, productId, true);
        marketplaceStorage.pushDeveloperOwnedProduct(developerId, productId);

        emit ProductCreated(productId);
    }

    function setProductTags(uint _productId, bytes32[] _systemTags, bytes32[] _authorTags) external onlyProductDeveloper(_productId) {
        for (uint i = 0; i < _systemTags.length; i++) {
            bytes32 systemTag = _systemTags[i];
            marketplaceStorage.setProductSystemTag(_productId, i, systemTag);
        }

        marketplaceStorage.setProductSystemTagsLength(_productId, _systemTags.length);

        for (uint j = 0; j < _authorTags.length; j++) {
            bytes32 authorTag = _authorTags[j];
            marketplaceStorage.setProductAuthorTag(_productId, j, authorTag);
        }

        marketplaceStorage.setProductAuthorTagsLength(_productId, _authorTags.length);
    }

    function editProductInfo(uint _productId, string _title, string _type, string _content) external onlyProductDeveloper(_productId) {
        marketplaceStorage.setProductTitle(_productId, _title);
        marketplaceStorage.setProductType(_productId, _type);
        marketplaceStorage.setProductContent(_productId, _content);
    }

    function getProduct(
        uint _productId
    )
        external
        view
        returns (
            uint id,
            uint status,
            string title,
            string productType,
            string content,
            bytes32[] systemTags,
            bytes32[] authorTags,
            address developer,
            uint developerId
        )
    {
        id = _productId;
        status = marketplaceStorage.getProductStatus(_productId);
        title = marketplaceStorage.getProductTitle(_productId);
        productType = marketplaceStorage.getProductType(_productId);
        content = marketplaceStorage.getProductContent(_productId);
        developer = marketplaceStorage.getProductDeveloper(_productId);
        developerId = marketplaceStorage.getProductDeveloperId(_productId);

        uint systemTagsLength = marketplaceStorage.getProductSystemTagsLength(_productId);
        for (uint i = 0; i < systemTagsLength; i++) {
            systemTags[i] = marketplaceStorage.getProductSystemTag(_productId, i);
        }

        uint authorTagsLength = marketplaceStorage.getProductAuthorTagsLength(_productId);
        for (uint j = 0; j < authorTagsLength; j++) {
            authorTags[j] = marketplaceStorage.getProductAuthorTag(_productId, j);
        }

        return (id, status, title, productType, content, systemTags, authorTags, developer, developerId);
    }
}
