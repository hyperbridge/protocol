pragma solidity ^0.4.24;

import "./ProductBase.sol";
import "../libraries/storage/AdministrationStorageAccess.sol";

contract ProductVersionVoting is ProductBase {

    using AdministrationStorageAccess for MarketplaceStorage;

    modifier onlyAdministrator() {
        require(marketplaceStorage.getIsAdmin(msg.sender));
        _;
    }

    modifier onlyActiveVersionVoting(uint _productId, string _version) {
        // Voting must be active for this version
        require(marketplaceStorage.getProductVersionVotingIsActive(_productId, _version));
        _;
    }

    constructor(address _marketplaceStorage) public {
        marketplaceStorage = MarketplaceStorage(_marketplaceStorage);
    }

    function voteOnVersion(uint _productId, string _version, bool _vote) external onlyAdministrator onlyActiveVersionVoting(_productId, _version) {
        // Check that voter has not already voted
        require(!marketplaceStorage.getProductVersionVotingHasVoted(_productId, _version, msg.sender));

        if (_vote) {
            uint currentApprovalCount = marketplaceStorage.getProductVersionVotingApprovalCount(_productId, _version);
            marketplaceStorage.setProductVersionVotingApprovalCount(_productId, _version, currentApprovalCount + 1);
        } else {
            uint currentDisapprovalCount = marketplaceStorage.getProductVersionVotingDisapprovalCount(_productId, _version);
            marketplaceStorage.setProductVersionVotingDisapprovalCount(_productId, _version, currentDisapprovalCount + 1);
        }

        marketplaceStorage.setProductVersionVotingHasVoted(_productId, _version, msg.sender, true);
    }

    function finalizeVersionVoting(uint _productId, string _version) external onlyProductDeveloper(_productId) onlyActiveVersionVoting(_productId, _version) {
        uint approvalCount = marketplaceStorage.getProductVersionVotingApprovalCount(_productId, _version);
        uint disapprovalCount = marketplaceStorage.getProductVersionVotingDisapprovalCount(_productId, _version);
        uint numVoters = approvalCount + disapprovalCount;

        uint votingThreshold;

        numVoters == 1 ? votingThreshold = 1 : votingThreshold = numVoters / 2;

        if (approvalCount >= votingThreshold) {
            ProductStorageAccess.ProductVersion memory newLatestVersion = marketplaceStorage.getProductVersion(_productId, _version);

            marketplaceStorage.setProductLatestVersion(_productId, newLatestVersion.version, newLatestVersion.downloadRefType, newLatestVersion.downloadRefSource, newLatestVersion.checksum, newLatestVersion.createdAt);
        } else {
            marketplaceStorage.setProductVersionVotingHasFailed(_productId, _version, true);
        }

        marketplaceStorage.setProductVersionVotingIsActive(_productId, _version, false);
    }

    function getVersionVoting(uint _productId, string _version) external view returns (uint approvalCount, uint disapprovalCount, bool isActive, bool hasFailed) {
        ProductStorageAccess.VersionVoting memory version = marketplaceStorage.getProductVersionVoting(_productId, _version);

        return (version.approvalCount, version.disapprovalCount, version.isActive, version.hasFailed);
    }
}
