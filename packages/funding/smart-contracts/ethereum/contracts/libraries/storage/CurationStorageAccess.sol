pragma solidity ^0.4.24;

import "../../FundingStorage.sol";
import "../../openzeppelin/SafeMath.sol";

library CurationStorageAccess {

    using SafeMath for uint256;

    struct DraftCuration {
        uint timestamp;
        uint approvalCount;
        bool isActive;
    }

    /*
        In FundingStorage...
            there is a registry of curators:
                mapping(address => uint (id)) curatorMap                (curation.contributorMap)

            there is a curation threshold set:
                uint curationThreshold                                  (curation.curationThreshold)

            there are DraftCuration's (indexed by project ID):
                DraftCuration draftCuration
                    uint timestamp                                      (curation.draftCuration.timestamp)
                    uint approvalCount                                  (curation.draftCuration.approvalCount)
                    bool isActive                                       (curation.draftCuration.isActive)
    */

    // Getters

    function generateNewCuratorId(FundingStorage _fundingStorage) internal returns (uint) {
        uint id = getNextCuratorId(_fundingStorage);
        incrementNextCuratorId(_fundingStorage);
        return id;
    }

    function getNextCuratorId(FundingStorage _fundingStorage) internal view returns (uint) {
        return _fundingStorage.getUint(keccak256("curation.nextCuratorId"));
    }

    function getCuratorId(FundingStorage _fundingStorage, address _curatorAddress) internal view returns (uint) {
        return _fundingStorage.getUint(keccak256(abi.encodePacked("curation.curatorMap", _curatorAddress)));
    }

    function getCurationThreshold(FundingStorage _fundingStorage) internal view returns (uint) {
        return _fundingStorage.getUint(keccak256("curation.curationThreshold"));
    }

    function getDraftCurationTimestamp(FundingStorage _fundingStorage, uint _projectId) internal view returns (uint) {
        return _fundingStorage.getUint(keccak256(abi.encodePacked("curation.draftCuration.timestamp", _projectId)));
    }

    function getDraftCurationApprovalCount(FundingStorage _fundingStorage, uint _projectId) internal view returns (uint) {
        return _fundingStorage.getUint(keccak256(abi.encodePacked("curation.draftCuration.approvalCount", _projectId)));
    }

    function getDraftCurationIsActive(FundingStorage _fundingStorage, uint _projectId) internal view returns (bool) {
        return _fundingStorage.getBool(keccak256(abi.encodePacked("curation.draftCuration.isActive", _projectId)));
    }

    function getDraftCuration(FundingStorage _fundingStorage, uint _projectId) internal view returns (DraftCuration) {
        uint timestamp = getDraftCurationTimestamp(_fundingStorage, _projectId);
        uint approvalCount = getDraftCurationApprovalCount(_fundingStorage, _projectId);
        bool isActive = getDraftCurationIsActive(_fundingStorage, _projectId);

        DraftCuration memory draftCuration = DraftCuration({
            timestamp: timestamp,
            approvalCount: approvalCount,
            isActive: isActive
        });

        return draftCuration;
    }



    // Setters

    function incrementNextCuratorId(FundingStorage _fundingStorage) internal {
        uint currentId = _fundingStorage.getUint(keccak256("curation.nextCuratorId"));
        _fundingStorage.setUint(keccak256("curation.nextCuratorId"), currentId + 1);
    }

    function setCuratorId(FundingStorage _fundingStorage, address _curatorAddress, uint _curatorId) internal {
        _fundingStorage.setUint(keccak256(abi.encodePacked("curation.curatorMap", _curatorAddress)), _curatorId);
    }

    function setCurationThreshold(FundingStorage _fundingStorage, uint _threshold) internal {
        _fundingStorage.setUint(keccak256("curation.curationThreshold"), _threshold);
    }

    function setDraftCurationTimestamp(FundingStorage _fundingStorage, uint _projectId, uint _timestamp) internal {
        _fundingStorage.setUint(keccak256(abi.encodePacked("curation.draftCuration.timestamp", _projectId)), _timestamp);
    }

    function setDraftCurationApprovalCount(FundingStorage _fundingStorage, uint _projectId, uint _approvalCount) internal {
        _fundingStorage.setUint(keccak256(abi.encodePacked("curation.draftCuration.approvalCount", _projectId)), _approvalCount);
    }

    function setDraftCurationIsActive(FundingStorage _fundingStorage, uint _projectId, bool _isActive) internal {
        _fundingStorage.setBool(keccak256(abi.encodePacked("curation.draftCuration.isActive", _projectId)), _isActive);
    }

    function setDraftCuration(FundingStorage _fundingStorage, uint _projectId, uint _timestamp, uint _approvalCount, bool _isActive) internal {
        setDraftCurationTimestamp(_fundingStorage, _projectId, _timestamp);
        setDraftCurationApprovalCount(_fundingStorage, _projectId, _approvalCount);
        setDraftCurationIsActive(_fundingStorage, _projectId, _isActive);
    }
}
