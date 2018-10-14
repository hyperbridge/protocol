pragma solidity ^0.4.24;

import "./libraries/storage/DeveloperStorageAccess.sol";
import "./Testable.sol";

contract Developer is Testable {

    using DeveloperStorageAccess for FundingStorage;

    modifier onlyLatestFundingContract() {
        require(FundingStorage(fundingStorage).getBool(keccak256(abi.encodePacked("contract.address", msg.sender))));
        _;
    }

    FundingStorage public fundingStorage;
    bool private inTest;

    event DeveloperCreated(address developerAddress, uint developerId);

    constructor(address _fundingStorage, bool _inTest) public Testable(_inTest) {
        fundingStorage = FundingStorage(_fundingStorage);
    }

    function () public payable {
        revert();
    }

    function initialize() external {
        require(FundingStorage(fundingStorage).getContractIsValid(this), "This contract is not registered in FundingStorage.");

        // reserve developerId 0
        fundingStorage.incrementNextDeveloperId();
    }

    function createDeveloper(string _name) external {
        require(fundingStorage.getDeveloperId(msg.sender) == 0, "This account is already a developer.");

        // Get next ID from storage + increment next ID
        uint id = fundingStorage.generateNewDeveloperId();

        // Create developer
        fundingStorage.setDeveloperId(msg.sender, id);
        fundingStorage.setDeveloperName(id, _name);
        fundingStorage.setDeveloperAddress(id, msg.sender);

        emit DeveloperCreated(msg.sender, id);
    }

    function getDeveloper(uint _id) external view
        returns (
            uint id,
            address addr,
            string name,
            uint[] ownedProjectIds
        )
    {
        DeveloperStorageAccess.Developer memory developer = fundingStorage.getDeveloper(_id);
        return (_id, developer.addr, developer.name, developer.ownedProjectIds);
    }
}