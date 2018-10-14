pragma solidity ^0.4.24;

import "../FundingStorage.sol";
import "./ProjectBase.sol";

contract ProjectContributionTier is ProjectBase {

    constructor(address _fundingStorage, bool _inTest) public Testable(_inTest) {
        fundingStorage = FundingStorage(_fundingStorage);
    }

    function () public payable {
        revert();
    }

    function addContributionTier(
        uint _projectId,
        uint _contributorLimit,
        uint _maxContribution,
        uint _minContribution,
        string _rewards
    )
        external
        onlyProjectDeveloper(_projectId)
        onlyDraftProject(_projectId)
    {
        fundingStorage.pushPendingContributionTier(_projectId, _contributorLimit, _maxContribution, _minContribution, _rewards);
    }

    function editContributionTier(
        uint _projectId,
        uint _index,
        uint _contributorLimit,
        uint _maxContribution,
        uint _minContribution,
        string _rewards
    )
        external
        onlyProjectDeveloper(_projectId)
        onlyDraftProject(_projectId)
    {
        fundingStorage.setPendingContributionTier(_projectId, _index, _contributorLimit, _maxContribution, _minContribution, _rewards);
    }

    function clearPendingContributionTiers(uint _projectId) external onlyProjectDeveloper(_projectId) onlyDraftProject(_projectId) {
        fundingStorage.setPendingContributionTiersLength(_projectId, 0);
    }

    function getPendingContributionTiersLength(uint _projectId) external view returns (uint length) {
        length = fundingStorage.getPendingContributionTiersLength(_projectId);
        return length;
    }

    function getPendingContributionTier(uint _projectId, uint _index) external view returns (uint contributorLimit, uint maxContribution, uint minContribution, string rewards) {
        ProjectStorageAccess.ContributionTier memory tier = fundingStorage.getPendingContributionTier(_projectId, _index);

        return (tier.contributorLimit, tier.maxContribution, tier.minContribution, tier.rewards);
    }

    function getContributionTiersLength(uint _projectId) external view returns (uint length) {
        length = fundingStorage.getContributionTiersLength(_projectId);
        return length;
    }

    function getContributionTier(uint _projectId, uint _index) external view returns (uint contributorLimit, uint maxContribution, uint minContribution, string rewards) {
        ProjectStorageAccess.ContributionTier memory tier = fundingStorage.getContributionTier(_projectId, _index);

        return (tier.contributorLimit, tier.maxContribution, tier.minContribution, tier.rewards);
    }
}
