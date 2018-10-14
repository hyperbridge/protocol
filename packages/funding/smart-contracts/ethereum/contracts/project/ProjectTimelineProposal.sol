pragma solidity ^0.4.24;

import "../FundingStorage.sol";
import "./ProjectBase.sol";
import "../libraries/ProjectTimelineHelpersLibrary.sol";

contract ProjectTimelineProposal is ProjectBase {

    using ProjectTimelineHelpersLibrary for FundingStorage;

    constructor(address _fundingStorage, bool _inTest) public Testable(_inTest) {
        fundingStorage = FundingStorage(_fundingStorage);
    }

    function () public payable {
        revert();
    }

    function proposeNewTimeline(uint _projectId) external onlyProjectDeveloper(_projectId) onlyInDevelopmentProject(_projectId) {
        // Can only suggest new timeline if there is not already a timeline proposal active
        require(!fundingStorage.getTimelineProposalIsActive(_projectId), "New timeline cannot be proposed if there is already an active timeline proposal.");
        // Can only suggest new timeline if there is not currently a vote on milestone completion
        require(!fundingStorage.getMilestoneCompletionSubmissionIsActive(_projectId), "New timeline cannot be proposed if there is an active vote on milestone completion.");

        fundingStorage.verifyPendingMilestones(_projectId);

        fundingStorage.setTimelineProposal(_projectId, now, 0, 0, true, false);
    }

    function getTimelineProposal(uint _projectId) external view returns (uint timestamp, uint approvalCount, uint disapprovalCount, bool isActive, bool hasFailed) {
        ProjectStorageAccess.TimelineProposal memory proposal = fundingStorage.getTimelineProposal(_projectId);

        return (proposal.timestamp, proposal.approvalCount, proposal.disapprovalCount, proposal.isActive, proposal.hasFailed);
    }
}
