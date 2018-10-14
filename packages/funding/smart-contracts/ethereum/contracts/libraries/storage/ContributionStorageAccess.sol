pragma solidity ^0.4.24;

import "../../FundingStorage.sol";
import "../../openzeppelin/SafeMath.sol";

library ContributionStorageAccess {

    using SafeMath for uint256;

    struct Contributor {
        uint id;
        address addr;
        mapping(uint => bool) contributesToProject;
        uint[] fundedProjects;
    }

    /*
        Each contributor (indexed by id) stores the following data in FundingStorage and accesses it through the
        associated namespace:
            uint id                                                                     (contributor.id)
            address addr                                                                (contributor.addr)
            mapping(uint => bool) contributesToProject                                  (contributor.contributesToProject)
            uint[] fundedProjects                                                       (contributor.fundedProjects)

        The FundingStorage tracks contribution amounts and total funds raised for each project:
            mapping(uint (projID) => mapping (uint (id) => uint)) contributionAmount    (contribution.contributionAmount)
            mapping(uint (projID) => address[]) contributorList                         (contribution.contributorList)
            mapping(uint (projID) => uint fundsRaised)                                  (contribution.fundsRaised)
            mapping(uint (projID) => uint percentageFundsReleased)                      (contribution.percentageFundsReleased)

        There is a registry of contributors:
            mapping(address => uint (id)) contributorMap                                (contribution.contributorMap)

        Each project stores the timestamp denoting the beginning of its contribution period:
            mapping(uint (projID) => uint contributionPeriodStart)                      (contribution.contributionPeriodStart)
    */

    // Getters

    function generateNewContributorId(FundingStorage _fundingStorage) internal returns (uint) {
        uint id = getNextContributorId(_fundingStorage);
        incrementNextContributorId(_fundingStorage);
        return id;
    }

    function getNextContributorId(FundingStorage _fundingStorage) internal view returns (uint) {
        return _fundingStorage.getUint(keccak256("contribution.nextContributorId"));
    }

    function getContributorId(FundingStorage _fundingStorage, address _contributorAddress) internal view returns (uint) {
        return _fundingStorage.getUint(keccak256(abi.encodePacked("contribution.contributorMap", _contributorAddress)));
    }

    function getContributorAddress(FundingStorage _fundingStorage, uint _contributorId) internal view returns (address) {
        return _fundingStorage.getAddress(keccak256(abi.encodePacked("contributor.address", _contributorId)));
    }

    function getContributesToProject(FundingStorage _fundingStorage, uint _contributorId, uint _projectId) internal view returns (bool) {
        return _fundingStorage.getBool(keccak256(abi.encodePacked("contributor.contributesToProject", _contributorId, _projectId)));
    }

    function getContributorFundedProjectsLength(FundingStorage _fundingStorage, uint _contributorId) internal view returns (uint) {
        return _fundingStorage.getUint(keccak256(abi.encodePacked("contributor.fundedProjects.length", _contributorId)));
    }

    function getContributorFundedProject(FundingStorage _fundingStorage, uint _contributorId, uint _index) internal view returns (uint) {
        return _fundingStorage.getUint(keccak256(abi.encodePacked("contributor.fundedProjects", _index, _contributorId)));
    }

    function getContributorFundedProjects(FundingStorage _fundingStorage, uint _contributorId) internal view returns (uint[]) {
        uint length = getContributorFundedProjectsLength(_fundingStorage, _contributorId);

        uint[] memory fundedIds = new uint[](length);

        for (uint i = 0; i < length; i++) {
            fundedIds[i] = getContributorFundedProject(_fundingStorage, _contributorId, i);
        }

        return fundedIds;
    }

    function getContributor(FundingStorage _fundingStorage, uint _contributorId) internal view returns (Contributor) {
        require(getContributorAddress(_fundingStorage, _contributorId) != address(0), "Contributor does not exist."); // check that contributor exists

        Contributor memory contributor = Contributor({
            id: _contributorId,
            addr: getContributorAddress(_fundingStorage, _contributorId),
            fundedProjects: getContributorFundedProjects(_fundingStorage, _contributorId)
        });

        return contributor;
    }

    function getContributionAmount(FundingStorage _fundingStorage, uint _projectId, uint _contributorId) internal view returns (uint) {
        return _fundingStorage.getUint(keccak256(abi.encodePacked("contribution.contributionAmount", _projectId, _contributorId)));
    }

    function getProjectContributorListLength(FundingStorage _fundingStorage, uint _projectId) internal view returns (uint) {
        return _fundingStorage.getUint(keccak256(abi.encodePacked("contribution.contributorList.length", _projectId)));
    }

    function getProjectContributor(FundingStorage _fundingStorage, uint _projectId, uint _index) internal view returns (uint) {
        return _fundingStorage.getUint(keccak256(abi.encodePacked("contribution.contributorList", _projectId, _index)));
    }

    function getProjectContributionPeriodStart(FundingStorage _fundingStorage, uint _projectId) internal view returns (uint) {
        return _fundingStorage.getUint(keccak256(abi.encodePacked("contribution.contributionPeriodStart", _projectId)));
    }

    function getProjectFundsRaised(FundingStorage _fundingStorage, uint _projectId) internal view returns (uint) {
        return _fundingStorage.getUint(keccak256(abi.encodePacked("contribution.fundsRaised", _projectId)));
    }

    function getProjectPercentageFundsReleased(FundingStorage _fundingStorage, uint _projectId) internal view returns (uint) {
        return _fundingStorage.getUint(keccak256(abi.encodePacked("contribution.percentageFundsReleased", _projectId)));
    }



    // Setters

    function incrementNextContributorId(FundingStorage _fundingStorage) internal {
        uint currentId = _fundingStorage.getUint(keccak256("contribution.nextContributorId"));
        _fundingStorage.setUint(keccak256("contribution.nextContributorId"), currentId + 1);

    }

    function setContributorId(FundingStorage _fundingStorage, address _contributorAddress, uint _contributorId) internal {
        _fundingStorage.setUint(keccak256(abi.encodePacked("contribution.contributorMap", _contributorAddress)), _contributorId);
    }

    function setContributorAddress(FundingStorage _fundingStorage, uint _contributorId, address _contributorAddress) internal {
        _fundingStorage.setAddress(keccak256(abi.encodePacked("contributor.address", _contributorId)), _contributorAddress);
    }

    function setContributesToProject(FundingStorage _fundingStorage, uint _contributorId, uint _projectId, bool _contributesToProject) internal {
        _fundingStorage.setBool(keccak256(abi.encodePacked("contributor.contributesToProject", _contributorId, _projectId)), _contributesToProject);
    }

    function setContributorFundedProjectsLength(FundingStorage _fundingStorage, uint _contributorId, uint _length) internal {
        _fundingStorage.setUint(keccak256(abi.encodePacked("contributor.fundedProjects.length", _contributorId)), _length);
    }

    function setContributorFundedProject(FundingStorage _fundingStorage, uint _contributorId, uint _index, uint _projectId) internal {
        _fundingStorage.setUint(keccak256(abi.encodePacked("contributor.fundedProjects", _index, _contributorId)), _projectId);
    }

    function setContributionAmount(FundingStorage _fundingStorage, uint _projectId, uint _contributorId, uint _amount) internal {
        _fundingStorage.setUint(keccak256(abi.encodePacked("contribution.contributionAmount", _projectId, _contributorId)), _amount);
    }

    function setProjectContributorListLength(FundingStorage _fundingStorage, uint _projectId, uint _length) internal {
        _fundingStorage.setUint(keccak256(abi.encodePacked("contribution.contributorList.length", _projectId)), _length);
    }

    function setProjectContributor(FundingStorage _fundingStorage, uint _projectId, uint _index, uint _contributorId) internal {
        _fundingStorage.setUint(keccak256(abi.encodePacked("contribution.contributorList", _projectId, _index)), _contributorId);
    }

    function setProjectContributionPeriodStart(FundingStorage _fundingStorage, uint _projectId, uint _timestamp) internal {
        _fundingStorage.setUint(keccak256(abi.encodePacked("contribution.contributionPeriodStart", _projectId)), _timestamp);
    }

    function setProjectFundsRaised(FundingStorage _fundingStorage, uint _projectId, uint _fundsRaised) internal {
        _fundingStorage.setUint(keccak256(abi.encodePacked("contribution.fundsRaised", _projectId)), _fundsRaised);
    }

    function setProjectPercentageFundsReleased(FundingStorage _fundingStorage, uint _projectId, uint _fundsReleased) internal {
        _fundingStorage.setUint(keccak256(abi.encodePacked("contribution.percentageFundsReleased", _projectId)), _fundsReleased);
    }
}
