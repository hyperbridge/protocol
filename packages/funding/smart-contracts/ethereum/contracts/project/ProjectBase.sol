pragma solidity ^0.4.24;

import "../libraries/storage/ProjectStorageAccess.sol";
import "../libraries/storage/DeveloperStorageAccess.sol";
import "../Testable.sol";

contract ProjectBase is Testable {

    using ProjectStorageAccess for FundingStorage;
    using DeveloperStorageAccess for FundingStorage;

    modifier onlyProjectDeveloper(uint _projectId) {
        require(msg.sender == fundingStorage.getProjectDeveloper(_projectId), "You must be the project developer to perform this action.");
        _;
    }

    modifier onlyDraftProject(uint _projectId) {
        require(Status(fundingStorage.getProjectStatus(_projectId)) == Status.Draft, "This action can only be performed on a draft project.");
        _;
    }

    modifier onlyPendingProject(uint _projectId) {
        require(Status(fundingStorage.getProjectStatus(_projectId)) == Status.Pending, "This action can only be performed on a pending project.");
        _;
    }

    modifier onlyContributableProject(uint _projectId) {
        require(Status(fundingStorage.getProjectStatus(_projectId)) == Status.Contributable, "This action can only be performed on a contributable project.");
        _;
    }

    modifier onlyInDevelopmentProject(uint _projectId) {
        require(Status(fundingStorage.getProjectStatus(_projectId)) == Status.InDevelopment, "This action can only be performed on a project in development.");
        _;
    }

    modifier onlyRefundableProject(uint _projectId) {
        require(Status(fundingStorage.getProjectStatus(_projectId)) == Status.Refundable, "This action can only be performed on a refundable project.");
        _;
    }

    enum Status {Inactive, Draft, Pending, Contributable, InDevelopment, Refundable, Rejected}

    FundingStorage public fundingStorage;
}
