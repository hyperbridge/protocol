pragma solidity ^0.4.24;

import "./MarketplaceStorage.sol";
import "./libraries/storage/DeveloperStorageAccess.sol";

contract Developer {

    using DeveloperStorageAccess for MarketplaceStorage;

    MarketplaceStorage public marketplaceStorage;

    event DeveloperCreated(address developerAddress, uint developerId);

    constructor(address _marketplaceStorage) public {
        marketplaceStorage = MarketplaceStorage(_marketplaceStorage);
    }

    function () public payable {
        revert();
    }

    function initialize() external {
        // reserve developerId 0
        marketplaceStorage.incrementNextDeveloperId();
    }

    function createDeveloper(string _name) external {
        require(marketplaceStorage.getDeveloperId(msg.sender) == 0, "This account is already a developer.");

        // Get next ID from storage + increment next ID
        uint id = marketplaceStorage.generateNewDeveloperId();

        // Create developer
        marketplaceStorage.setDeveloperId(msg.sender, id);
        marketplaceStorage.setDeveloperName(id, _name);
        marketplaceStorage.setDeveloperAddress(id, msg.sender);

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
        DeveloperStorageAccess.Developer memory developer = marketplaceStorage.getDeveloper(_id);
        return (_id, developer.addr, developer.name, developer.ownedProductIds);
    }
}
