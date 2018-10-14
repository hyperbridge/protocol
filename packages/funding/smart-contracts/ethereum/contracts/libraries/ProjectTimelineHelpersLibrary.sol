pragma solidity ^0.4.24;

import "./storage/ProjectStorageAccess.sol";
import "../FundingVault.sol";
import "../FundingStorage.sol";
import "../openzeppelin/SafeMath.sol";

library ProjectTimelineHelpersLibrary {

    using SafeMath for uint256;
    using ProjectStorageAccess for FundingStorage;

    function moveTimelineIntoTimelineHistory(FundingStorage _fundingStorage, uint _projectId) external {
        uint historyLength = _fundingStorage.getTimelineHistoryLength(_projectId);
        uint timelineLength = _fundingStorage.getTimelineLength(_projectId);

        for (uint i = 0; i < timelineLength; i++) {
            ProjectStorageAccess.Milestone memory milestone = _fundingStorage.getTimelineMilestone(_projectId, i);
            _fundingStorage.setTimelineHistoryMilestone(_projectId, historyLength, i, milestone.title, milestone.description, milestone.percentage, milestone.isComplete);
        }

        _fundingStorage.setTimelineHistoryLength(_projectId, historyLength.add(1));
        _fundingStorage.setTimelineHistoryMilestonesLength(_projectId, historyLength, timelineLength);
        _fundingStorage.setTimelineLength(_projectId, 0);
    }

    function movePendingMilestonesIntoTimeline(FundingStorage _fundingStorage, uint _projectId) external {
        uint pendingTimelineLength = _fundingStorage.getPendingTimelineLength(_projectId);

        for (uint j = 0; j < pendingTimelineLength; j++) {
            ProjectStorageAccess.Milestone memory pendingMilestone = _fundingStorage.getPendingTimelineMilestone(_projectId, j);
            _fundingStorage.setTimelineMilestone(_projectId, j, pendingMilestone.title, pendingMilestone.description, pendingMilestone.percentage, pendingMilestone.isComplete);
        }

        _fundingStorage.setTimelineLength(_projectId, pendingTimelineLength);
        _fundingStorage.setPendingTimelineLength(_projectId, 0);
    }

    function moveCompletedMilestonesIntoPendingTimeline(FundingStorage _fundingStorage, uint _projectId) external {
        uint completedMilestonesLength = _fundingStorage.getCompletedMilestonesLength(_projectId);

        // Add the completed milestones to the start of the pending timeline
        for (uint i = 0; i < completedMilestonesLength; i++) {
            ProjectStorageAccess.Milestone memory completedMilestone = _fundingStorage.getCompletedMilestone(_projectId, i);
            _fundingStorage.setPendingTimelineMilestone(_projectId, i, completedMilestone.title, completedMilestone.description, completedMilestone.percentage, completedMilestone.isComplete);
        }

        _fundingStorage.setPendingTimelineLength(_projectId, completedMilestonesLength);
    }

    function verifyPendingMilestones(FundingStorage _fundingStorage, uint _projectId) external view {
        // Verify:
        // - Milestones are present
        // - Milestone percentages add up to 100

        uint timelineLength = _fundingStorage.getPendingTimelineLength(_projectId);

        require(timelineLength > 0, "Project has no pending milestones.");

        uint percentageAcc = 0;
        for (uint i = 0; i < timelineLength; i++) {
            uint percentage = _fundingStorage.getPendingTimelineMilestonePercentage(_projectId, i);
            percentageAcc = percentageAcc.add(percentage);
        }

        require(percentageAcc == 100, "Milestone percentages must add to 100.");
    }
}
