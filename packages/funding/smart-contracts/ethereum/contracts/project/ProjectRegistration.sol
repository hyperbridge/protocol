pragma solidity ^0.4.24;

import "../FundingStorage.sol";
import "./ProjectBase.sol";
import "../libraries/storage/CurationStorageAccess.sol";
import "../libraries/ProjectTimelineHelpersLibrary.sol";
import "../libraries/ProjectContributionTierHelpersLibrary.sol";
import "../libraries/ProjectMilestoneCompletionHelpersLibrary.sol";
import "../libraries/ProjectRegistrationHelpersLibrary.sol";
import "../openzeppelin/SafeMath.sol";

contract ProjectRegistration is ProjectBase {

    using SafeMath for uint256;
    using ProjectRegistrationHelpersLibrary for FundingStorage;
    using ProjectTimelineHelpersLibrary for FundingStorage;
    using ProjectContributionTierHelpersLibrary for FundingStorage;
    using ProjectMilestoneCompletionHelpersLibrary for FundingStorage;
    using CurationStorageAccess for FundingStorage;
    using ContributionStorageAccess for FundingStorage;

    event ProjectCreated(uint projectId);

    constructor(address _fundingStorage, bool _inTest) public Testable(_inTest) {
        fundingStorage = FundingStorage(_fundingStorage);
    }

    function () public payable {
        revert();
    }

    function initialize() external {
        require(FundingStorage(fundingStorage).getContractIsValid(this), "This contract is not registered in FundingStorage.");

        // reserve projectId 0
        fundingStorage.incrementNextProjectId();
    }

    function createProject(
        string _title,
        string _description,
        string _about
    )
        external
    {
        // Verify that sender is a developer
        uint developerId = fundingStorage.getDeveloperId(msg.sender);
        require(developerId != 0, "This address is not a developer.");

        // Get next ID from storage + increment next ID
        uint projectId = fundingStorage.generateNewProjectId();

        // Set new project attributes
        fundingStorage.setProjectInfo(projectId, uint(Status.Draft), _title, _description, _about, msg.sender, developerId);

        // Add project to developer
        fundingStorage.pushDeveloperOwnedProject(developerId, projectId);

        emit ProjectCreated(projectId);
    }

    function setProjectContributionGoals(
        uint _projectId,
        uint _minGoal,
        uint _maxGoal,
        uint _contributionPeriod
    )
        external
        onlyProjectDeveloper(_projectId)
        onlyDraftProject(_projectId)
    {
        // Minimum goal must be greater than 0
        require(_minGoal > 0, "Minimum goal must be greater than 0.");

        // Minimum goal must be less than maximum goal
        require(_minGoal < _maxGoal, "Minimum goal must be less than maximum goal.");

        // Contribution period must be greater than 0
        require(_contributionPeriod > 0, "Contribution period must be at least 1 week.");

        fundingStorage.setProjectContributionGoals(_projectId, _minGoal, _maxGoal, _contributionPeriod);
    }

    function setProjectTerms(
        uint _projectId,
        bool _noRefunds,
        bool _noTimeline
    )
        external
        onlyProjectDeveloper(_projectId)
        onlyDraftProject(_projectId)
    {
        fundingStorage.setProjectTerms(_projectId, _noRefunds, _noTimeline);
    }

    function editProjectInfo(
        uint _projectId,
        string _title,
        string _description,
        string _about
    )
        external
        onlyProjectDeveloper(_projectId)
        onlyDraftProject(_projectId)
    {
        // Set project attributes
        uint developerId = fundingStorage.getProjectDeveloperId(_projectId);

        fundingStorage.setProjectInfo(_projectId, uint(Status.Draft), _title, _description, _about, msg.sender, developerId);
    }

    function getProject(
        uint _projectId
    )
        external
        view
        returns (
            uint id,
            uint status,
            string title,
            string description,
            string about,
            uint minContributionGoal,
            uint maxContributionGoal,
            uint contributionPeriod,
            bool noRefunds,
            bool noTimeline,
            address developer,
            uint developerId
        )
    {
        id = _projectId;
        status = fundingStorage.getProjectStatus(_projectId);
        title = fundingStorage.getProjectTitle(_projectId);
        description = fundingStorage.getProjectDescription(_projectId);
        about = fundingStorage.getProjectAbout(_projectId);
        minContributionGoal = fundingStorage.getProjectMinContributionGoal(_projectId);
        maxContributionGoal = fundingStorage.getProjectMaxContributionGoal(_projectId);
        contributionPeriod = fundingStorage.getProjectContributionPeriod(_projectId);
        developer = fundingStorage.getProjectDeveloper(_projectId);
        noRefunds = fundingStorage.getProjectNoRefunds(_projectId);
        noTimeline = fundingStorage.getProjectNoTimeline(_projectId);
        developerId = fundingStorage.getProjectDeveloperId(_projectId);

        return (id, status, title, description, about, minContributionGoal, maxContributionGoal, contributionPeriod, noRefunds, noTimeline, developer, developerId);
    }

    function submitProjectForReview(uint _projectId) external onlyProjectDeveloper(_projectId) onlyDraftProject(_projectId) {
        bool noTimeline = fundingStorage.getProjectNoTimeline(_projectId);

        // Verify that project has outlined contribution goals
        uint minGoal = fundingStorage.getProjectMinContributionGoal(_projectId);
        uint maxGoal = fundingStorage.getProjectMaxContributionGoal(_projectId);
        require(minGoal != 0 && maxGoal != 0);

        // Make sure project has outlined contribution tiers
        verifyProjectTiers(_projectId);

        // If project has a timeline, verify that milestone percentages add up to 100% and set active timeline
        if (!noTimeline) {
            fundingStorage.verifyPendingMilestones(_projectId);
            fundingStorage.movePendingMilestonesIntoTimeline(_projectId);
            fundingStorage.movePendingContributionTiersIntoActiveContributionTiers(_projectId);
        }

        // Change project status to "Pending"
        fundingStorage.setProjectStatus(_projectId, uint(Status.Pending));

        // Open curation
        fundingStorage.setDraftCurationTimestamp(_projectId, now);
        fundingStorage.setDraftCurationIsActive(_projectId, true);
    }

    function verifyProjectTiers(uint _projectId) private view {
        // Verify that project has contribution tiers
        uint tiersLength = fundingStorage.getPendingContributionTiersLength(_projectId);
        require(tiersLength > 0, "Project has no contribution tiers.");
    }

    function beginProjectDevelopment(uint _projectId) external onlyProjectDeveloper(_projectId) onlyContributableProject(_projectId) {
        // It must be within the contribution period set by the developer
        uint contributionPeriod = fundingStorage.getProjectContributionPeriod(_projectId);
        uint periodStart = fundingStorage.getProjectContributionPeriodStart(_projectId);
        require(getCurrentTime() >= contributionPeriod.mul(1 weeks).add(periodStart));

        uint fundsRaised = fundingStorage.getProjectFundsRaised(_projectId);
        uint minGoal = fundingStorage.getProjectMinContributionGoal(_projectId);

        if (fundsRaised >= minGoal) {
            fundingStorage.setProjectStatus(_projectId, uint(Status.InDevelopment));
            fundingStorage.releaseMilestoneFunds(_projectId, 0);
        } else {
            fundingStorage.setProjectStatus(_projectId, uint(Status.Refundable));
        }
    }
}
