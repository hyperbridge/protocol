const MarketplaceStorage = artifacts.require("MarketplaceStorage");

const Administration = artifacts.require("Administration");

const ProductStorageAccess = artifacts.require("ProductStorageAccess");
const DeveloperStorageAccess = artifacts.require("DeveloperStorageAccess");
const AdministrationStorageAccess = artifacts.require("AdministrationStorageAccess");

const Bytes32Utils = artifacts.require("Bytes32Utils");
const BytesUtils = artifacts.require("BytesUtils");
const StringUtils = artifacts.require("StringUtils");

const ProductBase = artifacts.require("ProductBase");
const ProductRegistration = artifacts.require("ProductRegistration");
const ProductLanguageSupport = artifacts.require("ProductLanguageSupport");
const ProductSystemRequirement = artifacts.require("ProductSystemRequirement");
const ProductPricePlan = artifacts.require("ProductPricePlan");
const ProductVersion = artifacts.require("ProductVersion");
const ProductVersionVoting = artifacts.require("ProductVersionVoting");
const ProductPurchase = artifacts.require("ProductPurchase");

const Developer = artifacts.require("Developer");

async function doDeploy(deployer, network) {
    console.log("MarketplaceStorage bytecode size: ", MarketplaceStorage.deployedBytecode.length);

    console.log("Administration byecode size: ", Administration.deployedBytecode.length);

    console.log("ProductStorageAccess bytecode size: ", ProductStorageAccess.deployedBytecode.length);
    console.log("DeveloperStorageAccess bytecode size: ", DeveloperStorageAccess.deployedBytecode.length);
    console.log("AdministrationStorageAccess bytecode size: ", AdministrationStorageAccess.deployedBytecode.length);

    console.log("Bytes32Utils bytecode size: ", Bytes32Utils.deployedBytecode.length);
    console.log("BytesUtils bytecode size: ", BytesUtils.deployedBytecode.length);
    console.log("StringUtils bytecode size: ", StringUtils.deployedBytecode.length);
    
    console.log("ProductBase bytecode size: ", ProductBase.deployedBytecode.length);
    console.log("ProductRegistration bytecode size: ", ProductRegistration.deployedBytecode.length);
    console.log("ProductLanguageSupport bytecode size: ", ProductLanguageSupport.deployedBytecode.length);
    console.log("ProductSystemRequirement bytecode size: ", ProductSystemRequirement.deployedBytecode.length);
    console.log("ProductPricePlan bytecode size: ", ProductPricePlan.deployedBytecode.length);
    console.log("ProductVersion bytecode size: ", ProductVersion.deployedBytecode.length);
    console.log("ProductVersionVoting bytecode size: ", ProductVersionVoting.deployedBytecode.length);
    console.log("ProductPurchase bytecode size: ", ProductPurchase.deployedBytecode.length);

    console.log("Developer bytecode size: ", Developer.deployedBytecode.length);

    await deployer.deploy(MarketplaceStorage);
    const ms = await MarketplaceStorage.deployed();

    await deployer.deploy(Administration, ms.address);

    await deployer.deploy(ProductStorageAccess);

    await deployer.deploy(DeveloperStorageAccess);

    await deployer.deploy(AdministrationStorageAccess);

    await deployer.deploy(Bytes32Utils);

    await deployer.deploy(BytesUtils);
    await deployer.link(BytesUtils, ProductRegistration);

    await deployer.deploy(StringUtils);
    await deployer.link(StringUtils, [ProductPurchase]);

    await deployer.deploy(ProductRegistration, ms.address);
    await deployer.deploy(ProductLanguageSupport, ms.address);
    await deployer.deploy(ProductSystemRequirement, ms.address);
    await deployer.deploy(ProductPricePlan, ms.address);
    await deployer.deploy(ProductVersion, ms.address);
    await deployer.deploy(ProductVersionVoting, ms.address);
    await deployer.deploy(ProductPurchase, ms.address);
    
    await deployer.deploy(Developer, ms.address);
}

module.exports = function(deployer, network) {
    deployer.then(async () => {
        await doDeploy(deployer, network);
    });
};
