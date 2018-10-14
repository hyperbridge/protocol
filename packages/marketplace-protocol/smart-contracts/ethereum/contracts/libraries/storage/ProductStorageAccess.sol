pragma solidity ^0.4.24;

import "../../MarketplaceStorage.sol";
import "../utils/Bytes32Utils.sol";
import "../utils/BytesUtils.sol";

library ProductStorageAccess {

    using Bytes32Utils for bytes32;
    using BytesUtils for bytes;

    struct PricePlan {
        string code;
        string name;
        uint price;
    }

    struct SystemRequirement {
        string systemInfo;
        string requirementInfo;
    }

    struct LanguageSupport {
        string language;
        bool closedCaptioning;
        bool audioDescription;
    }

    struct ProductVersion {
        string version;
        string downloadRefType;
        string downloadRefSource;
        string checksum;
        uint createdAt;
    }

    struct VersionVoting {
        uint approvalCount;
        uint disapprovalCount;
        bool isActive;
        bool hasFailed;
        mapping(address => bool) voters;
    }

    struct PurchaseOrder {
        uint productId;
        string pricePlanCode;
        uint value;
        address purchaser;
        address developer;
    }

    /*
        Each product (indexed by ID) stores the following data in MarketplaceStorage and accesses it through the
        associated namespace:
            string title                                                    (product.title)
            string type                                                     (product.type)
            string content                                                  (product.content)
            ProduceBase.Status Status                                       (product.status)
            bytes32[] systemTags                                            (product.systemTags)
            bytes32[] authorTags                                            (product.authorTags)
            address developer                                               (product.developer)
            uint developerId                                                (product.developerId)
            mapping(address => uint) purchasers                             (product.purchasers)
            Version latestVersion
                string version                                              (product.latestVersion.version)
                string downloadRefType                                      (product.latestVersion.downloadRefType)
                string downloadRefSource                                    (product.latestVersion.downloadRefSource)
                string checksum                                             (product.latestVersion.checksum)
                uint createdAt                                              (product.latestVersion.createdAt)
            mapping(string (version) => ProductVersion) versions
                string version                                              (product.versions.version)
                string downloadRefType                                      (product.versions.downloadRefType)
                string downloadRefSource                                    (product.versions.downloadRefSource)
                string checksum                                             (product.versions.checksum)
                uint createdAt                                              (product.versions.createdAt)
            mapping(string (version) => VersionVoting) versionVoting
                uint approvalCount                                          (product.versionVoting.approvalCount)
                uint disapprovalCount                                       (product.versionVoting.disapprovalCount)
                bool isActive                                               (product.versionVoting.isActive)
                bool hasFailed                                              (product.versionVoting.hasFailed)
                mapping(address => bool) voters                             (product.versionVoting.voters)
            PricePlan[] pricePlans
                string code                                                 (product.pricePlans.code)
                string name                                                 (product.pricePlans.name)
                uint price                                                  (product.pricePlans.price)
            SystemRequirement[] systemRequirements
                string system                                               (product.systemRequirements.system)
                string info                                                 (product.systemRequirements.info)
            LanguageSupport[] languagesSupported
                string language                                             (product.languagesSupported.language)
                bool closedCaptioning                                       (product.languagesSupported.closedCaptioning)
                bool audioDescription                                       (product.languagesSupported.audioDescription)
            mapping(address (purchaser) => PurchaseOrder[]) purchaseOrders
                uint productId                                              (product.purchaseOrders.productId)
                string pricePlanCode                                        (product.purchaseOrders.pricePlanCode)
                uint value                                                  (product.purchaseOrders.value)
                address purchaser                                           (product.purchaseOrders.purchaser)
                address developer                                           (product.purchaseOrders.developer)


    */

    /**** Getters *******/

    function generateNewProductId(MarketplaceStorage _storage) internal returns (uint) {
        uint id = getNextProductId(_storage);
        incrementNextProductId(_storage);
        return id;
    }

    function getNextProductId(MarketplaceStorage _storage) internal view returns (uint) {
        return _storage.getUint(keccak256("product.nextProductId"));
    }

    function getProductTitle(MarketplaceStorage _storage, uint _productId) internal view returns (string) {
        return _storage.getString(keccak256(abi.encodePacked("product.title", _productId)));
    }

    function getProductType(MarketplaceStorage _storage, uint _productId) internal view returns (string) {
        return _storage.getString(keccak256(abi.encodePacked("product.type", _productId)));
    }

    function getProductStatus(MarketplaceStorage _storage, uint _productId) internal view returns (uint) {
        return _storage.getUint(keccak256(abi.encodePacked("product.status", _productId)));
    }

    function getProductContent(MarketplaceStorage _storage, uint _productId) internal view returns (string) {
        return _storage.getString(keccak256(abi.encodePacked("product.content", _productId)));
    }

    function getProductSystemTagsLength(MarketplaceStorage _storage, uint _productId) internal view returns (uint) {
        return _storage.getUint(keccak256(abi.encodePacked("product.systemTags.length", _productId)));
    }

    function getProductSystemTag(MarketplaceStorage _storage, uint _productId, uint _index) internal view returns (bytes32) {
        bytes memory bytesTag = _storage.getBytes(keccak256(abi.encodePacked("product.systemTags", _productId, _index)));
        return bytesTag.toBytes32();
    }

    function getProductAuthorTagsLength(MarketplaceStorage _storage, uint _productId) internal view returns (uint) {
        return _storage.getUint(keccak256(abi.encodePacked("product.authorTags.length", _productId)));
    }

    function getProductAuthorTag(MarketplaceStorage _storage, uint _productId, uint _index) internal view returns (bytes32) {
        bytes memory bytesTag = _storage.getBytes(keccak256(abi.encodePacked("product.authorTags", _productId, _index)));
        return bytesTag.toBytes32();
    }

    function getProductDeveloper(MarketplaceStorage _storage, uint _productId) internal view returns (address) {
        return _storage.getAddress(keccak256(abi.encodePacked("product.developer", _productId)));
    }

    function getProductDeveloperId(MarketplaceStorage _storage, uint _productId) internal view returns (uint) {
        return _storage.getUint(keccak256(abi.encodePacked("product.developerId", _productId)));
    }

    // Price Plan

    function getProductPricePlanCode(MarketplaceStorage _storage, uint _productId, string _code) internal view returns (string) {
        return _storage.getString(keccak256(abi.encodePacked("product.pricePlans.code", _productId, _code)));
    }

    function getProductPricePlanName(MarketplaceStorage _storage, uint _productId, string _code) internal view returns (string) {
        return _storage.getString(keccak256(abi.encodePacked("product.pricePlans.name", _productId, _code)));
    }

    function getProductPricePlanPrice(MarketplaceStorage _storage, uint _productId, string _code) internal view returns (uint) {
        return _storage.getUint(keccak256(abi.encodePacked("product.pricePlans.price", _productId, _code)));
    }

    function getProductPricePlan(MarketplaceStorage _storage, uint _productId, string _code) internal view returns (PricePlan) {
        PricePlan memory pricePlan = PricePlan({
            code: getProductPricePlanCode(_storage, _productId, _code),
            name: getProductPricePlanName(_storage, _productId, _code),
            price: getProductPricePlanPrice(_storage, _productId, _code)
        });

        return pricePlan;
    }

    // System Requirement

    function getProductSystemRequirementsLength(MarketplaceStorage _storage, uint _productId) internal view returns (uint) {
        return _storage.getUint(keccak256(abi.encodePacked("product.systemRequirements.length", _productId)));
    }

    function getProductSystemRequirementSystem(MarketplaceStorage _storage, uint _productId, uint _index) internal view returns (string) {
        return _storage.getString(keccak256(abi.encodePacked("product.systemRequirements.system", _productId, _index)));
    }

    function getProductSystemRequirementInfo(MarketplaceStorage _storage, uint _productId, uint _index) internal view returns (string) {
        return _storage.getString(keccak256(abi.encodePacked("product.systemRequirements.info", _productId, _index)));
    }

    function getProductSystemRequirement(MarketplaceStorage _storage, uint _productId, uint _index) internal view returns (SystemRequirement) {
        SystemRequirement memory systemRequirement = SystemRequirement({
            systemInfo: getProductSystemRequirementSystem(_storage, _productId, _index),
            requirementInfo: getProductSystemRequirementInfo(_storage, _productId, _index)
        });

        return systemRequirement;
    }

    // Language Support

    function getProductLanguagesSupportedLength(MarketplaceStorage _storage, uint _productId) internal view returns (uint) {
        return _storage.getUint(keccak256(abi.encodePacked("product.languagesSupported.length", _productId)));
    }

    function getProductLanguageSupportLanguage(MarketplaceStorage _storage, uint _productId, uint _index) internal view returns (string) {
        return _storage.getString(keccak256(abi.encodePacked("product.languagesSupported.language", _productId, _index)));
    }

    function getProductLanguageSupportClosedCaptioning(MarketplaceStorage _storage, uint _productId, uint _index) internal view returns (bool) {
        return _storage.getBool(keccak256(abi.encodePacked("product.languagesSupported.closedCaptioning", _productId, _index)));
    }

    function getProductLanguageSupportAudioDescription(MarketplaceStorage _storage, uint _productId, uint _index) internal view returns (bool) {
        return _storage.getBool(keccak256(abi.encodePacked("product.languagesSupported.audioDescription", _productId, _index)));
    }

    function getProductLanguageSupport(MarketplaceStorage _storage, uint _productId, uint _index) internal view returns (LanguageSupport) {
        LanguageSupport memory languageSupport = LanguageSupport({
            language: getProductLanguageSupportLanguage(_storage, _productId, _index),
            closedCaptioning: getProductLanguageSupportClosedCaptioning(_storage, _productId, _index),
            audioDescription: getProductLanguageSupportAudioDescription(_storage, _productId, _index)
        });

        return languageSupport;
    }

    // Version

    function getProductLatestVersionVersion(MarketplaceStorage _storage, uint _productId) internal view returns (string) {
        return _storage.getString(keccak256(abi.encodePacked("product.latestVersion.version", _productId)));
    }

    function getProductLatestVersionDownloadRefType(MarketplaceStorage _storage, uint _productId) internal view returns (string) {
        return _storage.getString(keccak256(abi.encodePacked("product.latestVersion.downloadRefType", _productId)));
    }

    function getProductLatestVersionDownloadRefSource(MarketplaceStorage _storage, uint _productId) internal view returns (string) {
        return _storage.getString(keccak256(abi.encodePacked("product.latestVersion.downloadRefSource", _productId)));
    }

    function getProductLatestVersionChecksum(MarketplaceStorage _storage, uint _productId) internal view returns (string) {
        return _storage.getString(keccak256(abi.encodePacked("product.latestVersion.checksum", _productId)));
    }

    function getProductLatestVersionCreatedAt(MarketplaceStorage _storage, uint _productId) internal view returns (uint) {
        return _storage.getUint(keccak256(abi.encodePacked("product.latestVersion.createdAt", _productId)));
    }

    function getProductLatestVersion(MarketplaceStorage _storage, uint _productId) internal view returns (ProductVersion) {
        ProductVersion memory version = ProductVersion({
            version: getProductLatestVersionVersion(_storage, _productId),
            downloadRefType: getProductLatestVersionDownloadRefType(_storage, _productId),
            downloadRefSource: getProductLatestVersionDownloadRefSource(_storage, _productId),
            checksum: getProductLatestVersionChecksum(_storage, _productId),
            createdAt: getProductLatestVersionCreatedAt(_storage, _productId)
        });
        
        return version;
    }

    function getProductVersionsLength(MarketplaceStorage _storage, uint _productId) internal view returns (uint) {
        return _storage.getUint(keccak256(abi.encodePacked("product.versions.length", _productId)));
    }

    function getProductVersionVersion(MarketplaceStorage _storage, uint _productId, string _version) internal view returns (string) {
        return _storage.getString(keccak256(abi.encodePacked("product.versions.version", _productId, _version)));
    }

    function getProductVersionDownloadRefType(MarketplaceStorage _storage, uint _productId, string _version) internal view returns (string) {
        return _storage.getString(keccak256(abi.encodePacked("product.versions.downloadRefType", _productId, _version)));
    }

    function getProductVersionDownloadRefSource(MarketplaceStorage _storage, uint _productId, string _version) internal view returns (string) {
        return _storage.getString(keccak256(abi.encodePacked("product.versions.downloadRefSource", _productId, _version)));
    }

    function getProductVersionChecksum(MarketplaceStorage _storage, uint _productId, string _version) internal view returns (string) {
        return _storage.getString(keccak256(abi.encodePacked("product.versions.checksum", _productId, _version)));
    }

    function getProductVersionCreatedAt(MarketplaceStorage _storage, uint _productId, string _version) internal view returns (uint) {
        return _storage.getUint(keccak256(abi.encodePacked("product.versions.createdAt", _productId, _version)));
    }

    function getProductVersion(MarketplaceStorage _storage, uint _productId, string _version) internal view returns (ProductVersion) {
        ProductVersion memory version = ProductVersion({
            version: getProductVersionVersion(_storage, _productId, _version),
            downloadRefType: getProductVersionDownloadRefType(_storage, _productId, _version),
            downloadRefSource: getProductVersionDownloadRefSource(_storage, _productId, _version),
            checksum: getProductVersionChecksum(_storage, _productId, _version),
            createdAt: getProductVersionCreatedAt(_storage, _productId, _version)
        });

        return version;
    }

    // Version Voting

    function getProductVersionVotingApprovalCount(MarketplaceStorage _storage, uint _productId, string _version) internal view returns (uint) {
        return _storage.getUint(keccak256(abi.encodePacked("product.versionVoting.approvalCount", _productId, _version)));
    }

    function getProductVersionVotingDisapprovalCount(MarketplaceStorage _storage, uint _productId, string _version) internal view returns (uint) {
        return _storage.getUint(keccak256(abi.encodePacked("product.versionVoting.disapprovalCount", _productId, _version)));
    }

    function getProductVersionVotingIsActive(MarketplaceStorage _storage, uint _productId, string _version) internal view returns (bool) {
        return _storage.getBool(keccak256(abi.encodePacked("product.versionVoting.isActive", _productId, _version)));
    }

    function getProductVersionVotingHasFailed(MarketplaceStorage _storage, uint _productId, string _version) internal view returns (bool) {
        return _storage.getBool(keccak256(abi.encodePacked("product.versionVoting.hasFailed", _productId, _version)));
    }

    function getProductVersionVotingHasVoted(MarketplaceStorage _storage, uint _productId, string _version, address _address) internal view returns (bool) {
        return _storage.getBool(keccak256(abi.encodePacked("product.versionVoting.voters", _productId, _version, _address)));
    }


    function getProductVersionVoting(MarketplaceStorage _storage, uint _productId, string _version) internal view returns (VersionVoting) {
        VersionVoting memory versionVoting = VersionVoting({
            approvalCount: getProductVersionVotingApprovalCount(_storage, _productId, _version),
            disapprovalCount: getProductVersionVotingDisapprovalCount(_storage, _productId, _version),
            isActive: getProductVersionVotingIsActive(_storage, _productId, _version),
            hasFailed: getProductVersionVotingHasFailed(_storage, _productId, _version)
        });

        return versionVoting;
    }

    // Purchasing

    function getProductHasPurchased(MarketplaceStorage _storage, uint _productId, address _address) internal view returns (uint) {
        return _storage.getUint(keccak256(abi.encodePacked("product.purchasers", _productId, _address)));
    }

    function getProductPurchaseOrdersLength(MarketplaceStorage _storage, uint _productId, address _purchaser) internal view returns (uint) {
        return _storage.getUint(keccak256(abi.encodePacked("product.purchaseOrders.length", _productId, _purchaser)));
    }

    function getProductPurchaseOrderProductId(MarketplaceStorage _storage, uint _productId, address _purchaser, uint _index) internal view returns (uint) {
        return _storage.getUint(keccak256(abi.encodePacked("product.purchaseOrders.productId", _productId, _purchaser, _index)));
    }

    function getProductPurchaseOrderPricePlanCode(MarketplaceStorage _storage, uint _productId, address _purchaser, uint _index) internal view returns (string) {
        return _storage.getString(keccak256(abi.encodePacked("product.purchaseOrders.pricePlanCode", _productId, _purchaser, _index)));
    }

    function getProductPurchaseOrderValue(MarketplaceStorage _storage, uint _productId, address _purchaser, uint _index) internal view returns (uint) {
        return _storage.getUint(keccak256(abi.encodePacked("product.purchaseOrders.value", _productId, _purchaser, _index)));
    }

    function getProductPurchaseOrderPurchaser(MarketplaceStorage _storage, uint _productId, address _purchaser, uint _index) internal view returns (address) {
        return _storage.getAddress(keccak256(abi.encodePacked("product.purchaseOrders.purchaser", _productId, _purchaser, _index)));
    }

    function getProductPurchaseOrderDeveloper(MarketplaceStorage _storage, uint _productId, address _purchaser, uint _index) internal view returns (address) {
        return _storage.getAddress(keccak256(abi.encodePacked("product.purchaseOrders.developer", _productId, _purchaser, _index)));
    }

    function getProductPurchaseOrder(MarketplaceStorage _storage, uint _productId, address _purchaser, uint _index) internal view returns (PurchaseOrder) {
        PurchaseOrder memory purchaseOrder = PurchaseOrder({
            productId: getProductPurchaseOrderProductId(_storage, _productId, _purchaser, _index),
            pricePlanCode: getProductPurchaseOrderPricePlanCode(_storage, _productId, _purchaser, _index),
            value: getProductPurchaseOrderValue(_storage, _productId, _purchaser, _index),
            purchaser: getProductPurchaseOrderPurchaser(_storage, _productId, _purchaser, _index),
            developer: getProductPurchaseOrderDeveloper(_storage, _productId, _purchaser, _index)
        });

        return purchaseOrder;
    }



    /**** Setters *******/

    function incrementNextProductId(MarketplaceStorage _storage) internal {
        uint currentId = _storage.getUint(keccak256("product.nextProductId"));
        _storage.setUint(keccak256("product.nextProductId"), currentId + 1);
    }

    function setProductTitle(MarketplaceStorage _storage, uint _productId, string _title) internal {
        _storage.setString(keccak256(abi.encodePacked("product.title", _productId)), _title);
    }

    function setProductType(MarketplaceStorage _storage, uint _productId, string _type) internal {
        _storage.setString(keccak256(abi.encodePacked("product.type", _productId)), _type);
    }

    function setProductStatus(MarketplaceStorage _storage, uint _productId, uint _status) internal {
        _storage.setUint(keccak256(abi.encodePacked("product.status", _productId)), _status);
    }

    function setProductContent(MarketplaceStorage _storage, uint _productId, string _content) internal {
        _storage.setString(keccak256(abi.encodePacked("product.content", _productId)), _content);
    }

    function setProductSystemTagsLength(MarketplaceStorage _storage, uint _productId, uint _length) internal {
        _storage.setUint(keccak256(abi.encodePacked("product.systemTags.length", _productId)), _length);
    }

    function setProductSystemTag(MarketplaceStorage _storage, uint _productId, uint _index, bytes32 _tag) internal {
        bytes memory bytesTag = _tag.toBytes();
        _storage.setBytes(keccak256(abi.encodePacked("product.systemTags", _productId, _index)), bytesTag);
    }

    function setProductAuthorTagsLength(MarketplaceStorage _storage, uint _productId, uint _length) internal {
        _storage.setUint(keccak256(abi.encodePacked("product.authorTags.length", _productId)), _length);
    }

    function setProductAuthorTag(MarketplaceStorage _storage, uint _productId, uint _index, bytes32 _tag) internal {
        bytes memory bytesTag = _tag.toBytes();
        _storage.setBytes(keccak256(abi.encodePacked("product.authorTags", _productId, _index)), bytesTag);
    }

    function setProductDeveloper(MarketplaceStorage _storage, uint _productId, address _developer) internal {
        _storage.setAddress(keccak256(abi.encodePacked("product.developer", _productId)), _developer);
    }

    function setProductDeveloperId(MarketplaceStorage _storage, uint _productId, uint _developerId) internal {
        _storage.setUint(keccak256(abi.encodePacked("product.developerId", _productId)), _developerId);
    }

    // Price Plan

    function setProductPricePlanCode(MarketplaceStorage _storage, uint _productId, string _code) internal {
        _storage.setString(keccak256(abi.encodePacked("product.pricePlans.code", _productId, _code)), _code);
    }

    function setProductPricePlanName(MarketplaceStorage _storage, uint _productId, string _code, string _name) internal {
        _storage.setString(keccak256(abi.encodePacked("product.pricePlans.name", _productId, _code)), _name);
    }

    function setProductPricePlanPrice(MarketplaceStorage _storage, uint _productId, string _code, uint _price) internal {
        _storage.setUint(keccak256(abi.encodePacked("product.pricePlans.price", _productId, _code)), _price);
    }

    function setProductPricePlan(MarketplaceStorage _storage, uint _productId, string _code, string _name, uint _price) internal {
        setProductPricePlanCode(_storage, _productId, _code);
        setProductPricePlanName(_storage, _productId, _code, _name);
        setProductPricePlanPrice(_storage, _productId, _code, _price);
    }

    // System Requirement

    function setProductSystemRequirementsLength(MarketplaceStorage _storage, uint _productId, uint _length) internal {
        _storage.setUint(keccak256(abi.encodePacked("product.systemRequirements.length", _productId)), _length);
    }

    function setProductSystemRequirementSystem(MarketplaceStorage _storage, uint _productId, uint _index, string _system) internal {
        _storage.setString(keccak256(abi.encodePacked("product.systemRequirements.system", _productId, _index)), _system);
    }

    function setProductSystemRequirementInfo(MarketplaceStorage _storage, uint _productId, uint _index, string _info) internal {
        _storage.setString(keccak256(abi.encodePacked("product.systemRequirements.info", _productId, _index)), _info);
    }

    function setProductSystemRequirement(MarketplaceStorage _storage, uint _productId, uint _index, string _system, string _info) internal {
        setProductSystemRequirementSystem(_storage, _productId, _index, _system);
        setProductSystemRequirementInfo(_storage, _productId, _index, _info);
    }

    function pushProductSystemRequirement(MarketplaceStorage _storage, uint _productId, string _system, string _info) internal {
        uint nextIndex = getProductSystemRequirementsLength(_storage, _productId);

        setProductSystemRequirement(_storage, _productId, nextIndex, _system, _info);

        setProductSystemRequirementsLength(_storage, _productId, nextIndex + 1);
    }

    // Language Support

    function setProductLanguagesSupportedLength(MarketplaceStorage _storage, uint _productId, uint _length) internal {
        _storage.setUint(keccak256(abi.encodePacked("product.languagesSupported.length", _productId)), _length);
    }

    function setProductLanguageSupportLanguage(MarketplaceStorage _storage, uint _productId, uint _index, string _language) internal {
        _storage.setString(keccak256(abi.encodePacked("product.languagesSupported.language", _productId, _index)), _language);
    }

    function setProductLanguageSupportClosedCaptioning(MarketplaceStorage _storage, uint _productId, uint _index, bool _closedCaptioning) internal {
        _storage.setBool(keccak256(abi.encodePacked("product.languagesSupported.closedCaptioning", _productId, _index)), _closedCaptioning);
    }

    function setProductLanguageSupportAudioDescription(MarketplaceStorage _storage, uint _productId, uint _index, bool _audioDescription) internal {
        _storage.setBool(keccak256(abi.encodePacked("product.languagesSupported.audioDescription", _productId, _index)), _audioDescription);
    }

    function setProductLanguageSupport(MarketplaceStorage _storage, uint _productId, uint _index, string _language, bool _closedCaptioning, bool _audioDescription) internal {
        setProductLanguageSupportLanguage(_storage, _productId, _index, _language);
        setProductLanguageSupportClosedCaptioning(_storage, _productId, _index, _closedCaptioning);
        setProductLanguageSupportAudioDescription(_storage, _productId, _index, _audioDescription);
    }

    function pushProductLanguageSupport(MarketplaceStorage _storage, uint _productId, string _language, bool _closedCaptioning, bool _audioDescription) internal {
        uint nextIndex = getProductLanguagesSupportedLength(_storage, _productId);

        setProductLanguageSupport(_storage, _productId, nextIndex, _language, _closedCaptioning, _audioDescription);

        setProductLanguagesSupportedLength(_storage, _productId, nextIndex + 1);
    }

    // Version

    function setProductLatestVersionVersion(MarketplaceStorage _storage, uint _productId, string _version) internal {
        _storage.setString(keccak256(abi.encodePacked("product.latestVersion.version", _productId)), _version);
    }

    function setProductLatestVersionDownloadRefType(MarketplaceStorage _storage, uint _productId, string _downloadRefType) internal {
        _storage.setString(keccak256(abi.encodePacked("product.latestVersion.downloadRefType", _productId)), _downloadRefType);
    }

    function setProductLatestVersionDownloadRefSource(MarketplaceStorage _storage, uint _productId, string _downloadRefSource) internal {
        _storage.setString(keccak256(abi.encodePacked("product.latestVersion.downloadRefSource", _productId)), _downloadRefSource);
    }

    function setProductLatestVersionChecksum(MarketplaceStorage _storage, uint _productId, string _checksum) internal {
        _storage.setString(keccak256(abi.encodePacked("product.latestVersion.checksum", _productId)), _checksum);
    }

    function setProductLatestVersionCreatedAt(MarketplaceStorage _storage, uint _productId, uint _createdAt) internal {
        _storage.setUint(keccak256(abi.encodePacked("product.latestVersion.createdAt", _productId)), _createdAt);
    }

    function setProductLatestVersion(MarketplaceStorage _storage, uint _productId, string _version, string _downloadRefType, string _downloadRefSource, string _checksum, uint _createdAt) internal {
        setProductLatestVersionVersion(_storage, _productId, _version);
        setProductLatestVersionDownloadRefType(_storage, _productId, _downloadRefType);
        setProductLatestVersionDownloadRefSource(_storage, _productId, _downloadRefSource);
        setProductLatestVersionChecksum(_storage, _productId, _checksum);
        setProductLatestVersionCreatedAt(_storage, _productId, _createdAt);
    }

    function setProductVersionsLength(MarketplaceStorage _storage, uint _productId, uint _length) internal {
        _storage.setUint(keccak256(abi.encodePacked("product.versions.length", _productId)), _length);
    }

    function setProductVersionVersion(MarketplaceStorage _storage, uint _productId, string _version) internal {
        _storage.setString(keccak256(abi.encodePacked("product.versions.version", _productId, _version)), _version);
    }

    function setProductVersionDownloadRefType(MarketplaceStorage _storage, uint _productId, string _version, string _downloadRefType) internal {
        _storage.setString(keccak256(abi.encodePacked("product.versions.downloadRefType", _productId, _version)), _downloadRefType);
    }

    function setProductVersionDownloadRefSource(MarketplaceStorage _storage, uint _productId, string _version, string _downloadRefSource) internal {
        _storage.setString(keccak256(abi.encodePacked("product.versions.downloadRefSource", _productId, _version)), _downloadRefSource);
    }

    function setProductVersionChecksum(MarketplaceStorage _storage, uint _productId, string _version, string _checksum) internal {
        _storage.setString(keccak256(abi.encodePacked("product.versions.checksum", _productId, _version)), _checksum);
    }

    function setProductVersionCreatedAt(MarketplaceStorage _storage, uint _productId, string _version, uint _createdAt) internal {
        _storage.setUint(keccak256(abi.encodePacked("product.versions.createdAt", _productId, _version)), _createdAt);
    }

    function setProductVersion(MarketplaceStorage _storage, uint _productId, string _version, string _downloadRefType, string _downloadRefSource, string _checksum, uint _createdAt) internal {
        setProductVersionVersion(_storage, _productId, _version);
        setProductVersionDownloadRefType(_storage, _productId, _version, _downloadRefType);
        setProductVersionDownloadRefSource(_storage, _productId, _version, _downloadRefSource);
        setProductVersionChecksum(_storage, _productId, _version, _checksum);
        setProductVersionCreatedAt(_storage, _productId, _version, _createdAt);
    }

    // Version Voting

    function setProductVersionVotingApprovalCount(MarketplaceStorage _storage, uint _productId, string _version, uint _count) internal {
        _storage.setUint(keccak256(abi.encodePacked("product.versionVoting.approvalCount", _productId, _version)), _count);
    }

    function setProductVersionVotingDisapprovalCount(MarketplaceStorage _storage, uint _productId, string _version, uint _count) internal {
        _storage.setUint(keccak256(abi.encodePacked("product.versionVoting.disapprovalCount", _productId, _version)), _count);
    }

    function setProductVersionVotingIsActive(MarketplaceStorage _storage, uint _productId, string _version, bool _isActive) internal {
        _storage.setBool(keccak256(abi.encodePacked("product.versionVoting.isActive", _productId, _version)), _isActive);
    }

    function setProductVersionVotingHasFailed(MarketplaceStorage _storage, uint _productId, string _version, bool _hasFailed) internal {
        _storage.setBool(keccak256(abi.encodePacked("product.versionVoting.hasFailed", _productId, _version)), _hasFailed);
    }

    function setProductVersionVotingHasVoted(MarketplaceStorage _storage, uint _productId, string _version, address _address, bool _hasVoted) internal {
        _storage.setBool(keccak256(abi.encodePacked("product.versionVoting.voters", _productId, _version, _address)), _hasVoted);
    }

    function setProductVersionVoting(MarketplaceStorage _storage, uint _productId, string _version, uint _approvalCount, uint _disapprovalCount, bool _isActive, bool _hasFailed) internal {
        setProductVersionVotingApprovalCount(_storage, _productId, _version, _approvalCount);
        setProductVersionVotingDisapprovalCount(_storage, _productId, _version, _disapprovalCount);
        setProductVersionVotingIsActive(_storage, _productId, _version, _isActive);
        setProductVersionVotingHasFailed(_storage, _productId, _version, _hasFailed);
    }

    // Purchasing

    function setProductHasPurchased(MarketplaceStorage _storage, uint _productId, address _address, uint _val) internal {
        _storage.setUint(keccak256(abi.encodePacked("product.purchasers", _productId, _address)), _val);
    }

    function setProductPurchaseOrdersLength(MarketplaceStorage _storage, uint _productId, address _purchaser, uint _length) internal {
        _storage.setUint(keccak256(abi.encodePacked("product.purchaseOrders.length", _productId, _purchaser)), _length);
    }

    function setProductPurchaseOrderProductId(MarketplaceStorage _storage, uint _productId, address _purchaser, uint _index) internal {
        _storage.setUint(keccak256(abi.encodePacked("product.purchaseOrders.productId", _productId, _purchaser, _index)), _productId);
    }

    function setProductPurchaseOrderPricePlanCode(MarketplaceStorage _storage, uint _productId, address _purchaser, uint _index, string _code) internal {
        _storage.setString(keccak256(abi.encodePacked("product.purchaseOrders.pricePlanCode", _productId, _purchaser, _index)), _code);
    }

    function setProductPurchaseOrderValue(MarketplaceStorage _storage, uint _productId, address _purchaser, uint _index, uint _value) internal {
        _storage.setUint(keccak256(abi.encodePacked("product.purchaseOrders.value", _productId, _purchaser, _index)), _value);
    }

    function setProductPurchaseOrderPurchaser(MarketplaceStorage _storage, uint _productId, address _purchaser, uint _index) internal {
        _storage.setAddress(keccak256(abi.encodePacked("product.purchaseOrders.purchaser", _productId, _purchaser, _index)), _purchaser);
    }

    function setProductPurchaseOrderDeveloper(MarketplaceStorage _storage, uint _productId, address _purchaser, uint _index, address _developer) internal {
        _storage.setAddress(keccak256(abi.encodePacked("product.purchaseOrders.developer", _productId, _purchaser, _index)), _developer);
    }

    function setProductPurchaseOrder(MarketplaceStorage _storage, uint _productId, address _purchaser, uint _index, string _pricePlanCode, uint _value, address _developer) internal {
        setProductPurchaseOrderProductId(_storage, _productId, _purchaser, _index);
        setProductPurchaseOrderPricePlanCode(_storage, _productId, _purchaser, _index, _pricePlanCode);
        setProductPurchaseOrderValue(_storage, _productId, _purchaser, _index, _value);
        setProductPurchaseOrderPurchaser(_storage, _productId, _purchaser, _index);
        setProductPurchaseOrderDeveloper(_storage, _productId, _purchaser, _index, _developer);
    }

    function pushProductPurchaseOrder(MarketplaceStorage _storage, uint _productId, address _purchaser, string _pricePlanCode, uint _value, address _developer) internal {
        uint nextIndex = getProductPurchaseOrdersLength(_storage, _productId, _purchaser);

        setProductPurchaseOrder(_storage, _productId, _purchaser, nextIndex, _pricePlanCode, _value, _developer);

        setProductPurchaseOrdersLength(_storage, _productId, _purchaser, nextIndex + 1);
    }
}
