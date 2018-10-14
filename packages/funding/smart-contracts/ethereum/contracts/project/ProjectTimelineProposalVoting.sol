pragma solidity ^0.4.24;

import "../FundingStorage.sol";
import "./ProjectBase.sol";
import "../libraries/ProjectTimelineHelpersLibrary.sol";
import "../libraries/storage/ContributionStorageAccess.sol";
import "../IVoting.sol";

contract ProjectTimelineProposalVoting is ProjectBase, IVoting {

    using SafeMath for uint256;
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
        // TimelineProposal must be active
        require(fundingStorage.getTimelineProposalIsActive(_projectId), "No timeline proposal active.");

        // Contributor must not have already voted
        require(!fundingStorage.getTimelineProposalHasVoted(_projectId, msg.sender), "This contributor address has already voted.");

        if (_approved) {
            uint currentApprovalCount = fundingStorage.getTimelineProposalApprovalCount(_projectId);
            fundingStorage.setTimelineProposalApprovalCount(_projectId, currentApprovalCount.add(1));
        } else {
            uint currentDisapprovalCount = fundingStorage.getTimelineProposalDisapprovalCount(_projectId);
            fundingStorage.setTimelineProposalDisapprovalCount(_projectId, currentDisapprovalCount.add(1));
        }

        fundingStorage.setTimelineProposalHasVoted(_projectId, msg.sender, true);
    }

    function finalizeVoting(uint _projectId) external onlyProjectDeveloper(_projectId) {
        // TimelineProposal must be active
        require(fundingStorage.getTimelineProposalIsActive(_projectId), "There is no timeline proposal active.");

        if (hasPassedTimelineProposalVote(_projectId)) {
            succeedTimelineProposal(_projectId);
        } else {
            // Timeline proposal has failed
            fundingStorage.setTimelineProposalHasFailed(_projectId, true);
        }
    }

    function hasPassedTimelineProposalVote(uint _projectId) private view returns (bool) {
        uint numContributors = fundingStorage.getProjectContributorListLength(_projectId);
        uint approvalCount = fundingStorage.getTimelineProposalApprovalCount(_projectId);
        bool isTwoWeeksLater = getCurrentTime() >= fundingStorage.getTimelineProposalTimestamp(_projectId).add(2 weeks);

        // Proposal needs >75% total approval, or for 2 weeks to have passed and >75% approval among voters
        require(((approvalCount >= numContributors.mul(75).div(100)) || isTwoWeeksLater),
            "Conditions for finalizing timeline proposal have not yet been achieved.");

        uint disapprovalCount = fundingStorage.getTimelineProposalDisapprovalCount(_projectId);
        uint numVoters = approvalCount.add(disapprovalCount);
        uint votingThreshold = numVoters.mul(75).div(100);

        return (approvalCount >= votingThreshold);
    }

    function succeedTimelineProposal(uint _projectId) private {
        // Push old timeline into timeline history
        fundingStorage.moveTimelineIntoTimelineHistory(_projectId);

        // Move pending timeline into timeline
        fundingStorage.movePendingMilestonesIntoTimeline(_projectId);

        // Set timeline proposal to inactive
        fundingStorage.setTimelineProposalIsActive(_projectId, false);
    }
}
