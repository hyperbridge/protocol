pragma solidity ^0.4.24;

import "../FundingStorage.sol";
import "./ProjectBase.sol";
import "../libraries/ProjectTimelineHelpersLibrary.sol";

contract ProjectTimeline is ProjectBase {

    using ProjectTimelineHelpersLibrary for FundingStorage;

    constructor(address _fundingStorage, bool _inTest) public Testable(_inTest) {
        fundingStorage = FundingStorage(_fundingStorage);
    }

    function () public payable {
        revert();
    }

    function addMilestone(
        uint _projectId,
        string _title,
        string _description,
        uint _percentage
    )
        external
        onlyProjectDeveloper(_projectId)
    {
        require(_percentage <= 100, "Milestone percentage cannot be greater than 100.");
        require(!fundingStorage.getProjectNoTimeline(_projectId), "Cannot add a milestone to a project with no timeline.");
        require(!fundingStorage.getTimelineProposalIsActive(_projectId), "Pending milestones cannot be added while a timeline proposal vote is active.");

        fundingStorage.pushPendingTimelineMilestone(_projectId, _title, _description, _percentage, false);
    }

    function editMilestone(
        uint _projectId,
        uint _index,
        string _title,
        string _description,
        uint _percentage
    )
        external
        onlyProjectDeveloper(_projectId)
    {
        require(_percentage <= 100, "Milestone percentage cannot be greater than 100.");
        require(!fundingStorage.getTimelineProposalIsActive(_projectId), "Pending milestones cannot be edited while a timeline proposal vote is active.");
        require(!fundingStorage.getPendingTimelineMilestoneIsComplete(_projectId, _index), "Cannot edit a completed milestone.");

        fundingStorage.setPendingTimelineMilestone(_projectId, _index, _title, _description, _percentage, false);
    }

    function getPendingTimelineLength(uint _projectId) external view returns (uint length) {
        length = fundingStorage.getPendingTimelineLength(_projectId);
        return length;
    }

    function getPendingTimelineMilestone(uint _projectId, uint _index) external view returns (string title, string description, uint percentage, bool isComplete) {
        ProjectStorageAccess.Milestone memory milestone = fundingStorage.getPendingTimelineMilestone(_projectId, _index);

        return (milestone.title, milestone.description, milestone.percentage, milestone.isComplete);
    }

    function getTimelineLength(uint _projectId) external view returns (uint length) {
        length = fundingStorage.getTimelineLength(_projectId);
        return length;
    }

    function getTimelineMilestone(uint _projectId, uint _index) external view returns (string title, string description, uint percentage, bool isComplete) {
        ProjectStorageAccess.Milestone memory milestone = fundingStorage.getTimelineMilestone(_projectId, _index);

        return (milestone.title, milestone.description, milestone.percentage, milestone.isComplete);
    }

    function getTimelineHistoryLength(uint _projectId) external view returns (uint length) {
        length = fundingStorage.getTimelineHistoryLength(_projectId);
        return length;
    }

    function getTimelineHistoryLength(uint _projectId, uint _historyIndex) external view returns (uint length) {
        length = fundingStorage.getTimelineHistoryMilestonesLength(_projectId, _historyIndex);
        return length;
    }

    function getTimelineHistoryMilestone(uint _projectId, uint _timelineIndex, uint _milestoneIndex) external view returns (string title, string description, uint percentage, bool isComplete) {
        ProjectStorageAccess.Milestone memory milestone = fundingStorage.getTimelineHistoryMilestone(_projectId, _timelineIndex, _milestoneIndex);

        return (milestone.title, milestone.description, milestone.percentage, milestone.isComplete);
    }

    function clearPendingTimeline(uint _projectId) external onlyProjectDeveloper(_projectId) {
        // There must not be an active timeline proposal
        require(!fundingStorage.getTimelineProposalIsActive(_projectId), "A timeline proposal vote is active.");

        fundingStorage.setPendingTimelineLength(_projectId, 0);

        if (status == Status.InDevelopment) {

            fundingStorage.moveCompletedMilestonesIntoPendingTimeline(_projectId);

            Status status = Status(fundingStorage.getProjectStatus(_projectId));

            uint activeMilestoneIndex = fundingStorage.getActiveMilestoneIndex(_projectId);

            ProjectStorageAccess.Milestone memory activeMilestone = fundingStorage.getTimelineMilestone(_projectId, activeMilestoneIndex);

            fundingStorage.pushPendingTimelineMilestone(_projectId, activeMilestone.title, activeMilestone.description, activeMilestone.percentage, activeMilestone.isComplete);
        }
    }
}
