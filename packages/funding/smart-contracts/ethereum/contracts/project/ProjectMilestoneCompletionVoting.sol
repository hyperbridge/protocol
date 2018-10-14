pragma solidity ^0.4.24;

import "../FundingStorage.sol";
import "./ProjectBase.sol";
import "../libraries/ProjectMilestoneCompletionHelpersLibrary.sol";
import "../IVoting.sol";
import "../libraries/ProjectTimelineHelpersLibrary.sol";
import "../openzeppelin/SafeMath.sol";

contract ProjectMilestoneCompletionVoting is ProjectBase, IVoting {

    using SafeMath for uint256;
    using ProjectMilestoneCompletionHelpersLibrary for FundingStorage;
    using ProjectTimelineHelpersLibrary for FundingStorage;
    using ContributionStorageAccess for FundingStorage;

    modifier onlyProjectContributor(uint _projectId) {
        uint contributorId = fundingStorage.getContributorId(msg.sender);
        require(contributorId != 0, "This address is not a contributor.");
        require(fundingStorage.getContributesToProject(contributorId, _projectId), "This address is not a contributor to this project.");
        _;
    }

    constructor(address _fundingStorage, bool _inTest) public Testable(_inTest) {
        fundingStorage = FundingStorage(_fundingStorage);
    }

    function () public payable {
        revert();
    }

    function vote(uint _projectId, bool _approved) external onlyProjectContributor(_projectId) {
        // MilestoneCompletionSubmission must be active
        require(fundingStorage.getMilestoneCompletionSubmissionIsActive(_projectId), "No vote on milestone completion active.");

        // Contributor must not have already voted
        require(!fundingStorage.getMilestoneCompletionSubmissionHasVoted(_projectId, msg.sender), "This contributor address has already voted.");

        if (_approved) {
            uint currentApprovalCount = fundingStorage.getMilestoneCompletionSubmissionApprovalCount(_projectId);
            fundingStorage.setMilestoneCompletionSubmissionApprovalCount(_projectId, currentApprovalCount.add(1));
        } else {
            uint currentDisapprovalCount = fundingStorage.getMilestoneCompletionSubmissionDisapprovalCount(_projectId);
            fundingStorage.setMilestoneCompletionSubmissionDisapprovalCount(_projectId, currentDisapprovalCount.add(1));
        }

        fundingStorage.setMilestoneCompletionSubmissionHasVoted(_projectId, msg.sender, true);
    }

    function finalizeVoting(uint _projectId) external onlyProjectDeveloper(_projectId) {
        // MilestoneCompletionSubmission must be active
        require(fundingStorage.getMilestoneCompletionSubmissionIsActive(_projectId), "No vote on milestone completion active.");

        if (hasPassedMilestoneCompletionVote(_projectId)) {
            succeedMilestoneCompletion(_projectId);
        } else {
            // Set milestone completion submission to inactive
            fundingStorage.setMilestoneCompletionSubmissionIsActive(_projectId, false);

            // Set milestone completion submission has failed
            fundingStorage.setMilestoneCompletionSubmissionHasFailed(_projectId, true);

            if (!fundingStorage.getProjectNoRefunds(_projectId)) {
                fundingStorage.setProjectStatus(_projectId, uint(Status.Refundable));
            }
        }
    }

    function hasPassedMilestoneCompletionVote(uint _projectId) private view returns (bool) {
        uint numContributors = fundingStorage.getProjectContributorListLength(_projectId);
        uint approvalCount = fundingStorage.getMilestoneCompletionSubmissionApprovalCount(_projectId);
        bool isTwoWeeksLater = getCurrentTime() >= fundingStorage.getMilestoneCompletionSubmissionTimestamp(_projectId).add(2 weeks);

        // Proposal needs >75% total approval, or for 2 days to have passed and >75% approval among voters
        require(((approvalCount >= numContributors.mul(75).div(100)) || isTwoWeeksLater),
            "Conditions for finalizing milestone completion have not yet been achieved.");

        uint disapprovalCount = fundingStorage.getMilestoneCompletionSubmissionDisapprovalCount(_projectId);
        uint numVoters = approvalCount.add(disapprovalCount);
        uint votingThreshold = numVoters.mul(75).div(100);

        return (approvalCount >= votingThreshold);
    }

    function succeedMilestoneCompletion(uint _projectId) private {
        uint activeIndex = fundingStorage.getActiveMilestoneIndex(_projectId);
        fundingStorage.setTimelineMilestoneIsComplete(_projectId, activeIndex, true);

        // Set milestone completion submission to inactive
        fundingStorage.setMilestoneCompletionSubmissionIsActive(_projectId, false);

        // Update completedMilestones, remove any pending milestones, and add the completed milestones + current active
        // milestone to the start of the pending timeline. This is to ensure that any future timeline proposals take
        // into account the milestones that have already released their funds.

        // Add current milestone to completed milestones list
        ProjectStorageAccess.Milestone memory activeMilestone = fundingStorage.getTimelineMilestone(_projectId, activeIndex);

        fundingStorage.pushCompletedMilestone(_projectId, activeMilestone.title, activeMilestone.description, activeMilestone.percentage, activeMilestone.isComplete);

        fundingStorage.moveCompletedMilestonesIntoPendingTimeline(_projectId);

        // Increment active milestone and release funds if this was not the last milestone
        if (activeIndex < fundingStorage.getTimelineLength(_projectId).sub(1)) {
            // Increment the active milestone
            activeIndex = activeIndex.add(1);
            fundingStorage.setActiveMilestoneIndex(_projectId, activeIndex);

            // Add currently active milestone to pendingTimeline
            ProjectStorageAccess.Milestone memory currentMilestone = fundingStorage.getTimelineMilestone(_projectId, activeIndex);
            fundingStorage.pushPendingTimelineMilestone(_projectId, currentMilestone.title, currentMilestone.description, currentMilestone.percentage, currentMilestone.isComplete);

            fundingStorage.releaseMilestoneFunds(_projectId, activeIndex);
        }
    }
}
