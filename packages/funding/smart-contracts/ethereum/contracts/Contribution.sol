pragma solidity ^0.4.24;

import "./libraries/storage/ContributionStorageAccess.sol";
import "./libraries/storage/ProjectStorageAccess.sol";
import "./FundingVault.sol";
import "./project/ProjectBase.sol";
import "./openzeppelin/SafeMath.sol";

contract Contribution is Testable {

    using SafeMath for uint256;
    using ContributionStorageAccess for FundingStorage;
    using ProjectStorageAccess for FundingStorage;

    FundingStorage public fundingStorage;
    bool private inTest;

    event ContributorCreated(address contributorAddress, uint contributorId);

    constructor(address _fundingStorage, bool _inTest) public Testable(_inTest) {
        fundingStorage = FundingStorage(_fundingStorage);
    }

    function () public payable {
        revert();
    }

    function initialize() external {
        require(FundingStorage(fundingStorage).getContractIsValid(this), "This contract is not registered in FundingStorage.");

        // reserve contributorId 0
        fundingStorage.incrementNextContributorId();
    }

    function contributeToProject(uint _projectId) external payable {
        // Contribution must have value
        require(msg.value > 0);
        // Project must be accepting contributions
        require(fundingStorage.getProjectStatus(_projectId) == uint(ProjectBase.Status.Contributable), "Project is not accepting contributions.");
        // It must be within the contribution period set by the developer
        uint contributionPeriod = fundingStorage.getProjectContributionPeriod(_projectId);
        uint periodStart = fundingStorage.getProjectContributionPeriodStart(_projectId);
        require(getCurrentTime() <= contributionPeriod.mul(1 weeks).add(periodStart));
        // The maximum contribution goal must not be reached
        uint maxGoal = fundingStorage.getProjectMaxContributionGoal(_projectId);
        uint currentFunds = fundingStorage.getProjectFundsRaised(_projectId);
        require(currentFunds.add(msg.value) <= maxGoal);

        uint contributorId = fundingStorage.getContributorId(msg.sender);

        // if contributor doesn't exist, create it
        if (contributorId == 0) {
            contributorId = fundingStorage.generateNewContributorId();

            fundingStorage.setContributorId(msg.sender, contributorId);
            fundingStorage.setContributorAddress(contributorId, msg.sender);

            emit ContributorCreated(msg.sender, contributorId);
        }

        // if project is not in contributor's project list, add it
        if (!fundingStorage.getContributesToProject(contributorId, _projectId)) {
            fundingStorage.setContributesToProject(contributorId, _projectId, true);
            uint index = fundingStorage.getContributorFundedProjectsLength(contributorId);
            fundingStorage.setContributorFundedProject(contributorId, index, _projectId);
            fundingStorage.setContributorFundedProjectsLength(contributorId, index.add(1));
        }

        uint currentContribution = fundingStorage.getContributionAmount(_projectId, contributorId);

        // add to projectContributorList, if not already present
        if (currentContribution == 0) {
            uint length = fundingStorage.getProjectContributorListLength(_projectId);
            fundingStorage.setProjectContributor(_projectId, length, contributorId);
            fundingStorage.setProjectContributorListLength(_projectId, length.add(1));
        }

        // add contribution amount to project
        fundingStorage.setContributionAmount(_projectId, contributorId, currentContribution.add(msg.value));
        fundingStorage.setProjectFundsRaised(_projectId, currentFunds.add(msg.value));

        FundingStorage fs = FundingStorage(fundingStorage);
        FundingVault fv = FundingVault(fs.getContractAddress("FundingVault"));
        fv.depositEth.value(msg.value)();
    }

    function refund(uint _projectId) external {
        require(fundingStorage.getProjectStatus(_projectId) == uint(ProjectBase.Status.Refundable), "This project is not refundable.");
        uint contributorId = fundingStorage.getContributorId(msg.sender);
        require(fundingStorage.getContributesToProject(contributorId, _projectId), "This address has not contributed to this project.");

        uint contributedAmount = fundingStorage.getContributionAmount(_projectId, contributorId);
        uint percentageFundsReleased = fundingStorage.getProjectPercentageFundsReleased(_projectId);
        uint percentageFundsRemaining = 100 - percentageFundsReleased;
        uint fundsToRefund = contributedAmount.mul(percentageFundsRemaining).div(100);

        FundingStorage fs = FundingStorage(fundingStorage);
        FundingVault fv = FundingVault(fs.getContractAddress("FundingVault"));
        fv.withdrawEth(fundsToRefund, msg.sender);
    }

    function getProjectFundsRaised(uint _projectId) external view returns (uint) {
        return fundingStorage.getProjectFundsRaised(_projectId);
    }
}
