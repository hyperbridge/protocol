pragma solidity ^0.4.24;

import "../../FundingStorage.sol";
import "../../openzeppelin/SafeMath.sol";

library ProjectStorageAccess {

    using SafeMath for uint256;

    struct Timeline {
        Milestone[] milestones;
    }

    struct Milestone {
        string title;
        string description;
        uint percentage;
        bool isComplete;
    }

    struct ContributionTier {
        uint contributorLimit;
        uint minContribution;
        uint maxContribution;
        string rewards;
    }

    struct TimelineProposal {
        uint timestamp;
        uint approvalCount;
        uint disapprovalCount;
        bool isActive;
        bool hasFailed;
        mapping(address => bool) voters;
    }

    struct MilestoneCompletionSubmission {
        uint timestamp;
        uint approvalCount;
        uint disapprovalCount;
        string report;
        bool isActive;
        bool hasFailed;
        mapping(address => bool) voters;
    }

    /*
        Each project stores the following data in FundingStorage and accesses it through the associated namespace:
            uint id                                                         (project.id)
            Status status                                                   (project.status)
            string title                                                    (project.title)
            string description                                              (project.description)
            string about                                                    (project.about)
            address developer                                               (project.developer)
            uint developerId                                                (project.developerId)
            uint minContributionGoal                                        (project.minContributionGoal)
            uint maxContributionGoal                                        (project.maxContributionGoal)
            uint contributionPeriod                                         (project.contributionPeriod)
            bool noRefunds                                                  (project.noRefunds)
            bool noTimeline                                                 (project.noTimeline)
            ContributionTier[] contributionTiers
                uint contributorLimit                                       (project.contributionTiers.contributorLimit)
                uint minContribution                                        (project.contributionTiers.minContribution)
                uint maxContribution                                        (project.contributionTiers.maxContribution)
                uint rewards                                                (project.contributionTiers.rewards)
            ContributionTier[] pendingContributionTiers
                uint contributorLimit                                       (project.pendingContributionTiers.contributorLimit)
                uint minContribution                                        (project.pendingContributionTiers.minContribution)
                uint maxContribution                                        (project.pendingContributionTiers.maxContribution)
                string rewards                                              (project.pendingContributionTiers.rewards)
            Timeline timeline
                Milestone[] milestones
                    Milestone
                        string title                                        (project.timeline.milestones.title)
                        string description                                  (project.timeline.milestones.description)
                        uint percentage                                     (project.timeline.milestones.percentage)
                        bool isComplete                                     (project.timeline.milestones.isComplete)
            uint activeMilestoneIndex                                       (project.activeMilestoneIndex)
            Timeline pendingTimeline
                Milestone[] milestones
                    Milestone
                        string title                                        (project.pendingTimeline.milestones.title)
                        string description                                  (project.pendingTimeline.milestones.description)
                        uint percentage                                     (project.pendingTimeline.milestones.percentage)
                        bool isComplete                                     (project.pendingTimeline.milestones.isComplete)
            Milestone[] completedMilestones
                Milestone
                    string title                                            (project.completedMilestones.title)
                    string description                                      (project.completedMilestones.description)
                    uint percentage                                         (project.completedMilestones.percentage)
                    bool isComplete                                         (project.completedMilestones.isComplete)
            Timeline[] timelineHistory
                Timeline
                    Milestone[]
                        Milestone
                            string title                                    (project.timelineHistory.milestones.title)
                            string description                              (project.timelineHistory.milestones.description)
                            uint percentage                                 (project.timelineHistory.milestones.percentage)
                            bool isComplete                                 (project.timelineHistory.milestones.isComplete)
            TimelineProposal timelineProposal
                uint timestamp                                              (project.timelineProposal.timestamp)
                uint approvalCount                                          (project.timelineProposal.approvalCount)
                uint disapprovalCount                                       (project.timelineProposal.disapprovalCount)
                bool isActive                                               (project.timelineProposal.isActive)
                bool hasFailed                                              (project.timelineProposal.hasFailed)
                mapping(address => bool) voters                             (project.timelineProposal.voters)
            MilestoneCompletionSubmission milestoneCompletionSubmission
                uint timestamp                                              (project.milestoneCompletionSubmission.timestamp)
                uint approvalCount                                          (project.milestoneCompletionSubmission.approvalCount)
                uint disapprovalCount                                       (project.milestoneCompletionSubmission.disapprovalCount)
                string report                                               (project.milestoneCompletionSubmission.report)
                bool isActive                                               (project.milestoneCompletionSubmission.isActive)
                bool hasFailed                                              (project.milestoneCompletionSubmission.hasFailed)
                mapping(address => bool) voters                             (project.milestoneCompletionSubmission.voters)
    */

    // Getters

    function generateNewProjectId(FundingStorage _fundingStorage) internal returns (uint) {
        uint id = getNextProjectId(_fundingStorage);
        incrementNextProjectId(_fundingStorage);
        return id;
    }

    function getNextProjectId(FundingStorage _fundingStorage) internal view returns (uint) {
        return _fundingStorage.getUint(keccak256("project.nextId"));
    }

    function getProjectStatus(FundingStorage _fundingStorage, uint _projectId) internal view returns (uint) {
        return _fundingStorage.getUint(keccak256(abi.encodePacked("project.status", _projectId)));
    }

    function getProjectTitle(FundingStorage _fundingStorage, uint _projectId) internal view returns (string) {
        return _fundingStorage.getString(keccak256(abi.encodePacked("project.title", _projectId)));
    }

    function getProjectDescription(FundingStorage _fundingStorage, uint _projectId) internal view returns (string) {
        return _fundingStorage.getString(keccak256(abi.encodePacked("project.description", _projectId)));
    }

    function getProjectAbout(FundingStorage _fundingStorage, uint _projectId) internal view returns (string) {
        return _fundingStorage.getString(keccak256(abi.encodePacked("project.about", _projectId)));
    }

    function getProjectDeveloper(FundingStorage _fundingStorage, uint _projectId) internal view returns (address) {
        return _fundingStorage.getAddress(keccak256(abi.encodePacked("project.developer", _projectId)));
    }

    function getProjectDeveloperId(FundingStorage _fundingStorage, uint _projectId) internal view returns (uint) {
        return _fundingStorage.getUint(keccak256(abi.encodePacked("project.developerId", _projectId)));
    }

    function getProjectMinContributionGoal(FundingStorage _fundingStorage, uint _projectId) internal view returns (uint) {
        return _fundingStorage.getUint(keccak256(abi.encodePacked("project.minContributionGoal", _projectId)));
    }

    function getProjectMaxContributionGoal(FundingStorage _fundingStorage, uint _projectId) internal view returns (uint) {
        return _fundingStorage.getUint(keccak256(abi.encodePacked("project.maxContributionGoal", _projectId)));
    }

    function getProjectContributionPeriod(FundingStorage _fundingStorage, uint _projectId) internal view returns (uint) {
        return _fundingStorage.getUint(keccak256(abi.encodePacked("project.contributionPeriod", _projectId)));
    }

    function getProjectNoRefunds(FundingStorage _fundingStorage, uint _projectId) internal view returns (bool) {
        return _fundingStorage.getBool(keccak256(abi.encodePacked("project.noRefunds", _projectId)));
    }

    function getProjectNoTimeline(FundingStorage _fundingStorage, uint _projectId) internal view returns (bool) {
        return _fundingStorage.getBool(keccak256(abi.encodePacked("project.noTimeline", _projectId)));
    }

    function getActiveMilestoneIndex(FundingStorage _fundingStorage, uint _projectId) internal view returns (uint) {
        return _fundingStorage.getUint(keccak256(abi.encodePacked("project.activeMilestoneIndex", _projectId)));
    }

    // Timeline

    function getTimelineLength(FundingStorage _fundingStorage, uint _projectId) internal view returns (uint) {
        return _fundingStorage.getUint(keccak256(abi.encodePacked("project.timeline.length", _projectId)));
    }

    function getPendingTimelineLength(FundingStorage _fundingStorage, uint _projectId) internal view returns (uint) {
        return _fundingStorage.getUint(keccak256(abi.encodePacked("project.pendingTimeline.length", _projectId)));
    }

    function getTimelineHistoryLength(FundingStorage _fundingStorage, uint _projectId) internal view returns (uint) {
        return _fundingStorage.getUint(keccak256(abi.encodePacked("project.timelineHistory.length", _projectId)));
    }

    // Milestone

    function getTimelineMilestoneTitle(FundingStorage _fundingStorage, uint _projectId, uint _index) internal view returns (string) {
        require(_index < _fundingStorage.getUint(keccak256(abi.encodePacked("project.timeline.length", _projectId))), "Index is outside of accessible range.");

        return _fundingStorage.getString(keccak256(abi.encodePacked("project.timeline.milestones.title", _index, _projectId)));
    }

    function getTimelineMilestoneDescription(FundingStorage _fundingStorage, uint _projectId, uint _index) internal view returns (string) {
        require(_index < _fundingStorage.getUint(keccak256(abi.encodePacked("project.timeline.length", _projectId))), "Index is outside of accessible range.");

        return _fundingStorage.getString(keccak256(abi.encodePacked("project.timeline.milestones.description", _index, _projectId)));
    }

    function getTimelineMilestonePercentage(FundingStorage _fundingStorage, uint _projectId, uint _index) internal view returns (uint) {
        require(_index < _fundingStorage.getUint(keccak256(abi.encodePacked("project.timeline.length", _projectId))), "Index is outside of accessible range.");

        return _fundingStorage.getUint(keccak256(abi.encodePacked("project.timeline.milestones.percentage", _index, _projectId)));
    }

    function getTimelineMilestoneIsComplete(FundingStorage _fundingStorage, uint _projectId, uint _index) internal view returns (bool) {
        require(_index < _fundingStorage.getUint(keccak256(abi.encodePacked("project.timeline.length", _projectId))), "Index is outside of accessible range.");

        return _fundingStorage.getBool(keccak256(abi.encodePacked("project.timeline.milestones.isComplete", _index, _projectId)));
    }

    function getTimelineMilestone(FundingStorage _fundingStorage, uint _projectId, uint _index) internal view returns (Milestone) {
        require(_index < _fundingStorage.getUint(keccak256(abi.encodePacked("project.timeline.length", _projectId))), "Index is outside of accessible range.");

        string memory title = _fundingStorage.getString(keccak256(abi.encodePacked("project.timeline.milestones.title", _index, _projectId)));
        string memory description = _fundingStorage.getString(keccak256(abi.encodePacked("project.timeline.milestones.description", _index, _projectId)));
        uint percentage = _fundingStorage.getUint(keccak256(abi.encodePacked("project.timeline.milestones.percentage", _index, _projectId)));
        bool isComplete = _fundingStorage.getBool(keccak256(abi.encodePacked("project.timeline.milestones.isComplete", _index, _projectId)));

        Milestone memory milestone = Milestone({
            title: title,
            description: description,
            percentage: percentage,
            isComplete: isComplete
        });

        return milestone;
    }

    function getPendingTimelineMilestoneTitle(FundingStorage _fundingStorage, uint _projectId, uint _index) internal view returns (string) {
        require(_index < _fundingStorage.getUint(keccak256(abi.encodePacked("project.pendingTimeline.length", _projectId))), "Index is outside of accessible range.");

        return _fundingStorage.getString(keccak256(abi.encodePacked("project.pendingTimeline.milestones.title", _index, _projectId)));
    }

    function getPendingTimelineMilestoneDescription(FundingStorage _fundingStorage, uint _projectId, uint _index) internal view returns (string) {
        require(_index < _fundingStorage.getUint(keccak256(abi.encodePacked("project.pendingTimeline.length", _projectId))), "Index is outside of accessible range.");

        return _fundingStorage.getString(keccak256(abi.encodePacked("project.pendingTimeline.milestones.description", _index, _projectId)));
    }

    function getPendingTimelineMilestonePercentage(FundingStorage _fundingStorage, uint _projectId, uint _index) internal view returns (uint) {
        require(_index < _fundingStorage.getUint(keccak256(abi.encodePacked("project.pendingTimeline.length", _projectId))), "Index is outside of accessible range.");

        return _fundingStorage.getUint(keccak256(abi.encodePacked("project.pendingTimeline.milestones.percentage", _index, _projectId)));
    }

    function getPendingTimelineMilestoneIsComplete(FundingStorage _fundingStorage, uint _projectId, uint _index) internal view returns (bool) {
        require(_index < _fundingStorage.getUint(keccak256(abi.encodePacked("project.pendingTimeline.length", _projectId))), "Index is outside of accessible range.");

        return _fundingStorage.getBool(keccak256(abi.encodePacked("project.pendingTimeline.milestones.isComplete", _index, _projectId)));
    }

    function getPendingTimelineMilestone(FundingStorage _fundingStorage, uint _projectId, uint _index) internal view returns (Milestone) {
        require(_index < _fundingStorage.getUint(keccak256(abi.encodePacked("project.pendingTimeline.length", _projectId))), "Index is outside of accessible range.");

        string memory title = _fundingStorage.getString(keccak256(abi.encodePacked("project.pendingTimeline.milestones.title", _index, _projectId)));
        string memory description = _fundingStorage.getString(keccak256(abi.encodePacked("project.pendingTimeline.milestones.description", _index, _projectId)));
        uint percentage = _fundingStorage.getUint(keccak256(abi.encodePacked("project.pendingTimeline.milestones.percentage", _index, _projectId)));
        bool isComplete = _fundingStorage.getBool(keccak256(abi.encodePacked("project.pendingTimeline.milestones.isComplete", _index, _projectId)));

        Milestone memory milestone = Milestone({
            title: title,
            description: description,
            percentage: percentage,
            isComplete: isComplete
            });

        return milestone;
    }

    function getCompletedMilestonesLength(FundingStorage _fundingStorage, uint _projectId) internal view returns (uint) {
        return _fundingStorage.getUint(keccak256(abi.encodePacked("project.completedMilestones.length", _projectId)));
    }

    function getCompletedMilestoneTitle(FundingStorage _fundingStorage, uint _projectId, uint _index) internal view returns (string) {
        require(_index < _fundingStorage.getUint(keccak256(abi.encodePacked("project.completedMilestones.length", _projectId))), "Index is outside of accessible range.");

        return _fundingStorage.getString(keccak256(abi.encodePacked("project.completedMilestones.title", _index, _projectId)));
    }

    function getCompletedMilestoneDescription(FundingStorage _fundingStorage, uint _projectId, uint _index) internal view returns (string) {
        require(_index < _fundingStorage.getUint(keccak256(abi.encodePacked("project.completedMilestones.length", _projectId))), "Index is outside of accessible range.");

        return _fundingStorage.getString(keccak256(abi.encodePacked("project.completedMilestones.description", _index, _projectId)));
    }

    function getCompletedMilestonePercentage(FundingStorage _fundingStorage, uint _projectId, uint _index) internal view returns (uint) {
        require(_index < _fundingStorage.getUint(keccak256(abi.encodePacked("project.completedMilestones.length", _projectId))), "Index is outside of accessible range.");

        return _fundingStorage.getUint(keccak256(abi.encodePacked("project.completedMilestones.percentage", _index, _projectId)));
    }

    function getCompletedMilestoneIsComplete(FundingStorage _fundingStorage, uint _projectId, uint _index) internal view returns (bool) {
        require(_index < _fundingStorage.getUint(keccak256(abi.encodePacked("project.completedMilestones.length", _projectId))), "Index is outside of accessible range.");

        return _fundingStorage.getBool(keccak256(abi.encodePacked("project.completedMilestones.isComplete", _index, _projectId)));
    }

    function getCompletedMilestone(FundingStorage _fundingStorage, uint _projectId, uint _index) internal view returns (Milestone) {
        require(_index < _fundingStorage.getUint(keccak256(abi.encodePacked("project.completedMilestones.length", _projectId))), "Index is outside of accessible range.");

        string memory title = _fundingStorage.getString(keccak256(abi.encodePacked("project.completedMilestones.title", _index, _projectId)));
        string memory description = _fundingStorage.getString(keccak256(abi.encodePacked("project.completedMilestones.description", _index, _projectId)));
        uint percentage = _fundingStorage.getUint(keccak256(abi.encodePacked("project.completedMilestones.percentage", _index, _projectId)));
        bool isComplete = _fundingStorage.getBool(keccak256(abi.encodePacked("project.completedMilestones.isComplete", _index, _projectId)));

        Milestone memory milestone = Milestone({
            title: title,
            description: description,
            percentage: percentage,
            isComplete: isComplete
            });

        return milestone;
    }

    function getTimelineHistoryMilestonesLength(FundingStorage _fundingStorage, uint _projectId, uint _timelineIndex) internal view returns (uint) {
        return _fundingStorage.getUint(keccak256(abi.encodePacked("project.timelineHistory.milestones.length", _projectId, _timelineIndex)));
    }

    function getTimelineHistoryMilestoneTitle(FundingStorage _fundingStorage, uint _projectId, uint _timelineIndex, uint _milestoneIndex) internal view returns (string) {
        require(_timelineIndex < _fundingStorage.getUint(keccak256(abi.encodePacked("project.timelineHistory.length", _projectId))), "Timeline index is outside of accessible range.");
        require(_milestoneIndex < _fundingStorage.getUint(keccak256(abi.encodePacked("project.timelineHistory.milestones.length", _projectId, _timelineIndex))), "Milestone index is outside of accessible range.");

        return _fundingStorage.getString(keccak256(abi.encodePacked("project.timelineHistory.milestones.title", _timelineIndex, _milestoneIndex, _projectId)));
    }

    function getTimelineHistoryMilestoneDescription(FundingStorage _fundingStorage, uint _projectId, uint _timelineIndex, uint _milestoneIndex) internal view returns (string) {
        require(_timelineIndex < _fundingStorage.getUint(keccak256(abi.encodePacked("project.timelineHistory.length", _projectId))), "Timeline index is outside of accessible range.");
        require(_milestoneIndex < _fundingStorage.getUint(keccak256(abi.encodePacked("project.timelineHistory.milestones.length", _projectId, _timelineIndex))), "Milestone index is outside of accessible range.");

        return _fundingStorage.getString(keccak256(abi.encodePacked("project.timelineHistory.milestones.description", _timelineIndex, _milestoneIndex, _projectId)));
    }

    function getTimelineHistoryMilestonePercentage(FundingStorage _fundingStorage, uint _projectId, uint _timelineIndex, uint _milestoneIndex) internal view returns (uint) {
        require(_timelineIndex < _fundingStorage.getUint(keccak256(abi.encodePacked("project.timelineHistory.length", _projectId))), "Timeline index is outside of accessible range.");
        require(_milestoneIndex < _fundingStorage.getUint(keccak256(abi.encodePacked("project.timelineHistory.milestones.length", _projectId, _timelineIndex))), "Milestone index is outside of accessible range.");

        return _fundingStorage.getUint(keccak256(abi.encodePacked("project.timelineHistory.milestones.percentage", _timelineIndex, _milestoneIndex, _projectId)));
    }

    function getTimelineHistoryMilestoneIsComplete(FundingStorage _fundingStorage, uint _projectId, uint _timelineIndex, uint _milestoneIndex) internal view returns (bool) {
        require(_timelineIndex < _fundingStorage.getUint(keccak256(abi.encodePacked("project.timelineHistory.length", _projectId))), "Timeline index is outside of accessible range.");
        require(_milestoneIndex < _fundingStorage.getUint(keccak256(abi.encodePacked("project.timelineHistory.milestones.length", _projectId, _timelineIndex))), "Milestone index is outside of accessible range.");

        return _fundingStorage.getBool(keccak256(abi.encodePacked("project.timelineHistory.milestones.isComplete", _timelineIndex, _milestoneIndex, _projectId)));
    }

    function getTimelineHistoryMilestone(FundingStorage _fundingStorage, uint _projectId, uint _timelineIndex, uint _milestoneIndex) internal view returns (Milestone) {
        require(_timelineIndex < _fundingStorage.getUint(keccak256(abi.encodePacked("project.timelineHistory.length", _projectId))), "Timeline index is outside of accessible range.");
        require(_milestoneIndex < _fundingStorage.getUint(keccak256(abi.encodePacked("project.timelineHistory.milestones.length", _projectId, _timelineIndex))), "Milestone index is outside of accessible range.");

        string memory title = _fundingStorage.getString(keccak256(abi.encodePacked("project.timelineHistory.milestones.title", _timelineIndex, _milestoneIndex, _projectId)));
        string memory description = _fundingStorage.getString(keccak256(abi.encodePacked("project.timelineHistory.milestones.description", _timelineIndex, _milestoneIndex, _projectId)));
        uint percentage = _fundingStorage.getUint(keccak256(abi.encodePacked("project.timelineHistory.milestones.percentage", _timelineIndex, _milestoneIndex, _projectId)));
        bool isComplete = _fundingStorage.getBool(keccak256(abi.encodePacked("project.timelineHistory.milestones.isComplete", _timelineIndex, _milestoneIndex, _projectId)));

        Milestone memory milestone = Milestone({
            title: title,
            description: description,
            percentage: percentage,
            isComplete: isComplete
            });

        return milestone;
    }

    // ContributionTier

    function getContributionTiersLength(FundingStorage _fundingStorage, uint _projectId) internal view returns (uint) {
        return _fundingStorage.getUint(keccak256(abi.encodePacked("project.contributionTiers.length", _projectId)));
    }

    function getContributionTierContributorLimit(FundingStorage _fundingStorage, uint _projectId, uint _index) internal view returns (uint) {
        require(_index < _fundingStorage.getUint(keccak256(abi.encodePacked("project.contributionTiers.length", _projectId))), "Index is outside of accessible range.");

        return _fundingStorage.getUint(keccak256(abi.encodePacked("project.contributionTiers.contributorLimit", _index, _projectId)));
    }

    function getContributionTierMinContribution(FundingStorage _fundingStorage, uint _projectId, uint _index) internal view returns (uint) {
        require(_index < _fundingStorage.getUint(keccak256(abi.encodePacked("project.contributionTiers.length", _projectId))), "Index is outside of accessible range.");

        return _fundingStorage.getUint(keccak256(abi.encodePacked("project.contributionTiers.minContribution", _index, _projectId)));
    }

    function getContributionTierMaxContribution(FundingStorage _fundingStorage, uint _projectId, uint _index) internal view returns (uint) {
        require(_index < _fundingStorage.getUint(keccak256(abi.encodePacked("project.contributionTiers.length", _projectId))), "Index is outside of accessible range.");

        return _fundingStorage.getUint(keccak256(abi.encodePacked("project.contributionTiers.maxContribution", _index, _projectId)));
    }

    function getContributionTierRewards(FundingStorage _fundingStorage, uint _projectId, uint _index) internal view returns (string) {
        require(_index < _fundingStorage.getUint(keccak256(abi.encodePacked("project.contributionTiers.length", _projectId))), "Index is outside of accessible range.");

        return _fundingStorage.getString(keccak256(abi.encodePacked("project.contributionTiers.rewards", _index, _projectId)));
    }

    function getContributionTier(FundingStorage _fundingStorage, uint _projectId, uint _index) internal view returns (ContributionTier) {
        require(_index < _fundingStorage.getUint(keccak256(abi.encodePacked("project.contributionTiers.length", _projectId))), "Index is outside of accessible range.");

        uint contributorLimit = _fundingStorage.getUint(keccak256(abi.encodePacked("project.contributionTiers.contributorLimit", _index, _projectId)));
        uint minContribution = _fundingStorage.getUint(keccak256(abi.encodePacked("project.contributionTiers.minContribution", _index, _projectId)));
        uint maxContribution = _fundingStorage.getUint(keccak256(abi.encodePacked("project.contributionTiers.maxContribution", _index, _projectId)));
        string memory rewards = _fundingStorage.getString(keccak256(abi.encodePacked("project.contributionTiers.rewards", _index, _projectId)));

        ContributionTier memory tier = ContributionTier({
            contributorLimit: contributorLimit,
            minContribution: minContribution,
            maxContribution: maxContribution,
            rewards: rewards
            });

        return tier;
    }

    function getPendingContributionTiersLength(FundingStorage _fundingStorage, uint _projectId) internal view returns (uint) {
        return _fundingStorage.getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.length", _projectId)));
    }

    function getPendingContributionTierContributorLimit(FundingStorage _fundingStorage, uint _projectId, uint _index) internal view returns (uint) {
        require(_index < _fundingStorage.getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.length", _projectId))), "Index is outside of accessible range.");

        return _fundingStorage.getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.contributorLimit", _index, _projectId)));
    }

    function getPendingContributionTierMinContribution(FundingStorage _fundingStorage, uint _projectId, uint _index) internal view returns (uint) {
        require(_index < _fundingStorage.getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.length", _projectId))), "Index is outside of accessible range.");

        return _fundingStorage.getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.minContribution", _index, _projectId)));
    }

    function getPendingContributionTierMaxContribution(FundingStorage _fundingStorage, uint _projectId, uint _index) internal view returns (uint) {
        require(_index < _fundingStorage.getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.length", _projectId))), "Index is outside of accessible range.");

        return _fundingStorage.getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.maxContribution", _index, _projectId)));
    }

    function getPendingContributionTierRewards(FundingStorage _fundingStorage, uint _projectId, uint _index) internal view returns (string) {
        require(_index < _fundingStorage.getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.length", _projectId))), "Index is outside of accessible range.");

        return _fundingStorage.getString(keccak256(abi.encodePacked("project.pendingContributionTiers.rewards", _index, _projectId)));
    }

    function getPendingContributionTier(FundingStorage _fundingStorage, uint _projectId, uint _index) internal view returns (ContributionTier) {
        require(_index < _fundingStorage.getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.length", _projectId))), "Index is outside of accessible range.");

        uint contributorLimit = _fundingStorage.getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.contributorLimit", _index, _projectId)));
        uint minContribution = _fundingStorage.getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.minContribution", _index, _projectId)));
        uint maxContribution = _fundingStorage.getUint(keccak256(abi.encodePacked("project.pendingContributionTiers.maxContribution", _index, _projectId)));
        string memory rewards = _fundingStorage.getString(keccak256(abi.encodePacked("project.pendingContributionTiers.rewards", _index, _projectId)));

        ContributionTier memory tier = ContributionTier({
            contributorLimit: contributorLimit,
            minContribution: minContribution,
            maxContribution: maxContribution,
            rewards: rewards
            });

        return tier;
    }

    // TimelineProposal

    function getTimelineProposalTimestamp(FundingStorage _fundingStorage, uint _projectId) internal view returns (uint) {
        return _fundingStorage.getUint(keccak256(abi.encodePacked("project.timelineProposal.timestamp", _projectId)));
    }

    function getTimelineProposalApprovalCount(FundingStorage _fundingStorage, uint _projectId) internal view returns (uint) {
        return _fundingStorage.getUint(keccak256(abi.encodePacked("project.timelineProposal.approvalCount", _projectId)));
    }

    function getTimelineProposalDisapprovalCount(FundingStorage _fundingStorage, uint _projectId) internal view returns (uint) {
        return _fundingStorage.getUint(keccak256(abi.encodePacked("project.timelineProposal.disapprovalCount", _projectId)));
    }

    function getTimelineProposalIsActive(FundingStorage _fundingStorage, uint _projectId) internal view returns (bool) {
        return _fundingStorage.getBool(keccak256(abi.encodePacked("project.timelineProposal.isActive", _projectId)));
    }

    function getTimelineProposalHasFailed(FundingStorage _fundingStorage, uint _projectId) internal view returns (bool) {
        return _fundingStorage.getBool(keccak256(abi.encodePacked("project.timelineProposal.hasFailed", _projectId)));
    }

    function getTimelineProposalHasVoted(FundingStorage _fundingStorage, uint _projectId, address _address) internal view returns (bool) {
        return _fundingStorage.getBool(keccak256(abi.encodePacked("project.timelineProposal.voters", _address, _projectId)));
    }

    function getTimelineProposal(FundingStorage _fundingStorage, uint _projectId) internal view returns (TimelineProposal) {
        uint timestamp = _fundingStorage.getUint(keccak256(abi.encodePacked("project.timelineProposal.timestamp", _projectId)));
        uint approvalCount = _fundingStorage.getUint(keccak256(abi.encodePacked("project.timelineProposal.approvalCount", _projectId)));
        uint disapprovalCount = _fundingStorage.getUint(keccak256(abi.encodePacked("project.timelineProposal.disapprovalCount", _projectId)));
        bool isActive = _fundingStorage.getBool(keccak256(abi.encodePacked("project.timelineProposal.isActive", _projectId)));
        bool hasFailed = _fundingStorage.getBool(keccak256(abi.encodePacked("project.timelineProposal.hasFailed", _projectId)));

        TimelineProposal memory timelineProposal = TimelineProposal({
            timestamp: timestamp,
            approvalCount: approvalCount,
            disapprovalCount: disapprovalCount,
            isActive: isActive,
            hasFailed: hasFailed
            });

        return timelineProposal;
    }

    // MilestoneCompletionSubmission

    function getMilestoneCompletionSubmissionTimestamp(FundingStorage _fundingStorage, uint _projectId) internal view returns (uint) {
        return _fundingStorage.getUint(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.timestamp", _projectId)));
    }

    function getMilestoneCompletionSubmissionApprovalCount(FundingStorage _fundingStorage, uint _projectId) internal view returns (uint) {
        return _fundingStorage.getUint(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.approvalCount", _projectId)));
    }

    function getMilestoneCompletionSubmissionDisapprovalCount(FundingStorage _fundingStorage, uint _projectId) internal view returns (uint) {
        return _fundingStorage.getUint(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.disapprovalCount", _projectId)));
    }

    function getMilestoneCompletionSubmissionReport(FundingStorage _fundingStorage, uint _projectId) internal view returns (string) {
        return _fundingStorage.getString(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.report", _projectId)));
    }

    function getMilestoneCompletionSubmissionIsActive(FundingStorage _fundingStorage, uint _projectId) internal view returns (bool) {
        return _fundingStorage.getBool(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.isActive", _projectId)));
    }

    function getMilestoneCompletionSubmissionHasFailed(FundingStorage _fundingStorage, uint _projectId) internal view returns (bool) {
        return _fundingStorage.getBool(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.hasFailed", _projectId)));
    }

    function getMilestoneCompletionSubmissionHasVoted(FundingStorage _fundingStorage, uint _projectId, address _address) internal view returns (bool) {
        return _fundingStorage.getBool(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.voters", _address, _projectId)));
    }

    function getMilestoneCompletionSubmission(FundingStorage _fundingStorage, uint _projectId) internal view returns (MilestoneCompletionSubmission) {
        uint timestamp = _fundingStorage.getUint(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.timestamp", _projectId)));
        uint approvalCount = _fundingStorage.getUint(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.approvalCount", _projectId)));
        uint disapprovalCount = _fundingStorage.getUint(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.disapprovalCount", _projectId)));
        string memory report = _fundingStorage.getString(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.report", _projectId)));
        bool isActive = _fundingStorage.getBool(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.isActive", _projectId)));
        bool hasFailed = _fundingStorage.getBool(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.hasFailed", _projectId)));

        MilestoneCompletionSubmission memory submission = MilestoneCompletionSubmission({
            timestamp: timestamp,
            approvalCount: approvalCount,
            disapprovalCount: disapprovalCount,
            report: report,
            isActive: isActive,
            hasFailed: hasFailed
            });

        return submission;
    }



    // Setters

    function incrementNextProjectId(FundingStorage _fundingStorage) internal {
        uint currentId = _fundingStorage.getUint(keccak256("project.nextId"));
        _fundingStorage.setUint(keccak256("project.nextId"), currentId + 1);
    }

    function setProjectStatus(FundingStorage _fundingStorage, uint _projectId, uint _status) internal {
        _fundingStorage.setUint(keccak256(abi.encodePacked("project.status", _projectId)), _status);
    }

    function setProjectTitle(FundingStorage _fundingStorage, uint _projectId, string _title) internal {
        _fundingStorage.setString(keccak256(abi.encodePacked("project.title", _projectId)), _title);
    }

    function setProjectDescription(FundingStorage _fundingStorage, uint _projectId, string _description) internal {
        _fundingStorage.setString(keccak256(abi.encodePacked("project.description", _projectId)), _description);
    }

    function setProjectAbout(FundingStorage _fundingStorage, uint _projectId, string _about) internal {
        _fundingStorage.setString(keccak256(abi.encodePacked("project.about", _projectId)), _about);
    }

    function setProjectMinContributionGoal(FundingStorage _fundingStorage, uint _projectId, uint _goal) internal {
        _fundingStorage.setUint(keccak256(abi.encodePacked("project.minContributionGoal", _projectId)), _goal);
    }

    function setProjectMaxContributionGoal(FundingStorage _fundingStorage, uint _projectId, uint _goal) internal {
        _fundingStorage.setUint(keccak256(abi.encodePacked("project.maxContributionGoal", _projectId)), _goal);
    }

    function setProjectContributionPeriod(FundingStorage _fundingStorage, uint _projectId, uint _weeks) internal {
        _fundingStorage.setUint(keccak256(abi.encodePacked("project.contributionPeriod", _projectId)), _weeks);
    }

    function setProjectNoRefunds(FundingStorage _fundingStorage, uint _projectId, bool _noRefunds) internal {
        _fundingStorage.setBool(keccak256(abi.encodePacked("project.noRefunds", _projectId)), _noRefunds);
    }

    function setProjectNoTimeline(FundingStorage _fundingStorage, uint _projectId, bool _noTimeline) internal {
        _fundingStorage.setBool(keccak256(abi.encodePacked("project.noTimeline", _projectId)), _noTimeline);
    }

    function setProjectDeveloper(FundingStorage _fundingStorage, uint _projectId, address _developer) internal {
        _fundingStorage.setAddress(keccak256(abi.encodePacked("project.developer", _projectId)), _developer);
    }

    function setProjectDeveloperId(FundingStorage _fundingStorage, uint _projectId, uint _developerId) internal {
        _fundingStorage.setUint(keccak256(abi.encodePacked("project.developerId", _projectId)), _developerId);
    }

    function setActiveMilestoneIndex(FundingStorage _fundingStorage, uint _projectId, uint _index) internal {
        _fundingStorage.setUint(keccak256(abi.encodePacked("project.activeMilestoneIndex", _projectId)), _index);
    }

    // Timeline

    function setTimelineLength(FundingStorage _fundingStorage, uint _projectId, uint _length) internal {
        return _fundingStorage.setUint(keccak256(abi.encodePacked("project.timeline.length", _projectId)), _length);
    }

    function setPendingTimelineLength(FundingStorage _fundingStorage, uint _projectId, uint _length) internal {
        return _fundingStorage.setUint(keccak256(abi.encodePacked("project.pendingTimeline.length", _projectId)), _length);
    }

    function setTimelineHistoryLength(FundingStorage _fundingStorage, uint _projectId, uint _length) internal {
        return _fundingStorage.setUint(keccak256(abi.encodePacked("project.timelineHistory.length", _projectId)), _length);
    }

    // Milestone

    function setTimelineMilestoneTitle(FundingStorage _fundingStorage, uint _projectId, uint _index, string _title) internal {
        return _fundingStorage.setString(keccak256(abi.encodePacked("project.timeline.milestones.title", _index, _projectId)), _title);
    }

    function setTimelineMilestoneDescription(FundingStorage _fundingStorage, uint _projectId, uint _index, string _description) internal {
        return _fundingStorage.setString(keccak256(abi.encodePacked("project.timeline.milestones.description", _index, _projectId)), _description);
    }

    function setTimelineMilestonePercentage(FundingStorage _fundingStorage, uint _projectId, uint _index, uint _percentage) internal {
        return _fundingStorage.setUint(keccak256(abi.encodePacked("project.timeline.milestones.percentage", _index, _projectId)), _percentage);
    }

    function setTimelineMilestoneIsComplete(FundingStorage _fundingStorage, uint _projectId, uint _index, bool _isComplete) internal {
        return _fundingStorage.setBool(keccak256(abi.encodePacked("project.timeline.milestones.isComplete", _index, _projectId)), _isComplete);
    }

    function setTimelineMilestone(
        FundingStorage _fundingStorage,
        uint _projectId,
        uint _index,
        string _title,
        string _description,
        uint _percentage,
        bool _isComplete
    )
        internal
    {
        setTimelineMilestoneTitle(_fundingStorage, _projectId, _index, _title);
        setTimelineMilestoneDescription(_fundingStorage, _projectId, _index, _description);
        setTimelineMilestonePercentage(_fundingStorage, _projectId, _index, _percentage);
        setTimelineMilestoneIsComplete(_fundingStorage, _projectId, _index, _isComplete);
    }

    function pushTimelineMilestone(
        FundingStorage _fundingStorage,
        uint _projectId,
        string _title,
        string _description,
        uint _percentage,
        bool _isComplete
    )
        internal
    {
        uint length = getTimelineLength(_fundingStorage, _projectId);

        setTimelineMilestone(_fundingStorage, _projectId, length, _title, _description, _percentage, _isComplete);

        setTimelineLength(_fundingStorage, _projectId, length.add(1));
    }

    function setPendingTimelineMilestoneTitle(FundingStorage _fundingStorage, uint _projectId, uint _index, string _title) internal {
        return _fundingStorage.setString(keccak256(abi.encodePacked("project.pendingTimeline.milestones.title", _index, _projectId)), _title);
    }

    function setPendingTimelineMilestoneDescription(FundingStorage _fundingStorage, uint _projectId, uint _index, string _description) internal {
        return _fundingStorage.setString(keccak256(abi.encodePacked("project.pendingTimeline.milestones.description", _index, _projectId)), _description);
    }

    function setPendingTimelineMilestonePercentage(FundingStorage _fundingStorage, uint _projectId, uint _index, uint _percentage) internal {
        return _fundingStorage.setUint(keccak256(abi.encodePacked("project.pendingTimeline.milestones.percentage", _index, _projectId)), _percentage);
    }

    function setPendingTimelineMilestoneIsComplete(FundingStorage _fundingStorage, uint _projectId, uint _index, bool _isComplete) internal {
        return _fundingStorage.setBool(keccak256(abi.encodePacked("project.pendingTimeline.milestones.isComplete", _index, _projectId)), _isComplete);
    }

    function setPendingTimelineMilestone(
        FundingStorage _fundingStorage,
        uint _projectId,
        uint _index,
        string _title,
        string _description,
        uint _percentage,
        bool _isComplete
    )
    internal
    {
        setPendingTimelineMilestoneTitle(_fundingStorage, _projectId, _index, _title);
        setPendingTimelineMilestoneDescription(_fundingStorage, _projectId, _index, _description);
        setPendingTimelineMilestonePercentage(_fundingStorage, _projectId, _index, _percentage);
        setPendingTimelineMilestoneIsComplete(_fundingStorage, _projectId, _index, _isComplete);
    }

    function pushPendingTimelineMilestone(
        FundingStorage _fundingStorage,
        uint _projectId,
        string _title,
        string _description,
        uint _percentage,
        bool _isComplete
    )
    internal
    {
        uint length = getPendingTimelineLength(_fundingStorage, _projectId);

        setPendingTimelineMilestone(_fundingStorage, _projectId, length, _title, _description, _percentage, _isComplete);

        setPendingTimelineLength(_fundingStorage, _projectId, length.add(1));
    }

    function setCompletedMilestonesLength(FundingStorage _fundingStorage, uint _projectId, uint _length) internal {
        return _fundingStorage.setUint(keccak256(abi.encodePacked("project.completedMilestones.length", _projectId)), _length);
    }

    function setCompletedMilestoneTitle(FundingStorage _fundingStorage, uint _projectId, uint _index, string _title) internal {
        return _fundingStorage.setString(keccak256(abi.encodePacked("project.completedMilestones.title", _index, _projectId)), _title);
    }

    function setCompletedMilestoneDescription(FundingStorage _fundingStorage, uint _projectId, uint _index, string _description) internal {
        return _fundingStorage.setString(keccak256(abi.encodePacked("project.completedMilestones.description", _index, _projectId)), _description);
    }

    function setCompletedMilestonePercentage(FundingStorage _fundingStorage, uint _projectId, uint _index, uint _percentage) internal {
        return _fundingStorage.setUint(keccak256(abi.encodePacked("project.completedMilestones.percentage", _index, _projectId)), _percentage);
    }

    function setCompletedMilestoneIsComplete(FundingStorage _fundingStorage, uint _projectId, uint _index, bool _isComplete) internal {
        return _fundingStorage.setBool(keccak256(abi.encodePacked("project.completedMilestones.isComplete", _index, _projectId)), _isComplete);
    }

    function setCompletedMilestone(
        FundingStorage _fundingStorage,
        uint _projectId,
        uint _index,
        string _title,
        string _description,
        uint _percentage,
        bool _isComplete
    )
        internal
    {
        setCompletedMilestoneTitle(_fundingStorage, _projectId, _index, _title);
        setCompletedMilestoneDescription(_fundingStorage, _projectId, _index, _description);
        setCompletedMilestonePercentage(_fundingStorage, _projectId, _index, _percentage);
        setCompletedMilestoneIsComplete(_fundingStorage, _projectId, _index, _isComplete);
    }

    function pushCompletedMilestone(
        FundingStorage _fundingStorage,
        uint _projectId,
        string _title,
        string _description,
        uint _percentage,
        bool _isComplete
    )
        internal
    {
        uint length = getCompletedMilestonesLength(_fundingStorage, _projectId);

        setCompletedMilestone(_fundingStorage, _projectId, length, _title, _description, _percentage, _isComplete);

        setCompletedMilestonesLength(_fundingStorage, _projectId, length.add(1));
    }

    function setTimelineHistoryMilestonesLength(FundingStorage _fundingStorage, uint _projectId, uint _timelineIndex, uint _length) internal {
        return _fundingStorage.setUint(keccak256(abi.encodePacked("project.timelineHistory.milestones.length", _projectId, _timelineIndex)), _length);
    }

    function setTimelineHistoryMilestoneTitle(FundingStorage _fundingStorage, uint _projectId, uint _timelineIndex, uint _milestoneIndex, string _title) internal {
        return _fundingStorage.setString(keccak256(abi.encodePacked("project.timelineHistory.milestones.title", _projectId, _timelineIndex, _milestoneIndex)), _title);
    }

    function setTimelineHistoryMilestoneDescription(FundingStorage _fundingStorage, uint _projectId, uint _timelineIndex, uint _milestoneIndex, string _description) internal {
        return _fundingStorage.setString(keccak256(abi.encodePacked("project.timelineHistory.milestones.description", _projectId, _timelineIndex, _milestoneIndex)), _description);
    }

    function setTimelineHistoryMilestonePercentage(FundingStorage _fundingStorage, uint _projectId, uint _timelineIndex, uint _milestoneIndex, uint _percentage) internal {
        return _fundingStorage.setUint(keccak256(abi.encodePacked("project.timelineHistory.milestones.percentage", _projectId, _timelineIndex, _milestoneIndex)), _percentage);
    }

    function setTimelineHistoryMilestoneIsComplete(FundingStorage _fundingStorage, uint _projectId, uint _timelineIndex, uint _milestoneIndex, bool _isComplete) internal {
        return _fundingStorage.setBool(keccak256(abi.encodePacked("project.timelineHistory.milestones.isComplete", _projectId, _timelineIndex, _milestoneIndex)), _isComplete);
    }

    function setTimelineHistoryMilestone(
        FundingStorage _fundingStorage,
        uint _projectId,
        uint _timelineIndex,
        uint _milestoneIndex,
        string _title,
        string _description,
        uint _percentage,
        bool _isComplete
    )
    internal
    {
        setTimelineHistoryMilestoneTitle(_fundingStorage, _projectId, _timelineIndex, _milestoneIndex, _title);
        setTimelineHistoryMilestoneDescription(_fundingStorage, _projectId, _timelineIndex, _milestoneIndex, _description);
        setTimelineHistoryMilestonePercentage(_fundingStorage, _projectId, _timelineIndex, _milestoneIndex, _percentage);
        setTimelineHistoryMilestoneIsComplete(_fundingStorage, _projectId, _timelineIndex, _milestoneIndex, _isComplete);
    }

    function pushTimelineHistoryMilestone(
        FundingStorage _fundingStorage,
        uint _projectId,
        uint _timelineIndex,
        string _title,
        string _description,
        uint _percentage,
        bool _isComplete
    )
    internal
    {
        uint length = getTimelineHistoryMilestonesLength(_fundingStorage, _projectId, _timelineIndex);

        setTimelineHistoryMilestone(_fundingStorage, _projectId, _timelineIndex, length, _title, _description, _percentage, _isComplete);

        setTimelineHistoryMilestonesLength(_fundingStorage, _projectId, _timelineIndex, length.add(1));
    }



    // ContributionTier

    function setContributionTiersLength(FundingStorage _fundingStorage, uint _projectId, uint _length) internal {
        return _fundingStorage.setUint(keccak256(abi.encodePacked("project.contributionTiers.length", _projectId)), _length);
    }

    function setContributionTierContributorLimit(FundingStorage _fundingStorage, uint _projectId, uint _index, uint _limit) internal {
        return _fundingStorage.setUint(keccak256(abi.encodePacked("project.contributionTiers.contributorLimit", _index, _projectId)), _limit);
    }

    function setContributionTierMinContribution(FundingStorage _fundingStorage, uint _projectId, uint _index, uint _min) internal {
        return _fundingStorage.setUint(keccak256(abi.encodePacked("project.contributionTiers.minContribution", _index, _projectId)), _min);
    }

    function setContributionTierMaxContribution(FundingStorage _fundingStorage, uint _projectId, uint _index, uint _max) internal {
        return _fundingStorage.setUint(keccak256(abi.encodePacked("project.contributionTiers.maxContribution", _index, _projectId)), _max);
    }

    function setContributionTierRewards(FundingStorage _fundingStorage, uint _projectId, uint _index, string _rewards) internal {
        _fundingStorage.setString(keccak256(abi.encodePacked("project.contributionTiers.rewards", _index, _projectId)), _rewards);
    }

    function setContributionTier(
        FundingStorage _fundingStorage,
        uint _projectId,
        uint _index,
        uint _contributorLimit,
        uint _maxContribution,
        uint _minContribution,
        string _rewards
    )
    internal
    {
        setContributionTierContributorLimit(_fundingStorage, _projectId, _index, _contributorLimit);
        setContributionTierMaxContribution(_fundingStorage, _projectId, _index, _maxContribution);
        setContributionTierMinContribution(_fundingStorage, _projectId, _index, _minContribution);
        setContributionTierRewards(_fundingStorage, _projectId, _index, _rewards);
    }

    function pushContributionTier(
        FundingStorage _fundingStorage,
        uint _projectId,
        uint _contributorLimit,
        uint _maxContribution,
        uint _minContribution,
        string _rewards
    )
        internal
    {
        uint length = getContributionTiersLength(_fundingStorage, _projectId);

        setContributionTier(_fundingStorage, _projectId, length, _contributorLimit, _maxContribution, _minContribution, _rewards);

        setContributionTiersLength(_fundingStorage, _projectId, length.add(1));
    }

    function setPendingContributionTiersLength(FundingStorage _fundingStorage, uint _projectId, uint _length) internal {
        return _fundingStorage.setUint(keccak256(abi.encodePacked("project.pendingContributionTiers.length", _projectId)), _length);
    }

    function setPendingContributionTierContributorLimit(FundingStorage _fundingStorage, uint _projectId, uint _index, uint _limit) internal {
        return _fundingStorage.setUint(keccak256(abi.encodePacked("project.pendingContributionTiers.contributorLimit", _index, _projectId)), _limit);
    }

    function setPendingContributionTierMinContribution(FundingStorage _fundingStorage, uint _projectId, uint _index, uint _min) internal {
        return _fundingStorage.setUint(keccak256(abi.encodePacked("project.pendingContributionTiers.minContribution", _index, _projectId)), _min);
    }

    function setPendingContributionTierMaxContribution(FundingStorage _fundingStorage, uint _projectId, uint _index, uint _max) internal {
        return _fundingStorage.setUint(keccak256(abi.encodePacked("project.pendingContributionTiers.maxContribution", _index, _projectId)), _max);
    }

    function setPendingContributionTierRewards(FundingStorage _fundingStorage, uint _projectId, uint _index, string _rewards) internal {
        _fundingStorage.setString(keccak256(abi.encodePacked("project.pendingContributionTiers.rewards", _index, _projectId)), _rewards);
    }

    function setPendingContributionTier(
        FundingStorage _fundingStorage,
        uint _projectId,
        uint _index,
        uint _contributorLimit,
        uint _maxContribution,
        uint _minContribution,
        string _rewards
    )
    internal
    {
        setPendingContributionTierContributorLimit(_fundingStorage, _projectId, _index, _contributorLimit);
        setPendingContributionTierMaxContribution(_fundingStorage, _projectId, _index, _maxContribution);
        setPendingContributionTierMinContribution(_fundingStorage, _projectId, _index, _minContribution);
        setPendingContributionTierRewards(_fundingStorage, _projectId, _index, _rewards);
    }

    function pushPendingContributionTier(
        FundingStorage _fundingStorage,
        uint _projectId,
        uint _contributorLimit,
        uint _maxContribution,
        uint _minContribution,
        string _rewards
    )
    internal
    {
        uint length = getPendingContributionTiersLength(_fundingStorage, _projectId);

        setPendingContributionTier(_fundingStorage, _projectId, length, _contributorLimit, _maxContribution, _minContribution, _rewards);

        setPendingContributionTiersLength(_fundingStorage, _projectId, length.add(1));
    }

    // TimelineProposal

    function setTimelineProposalTimestamp(FundingStorage _fundingStorage, uint _projectId, uint _timestamp) internal {
        return _fundingStorage.setUint(keccak256(abi.encodePacked("project.timelineProposal.timestamp", _projectId)), _timestamp);
    }

    function setTimelineProposalApprovalCount(FundingStorage _fundingStorage, uint _projectId, uint _count) internal {
        return _fundingStorage.setUint(keccak256(abi.encodePacked("project.timelineProposal.approvalCount", _projectId)), _count);
    }

    function setTimelineProposalDisapprovalCount(FundingStorage _fundingStorage, uint _projectId, uint _count) internal {
        return _fundingStorage.setUint(keccak256(abi.encodePacked("project.timelineProposal.disapprovalCount", _projectId)), _count);
    }

    function setTimelineProposalIsActive(FundingStorage _fundingStorage, uint _projectId, bool _isActive) internal {
        return _fundingStorage.setBool(keccak256(abi.encodePacked("project.timelineProposal.isActive", _projectId)), _isActive);
    }

    function setTimelineProposalHasFailed(FundingStorage _fundingStorage, uint _projectId, bool _hasFailed) internal {
        return _fundingStorage.setBool(keccak256(abi.encodePacked("project.timelineProposal.hasFailed", _projectId)), _hasFailed);
    }

    function setTimelineProposalHasVoted(FundingStorage _fundingStorage, uint _projectId, address _address, bool _hasVoted) internal {
        return _fundingStorage.setBool(keccak256(abi.encodePacked("project.timelineProposal.voters", _address, _projectId)), _hasVoted);
    }

    function setTimelineProposal(
        FundingStorage _fundingStorage,
        uint _projectId,
        uint _timestamp,
        uint _approvalCount,
        uint _disapprovalCount,
        bool _isActive,
        bool _hasFailed
    )
    internal
    {
        setTimelineProposalTimestamp(_fundingStorage, _projectId, _timestamp);
        setTimelineProposalApprovalCount(_fundingStorage, _projectId, _approvalCount);
        setTimelineProposalDisapprovalCount(_fundingStorage, _projectId, _disapprovalCount);
        setTimelineProposalIsActive(_fundingStorage, _projectId, _isActive);
        setTimelineProposalHasFailed(_fundingStorage, _projectId, _hasFailed);
    }

    // MilestoneCompletionSubmission

    function setMilestoneCompletionSubmissionTimestamp(FundingStorage _fundingStorage, uint _projectId, uint _timestamp) internal {
        return _fundingStorage.setUint(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.timestamp", _projectId)), _timestamp);
    }

    function setMilestoneCompletionSubmissionApprovalCount(FundingStorage _fundingStorage, uint _projectId, uint _count) internal {
        return _fundingStorage.setUint(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.approvalCount", _projectId)), _count);
    }

    function setMilestoneCompletionSubmissionDisapprovalCount(FundingStorage _fundingStorage, uint _projectId, uint _count) internal {
        return _fundingStorage.setUint(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.disapprovalCount", _projectId)), _count);
    }

    function setMilestoneCompletionSubmissionReport(FundingStorage _fundingStorage, uint _projectId, string _report) internal {
        return _fundingStorage.setString(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.report", _projectId)), _report);
    }

    function setMilestoneCompletionSubmissionIsActive(FundingStorage _fundingStorage, uint _projectId, bool _isActive) internal {
        return _fundingStorage.setBool(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.isActive", _projectId)), _isActive);
    }

    function setMilestoneCompletionSubmissionHasFailed(FundingStorage _fundingStorage, uint _projectId, bool _hasFailed) internal {
        return _fundingStorage.setBool(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.hasFailed", _projectId)), _hasFailed);
    }

    function setMilestoneCompletionSubmissionHasVoted(FundingStorage _fundingStorage, uint _projectId, address _address, bool _vote) internal {
        return _fundingStorage.setBool(keccak256(abi.encodePacked("project.milestoneCompletionSubmission.voters", _address, _projectId)), _vote);
    }

    function setMilestoneCompletionSubmission(
        FundingStorage _fundingStorage,
        uint _projectId,
        uint _timestamp,
        uint _approvalCount,
        uint _disapprovalCount,
        string _report,
        bool _isActive,
        bool _hasFailed
    )
    internal
    {
        setMilestoneCompletionSubmissionTimestamp(_fundingStorage, _projectId, _timestamp);
        setMilestoneCompletionSubmissionApprovalCount(_fundingStorage, _projectId, _approvalCount);
        setMilestoneCompletionSubmissionDisapprovalCount(_fundingStorage, _projectId, _disapprovalCount);
        setMilestoneCompletionSubmissionReport(_fundingStorage, _projectId, _report);
        setMilestoneCompletionSubmissionIsActive(_fundingStorage, _projectId, _isActive);
        setMilestoneCompletionSubmissionHasFailed(_fundingStorage, _projectId, _hasFailed);
    }
}
