pragma solidity ^0.4.24;

import "./storage/ProjectStorageAccess.sol";

library ProjectRegistrationHelpersLibrary {

    using ProjectStorageAccess for FundingStorage;

    function setProjectInfo(FundingStorage _fundingStorage, uint _projectId, uint _status, string _title, string _description, string _about, address _developer, uint _developerId) external {
        _fundingStorage.setProjectStatus(_projectId, _status);
        _fundingStorage.setProjectTitle(_projectId, _title);
        _fundingStorage.setProjectDescription(_projectId, _description);
        _fundingStorage.setProjectAbout(_projectId, _about);
        _fundingStorage.setProjectDeveloper(_projectId, _developer);
        _fundingStorage.setProjectDeveloperId(_projectId, _developerId);
    }

    function setProjectContributionGoals(FundingStorage _fundingStorage, uint _projectId, uint _minGoal, uint _maxGoal, uint _contributionPeriod) external {
        _fundingStorage.setProjectMinContributionGoal(_projectId, _minGoal);
        _fundingStorage.setProjectMaxContributionGoal(_projectId, _maxGoal);
        _fundingStorage.setProjectContributionPeriod(_projectId, _contributionPeriod);
    }

    function setProjectTerms(FundingStorage _fundingStorage, uint _projectId, bool _noRefunds, bool _noTimeline) external {
        _fundingStorage.setProjectNoRefunds(_projectId, _noRefunds);
        _fundingStorage.setProjectNoTimeline(_projectId, _noTimeline);
    }
}
