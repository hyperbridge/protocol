pragma solidity ^0.4.24;

import "../FundingStorage.sol";
import "./ProjectBase.sol";

contract ProjectMilestoneCompletion is ProjectBase {

    constructor(address _fundingStorage, bool _inTest) public Testable(_inTest) {
        fundingStorage = FundingStorage(_fundingStorage);
    }

    function () public payable {
        revert();
    }

    function submitMilestoneCompletion(uint _projectId, string _report) external onlyProjectDeveloper(_projectId) onlyInDevelopmentProject(_projectId) {
        // Can only submit for milestone completion if there is not already a vote on milestone completion
        require(!fundingStorage.getMilestoneCompletionSubmissionIsActive(_projectId), "There is already a vote on milestone completion active.");
        // Can only submit for milestone completion if there is not already a vote on a timeline proposal
        require(!fundingStorage.getTimelineProposalIsActive(_projectId), "Cannot submit milestone completion if there is an active vote to change the timeline.");

        fundingStorage.setMilestoneCompletionSubmission(_projectId, now, 0, 0, _report, true, false);
    }

    function getMilestoneCompletionSubmission(uint _projectId) external view returns (uint timestamp, uint approvalCount, uint disapprovalCount, string report, bool isActive, bool hasFailed) {
        ProjectStorageAccess.MilestoneCompletionSubmission memory submission = fundingStorage.getMilestoneCompletionSubmission(_projectId);

        return (submission.timestamp, submission.approvalCount, submission.disapprovalCount, submission.report, submission.isActive, submission.hasFailed);
    }
}
