pragma solidity ^0.4.24;

import "./storage/ProjectStorageAccess.sol";
import "./storage/ContributionStorageAccess.sol";

library ProjectContributionTierHelpersLibrary {

    using ProjectStorageAccess for FundingStorage;
    using ContributionStorageAccess for FundingStorage;

    function movePendingContributionTiersIntoActiveContributionTiers(FundingStorage _fundingStorage, uint _projectId) external {
        uint length = _fundingStorage.getPendingContributionTiersLength(_projectId);

        for (uint i = 0; i < length; i++) {
            ProjectStorageAccess.ContributionTier memory tier = _fundingStorage.getPendingContributionTier(_projectId, i);

            _fundingStorage.setContributionTier(_projectId, i, tier.contributorLimit, tier.minContribution, tier.maxContribution, tier.rewards);
        }

        _fundingStorage.setContributionTiersLength(_projectId, length);
        _fundingStorage.setPendingContributionTiersLength(_projectId, 0);
    }
}
