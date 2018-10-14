pragma solidity ^0.4.24;

import "./ProductBase.sol";
import "../libraries/utils/StringUtils.sol";

contract ProductPurchase is ProductBase {

    using StringUtils for string;

    event productPurchased(uint productId, string pricePlanCode, uint value, address purchaser, address developer);

    constructor(address _marketplaceStorage) public {
        marketplaceStorage = MarketplaceStorage(_marketplaceStorage);
    }

    function purchase(uint _productId, string _pricePlanCode) external payable {
        string memory registeredPricePlanCode = marketplaceStorage.getProductPricePlanCode(_productId, _pricePlanCode);
        require(registeredPricePlanCode.equals(_pricePlanCode), "Price plan does not exist.");

        uint productPrice = marketplaceStorage.getProductPricePlanPrice(_productId, _pricePlanCode);
        require(msg.value == productPrice, "Transaction value incorrect.");

        // Mark that msg.sender has purchased this product
        uint senderPurchases = marketplaceStorage.getProductHasPurchased(_productId, msg.sender);
        marketplaceStorage.setProductHasPurchased(_productId, msg.sender, senderPurchases + 1);

        address developerAddress = marketplaceStorage.getProductDeveloper(_productId);

        // Register the purchase order
        marketplaceStorage.pushProductPurchaseOrder(_productId, msg.sender, _pricePlanCode, msg.value, developerAddress);

        // Send the funds
        developerAddress.transfer(msg.value);

        emit productPurchased(_productId, _pricePlanCode, msg.value, msg.sender, developerAddress);
    }

    function getPurchaseOrder(uint _productId, address _purchaser, uint _index) external view returns (uint id, string pricePlanCode, uint value, address purchaser, address developer) {
        ProductStorageAccess.PurchaseOrder memory order = marketplaceStorage.getProductPurchaseOrder(_productId, _purchaser, _index);

        return (order.productId, order.pricePlanCode, order.value, order.purchaser, order.developer);
    }
}
