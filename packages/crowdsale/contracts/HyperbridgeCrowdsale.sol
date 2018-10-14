pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/crowdsale/distribution/FinalizableCrowdsale.sol";
import "openzeppelin-solidity/contracts/crowdsale/distribution/PostDeliveryCrowdsale.sol";
import "openzeppelin-solidity/contracts/crowdsale/emission/AllowanceCrowdsale.sol";
import "openzeppelin-solidity/contracts/crowdsale/validation/CappedCrowdsale.sol";
import "openzeppelin-solidity/contracts/crowdsale/validation/IndividuallyCappedCrowdsale.sol";

contract HyperbridgeCrowdsale is
    PostDeliveryCrowdsale,
    AllowanceCrowdsale,
    IndividuallyCappedCrowdsale,
    CappedCrowdsale {

    constructor(uint256 _rate, address _wallet, ERC20 _token, address _tokenWallet, uint256 _cap, uint256 _startTime, uint256 _endTime) public
        Crowdsale(_rate, _wallet, _token)
        AllowanceCrowdsale(_tokenWallet)
        CappedCrowdsale(_cap)
        TimedCrowdsale (_startTime, _endTime) {}


    function changeTokenAddress(ERC20 _token) public onlyOwner {
        token = _token;
    }

    function changeWalletAddress(address _wallet) public onlyOwner {
        wallet = _wallet;
    }

    function changeRate(uint256 _rate) public onlyOwner {
        rate = _rate;
    }

    function changeTokenWallet(address _tokenWallet) public onlyOwner {
        tokenWallet = _tokenWallet;
    }
}
