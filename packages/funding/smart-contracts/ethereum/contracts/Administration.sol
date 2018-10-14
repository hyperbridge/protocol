pragma solidity ^0.4.24;

import "./openzeppelin/Ownable.sol";
import "./libraries/storage/ProjectStorageAccess.sol";

contract Administration is Ownable {

    using ProjectStorageAccess for FundingStorage;

    FundingStorage public fundingStorage;

    constructor(address _fundingStorage) public {
        fundingStorage = FundingStorage(_fundingStorage);
    }

    function () public payable {
        revert();
    }

    function setProjectStatus(uint _projectId, uint _status) external onlyOwner {
        fundingStorage.setProjectStatus(_projectId, _status);
    }
}
