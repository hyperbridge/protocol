pragma solidity ^0.4.24;

import "../../FundingStorage.sol";
import "../../openzeppelin/SafeMath.sol";

library DeveloperStorageAccess {

    using SafeMath for uint256;

    struct Developer {
        uint id;
        address addr;
        string name;
        mapping(uint => bool) ownsProject; // project id => owned by this dev
        uint[] ownedProjectIds; // the projects belonging to this developer
    }

    /*
        Each developer (indexed by ID) stores the following data in FundingStorage and accesses it through the
        associated namespace:
            address addr                                                    (developer.addr)
            string name                                                     (developer.name)
            mapping(uint (id) => bool) ownsProject                          (developer.ownsProject)
            uint[] ownedProjectIds                                          (developer.projectIds)

        In addition, there is a registry of developers:
            mapping(address => uint (id)) developerMap                      (developer.developerMap)
    */

    // Getters

    function generateNewDeveloperId(FundingStorage _fundingStorage) internal returns (uint) {
        uint id = getNextDeveloperId(_fundingStorage);
        incrementNextDeveloperId(_fundingStorage);
        return id;
    }

    function getNextDeveloperId(FundingStorage _fundingStorage) internal view returns (uint) {
        return _fundingStorage.getUint(keccak256("developer.nextDeveloperId"));
    }

    function getDeveloperId(FundingStorage _fundingStorage, address _developerAddress) internal view returns (uint) {
        return _fundingStorage.getUint(keccak256(abi.encodePacked("developer.developerMap", _developerAddress)));
    }

    function getDeveloperAddress(FundingStorage _fundingStorage, uint _developerId) internal view returns (address) {
        return _fundingStorage.getAddress(keccak256(abi.encodePacked("developer.address", _developerId)));
    }

    function getDeveloperName(FundingStorage _fundingStorage, uint _developerId) internal view returns (string) {
        return _fundingStorage.getString(keccak256(abi.encodePacked("developer.name", _developerId)));
    }

    function getDeveloperOwnsProject(FundingStorage _fundingStorage, uint _developerId, uint _projectId) internal view returns (bool) {
        return _fundingStorage.getBool(keccak256(abi.encodePacked("developer.ownsProject", _developerId, _projectId)));
    }

    function getDeveloperOwnedProjectsLength(FundingStorage _fundingStorage, uint _developerId) internal view returns (uint) {
        return _fundingStorage.getUint(keccak256(abi.encodePacked("developer.projectIds.length", _developerId)));
    }

    function getDeveloperOwnedProject(FundingStorage _fundingStorage, uint _developerId, uint _index) internal view returns (uint) {
        return _fundingStorage.getUint(keccak256(abi.encodePacked("developer.projectIds", _index, _developerId)));
    }

    function getDeveloperOwnedProjects(FundingStorage _fundingStorage, uint _developerId) internal view returns (uint[]) {
        uint length = getDeveloperOwnedProjectsLength(_fundingStorage, _developerId);

        uint[] memory ownedIds = new uint[](length);

        for (uint i = 0; i < length; i++) {
            ownedIds[i] = getDeveloperOwnedProject(_fundingStorage, _developerId, i);
        }

        return ownedIds;
    }

    function getDeveloper(FundingStorage _fundingStorage, uint _developerId) internal view returns (Developer) {
        require(getDeveloperAddress(_fundingStorage, _developerId) != address(0), "Developer does not exist."); // check that developer exists

        Developer memory developer = Developer({
            id: _developerId,
            addr: getDeveloperAddress(_fundingStorage, _developerId),
            name: getDeveloperName(_fundingStorage, _developerId),
            ownedProjectIds: getDeveloperOwnedProjects(_fundingStorage, _developerId)
        });

        return developer;
    }



    // Setters

    function incrementNextDeveloperId(FundingStorage _fundingStorage) internal {
        uint currentId = _fundingStorage.getUint(keccak256("developer.nextDeveloperId"));
        _fundingStorage.setUint(keccak256("developer.nextDeveloperId"), currentId + 1);
    }

    function setDeveloperId(FundingStorage _fundingStorage, address _developerAddress, uint _developerId) internal {
        _fundingStorage.setUint(keccak256(abi.encodePacked("developer.developerMap", _developerAddress)), _developerId);
    }

    function setDeveloperAddress(FundingStorage _fundingStorage, uint _developerId, address _address) internal {
        _fundingStorage.setAddress(keccak256(abi.encodePacked("developer.address", _developerId)), _address);
    }

    function setDeveloperName(FundingStorage _fundingStorage, uint _developerId, string _name) internal {
        _fundingStorage.setString(keccak256(abi.encodePacked("developer.name", _developerId)), _name);
    }

    function setDeveloperOwnsProject(FundingStorage _fundingStorage, uint _developerId, uint _projectId, bool _ownsProject) internal {
        _fundingStorage.setBool(keccak256(abi.encodePacked("developer.ownsProject", _developerId, _projectId)), _ownsProject);
    }

    function setDeveloperOwnedProjectsLength(FundingStorage _fundingStorage, uint _developerId, uint _length) internal {
        _fundingStorage.setUint(keccak256(abi.encodePacked("developer.projectIds.length", _developerId)), _length);
    }

    function setDeveloperOwnedProject(FundingStorage _fundingStorage, uint _developerId, uint _index, uint _projectId) internal {
        _fundingStorage.setUint(keccak256(abi.encodePacked("developer.projectIds", _index, _developerId)), _projectId);
    }

    function pushDeveloperOwnedProject(FundingStorage _fundingStorage, uint _developerId, uint _projectId) internal {
        uint nextIndex = getDeveloperOwnedProjectsLength(_fundingStorage, _developerId);

        setDeveloperOwnedProject(_fundingStorage, _developerId, nextIndex, _projectId);
        setDeveloperOwnedProjectsLength(_fundingStorage, _developerId, nextIndex + 1);

        setDeveloperOwnsProject(_fundingStorage, _developerId, _projectId, true);
    }
}
