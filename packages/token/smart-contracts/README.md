#   Hyperbridge Token contracts

Hyperbridge token implementation utilizes proxy, eternal storage, and libraries contracts to achieve high upgradability.
 The proxy contract will reference to the latest token implementation and all the token implementations use the same permeant storage contract which makes our token implementation highly permissioned and upgradable.

 #### Deploying and getting the contracts running:

 *  Deploy EternalStorage and Token contracts
 *  Deploy TokenDelegate contract with the following constructor parameters:
     - Name: The token name (i.e. "Hyperbridge Token V1"),
     - Symbol: The token symbol (i.e. "HBX"),
     - Decimals: the token decimals (i.e. 18),
     - Storage: EternalStorage contract address,
     - Version: Token implementation version (i.e. "1.0")
 *  Set the current token implementation as an admin in EternalStorage by calling `addAdmin(address tokenAddress)`
 *  Set the current token implementation as an implementation in Token proxy contract by calling `upgradeTo(address tokenAddress)`

Now Token proxy will be the entry point to our token implementation since it's delegating all the calls to the current token implementation.

#### Upgrading to a new token implementation:

now in order to upgrade to a new implementation, we only have to deploy our new token delegate contract as we did previously and then do the following:

*  Set the current token implementation as an admin in EternalStorage by calling `addAdmin(address tokenAddress)` in the EternalStorage contract.
*  Set the current token implementation as an implementation in Token proxy contract by calling `upgradeTo(address tokenAddress)` in the Token contract.
*  Remove the previous implementation from EternalStorage admins list by calling `removeAdmin(address tokenAddress)` in the EternalStorage contract.
*  Link the new implementation with previous one as a successor/predecessor relationship by calling `upgradeTo(address tokenAddress)` from the previous implementation contract and calling `upgradeFrom(address tokenAddress)` from the new implementation contract in order to move any remaining funds owned by the previous contract to the new one and maintaining a clear traceability
