pragma solidity ^0.4.24;

import "./project/ProjectBase.sol";
import "./libraries/storage/CurationStorageAccess.sol";
import "./libraries/storage/ProjectStorageAccess.sol";
import "./libraries/storage/ContributionStorageAccess.sol";
import "./openzeppelin/SafeMath.sol";

contract Curation is Ownable, Testable {

    using SafeMath for uint256;
    using CurationStorageAccess for FundingStorage;
    using ContributionStorageAccess for FundingStorage;
    using ProjectStorageAccess for FundingStorage;

    modifier onlyCurator() {
        require(fundingStorage.getCuratorId(msg.sender) != 0, "You must be a curator to perform this action.");
        _;
    }

    modifier onlyDeveloper(uint _projectId) {
        require(fundingStorage.getProjectDeveloper(_projectId) == msg.sender, "You must be the project developer to perform this action.");
        _;
    }

    FundingStorage public fundingStorage;
    bool private inTest;

    event CuratorCreated(address curatorAddress, uint curatorId);

    constructor(address _fundingStorage, bool _inTest) public Testable(_inTest) {
        fundingStorage = FundingStorage(_fundingStorage);
    }
    
    function () public payable {
        revert();
    }

    function initialize() external {
        require(FundingStorage(fundingStorage).getContractIsValid(this), "This contract is not registered in FundingStorage.");

        // reserve curatorId 0
        fundingStorage.incrementNextCuratorId();
    }

    function createCurator() external {
        require(fundingStorage.getCuratorId(msg.sender) == 0, "This account is already a curator.");

        // Get next ID from storage + increment next ID
        uint id = fundingStorage.generateNewCuratorId();

        // Create developer
        fundingStorage.setCuratorId(msg.sender, id);

        emit CuratorCreated(msg.sender, id);
    }

    function curate(uint _projectId, bool _isApproved) external onlyCurator {
        require(fundingStorage.getDraftCurationIsActive(_projectId), "This project is not open for curation.");

        uint currentApprovalCount = fundingStorage.getDraftCurationApprovalCount(_projectId);

        if (_isApproved) {
            fundingStorage.setDraftCurationApprovalCount(_projectId, currentApprovalCount.add(1));
        } else {
            uint newCount;
            (currentApprovalCount > 0) ? newCount = currentApprovalCount.sub(1) : newCount = 0;
            fundingStorage.setDraftCurationApprovalCount(_projectId, newCount);
        }
    }

    function publishProject(uint _projectId) external onlyDeveloper(_projectId) {
        require(fundingStorage.getDraftCurationIsActive(_projectId), "This project is not open for curation.");
        require(getCurrentTime() > fundingStorage.getDraftCurationTimestamp(_projectId).add(4 weeks), "The project curation window has not closed.");

        uint approvalCount = fundingStorage.getDraftCurationApprovalCount(_projectId);
        uint curationThreshold = fundingStorage.getCurationThreshold();

        if (approvalCount >= curationThreshold) {
            fundingStorage.setProjectStatus(_projectId, uint(ProjectBase.Status.Contributable));
            fundingStorage.setProjectContributionPeriodStart(_projectId, now);
        } else {
            fundingStorage.setProjectStatus(_projectId, uint(ProjectBase.Status.Rejected));
        }

        fundingStorage.setDraftCurationIsActive(_projectId, false);
    }

    function getDraftCuration(uint _projectId) external view returns (uint timestamp, uint approvalCount, bool isActive) {
        CurationStorageAccess.DraftCuration memory draftCuration = fundingStorage.getDraftCuration(_projectId);

        return (draftCuration.timestamp, draftCuration.approvalCount, draftCuration.isActive);
    }

    function getCurationThreshold() external view returns (uint threshold) {
        threshold = fundingStorage.getCurationThreshold();
    }

    function setCurationThreshold(uint _threshold) external onlyOwner {
        fundingStorage.setCurationThreshold(_threshold);
    }
}