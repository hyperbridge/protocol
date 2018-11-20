pragma solidity ^0.4.2;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/NetworkAccessToken.sol";

contract TestNetworkAccessToken {

    function testInitialBalanceUsingDeployedContract() public payable {
        NetworkAccessToken token = NetworkAccessToken(DeployedAddresses.NetworkAccessToken());

        uint expected = 1000000000 * 10**uint256(token.decimals());

        Assert.equal(token.balanceOf(tx.origin), expected, "Owner should have 1000000000 NAT initially");
    }

    function testInitialBalanceWithNewToken() public payable {
        NetworkAccessToken token = new NetworkAccessToken();

        uint expected = 1000000000 * 10**uint256(token.decimals());

        Assert.equal(token.balanceOf(address(this)), expected, "Owner should have 1000000000 NAT initially");
    }

    function testTransferBalance() public payable {
        NetworkAccessToken token = new NetworkAccessToken();

        uint expected = 500000000 * 10**uint256(token.decimals());

        token.transferFrom(address(this), 0xC5fdf4076b8F3A5357c5E395ab970B5B54098Fef, expected);

        Assert.equal(token.balanceOf(0xC5fdf4076b8F3A5357c5E395ab970B5B54098Fef), expected, "Owner should have 500000000 NAT initially");
    }

}
