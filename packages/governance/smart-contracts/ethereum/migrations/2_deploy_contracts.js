var NetworkAccessToken = artifacts.require("./NetworkAccessToken.sol");
var User = artifacts.require("./User.sol");
var Republic = artifacts.require("./Republic.sol");
var RepublicPrimaryElection = artifacts.require("./RepublicPrimaryElection.sol");
var RepublicIndustryElection = artifacts.require("./RepublicIndustryElection.sol");

module.exports = function (deployer) {
    deployer.deploy(NetworkAccessToken);
    deployer.deploy(Republic);
};
