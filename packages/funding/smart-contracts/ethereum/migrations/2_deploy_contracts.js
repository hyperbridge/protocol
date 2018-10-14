const FundingStorage = artifacts.require("FundingStorage");
const FundingVault = artifacts.require("FundingVault");

const Administration = artifacts.require("Administration");

const ProjectStorageAccess = artifacts.require("ProjectStorageAccess");
const DeveloperStorageAccess = artifacts.require("DeveloperStorageAccess");
const ContributionStorageAccess = artifacts.require("ContributionStorageAccess");
const CurationStorageAccess = artifacts.require("CurationStorageAccess");

const ProjectBase = artifacts.require("ProjectBase");
const ProjectRegistration = artifacts.require("ProjectRegistration");
const ProjectTimeline = artifacts.require("ProjectTimeline");
const ProjectContributionTier = artifacts.require("ProjectContributionTier");
const ProjectMilestoneCompletion = artifacts.require("ProjectMilestoneCompletion");
const ProjectMilestoneCompletionVoting = artifacts.require("ProjectMilestoneCompletionVoting");
const ProjectTimelineProposal = artifacts.require("ProjectTimelineProposal");
const ProjectTimelineProposalVoting = artifacts.require("ProjectTimelineProposalVoting");

const ProjectTimelineHelpersLibrary = artifacts.require("ProjectTimelineHelpersLibrary");
const ProjectContributionTierHelpersLibrary = artifacts.require("ProjectContributionTierHelpersLibrary");
const ProjectRegistrationHelpersLibrary = artifacts.require("ProjectRegistrationHelpersLibrary");
const ProjectMilestoneCompletionHelpersLibrary = artifacts.require("ProjectMilestoneCompletionHelpersLibrary");

const Contribution = artifacts.require("Contribution");

const Developer = artifacts.require("Developer");

const Curation = artifacts.require("Curation");

async function doDeploy(deployer, network) {
    console.log("FundingStorage bytecode size: ", FundingStorage.deployedBytecode.length);
    console.log("FundingVault bytecode size: ", FundingVault.deployedBytecode.length);

    console.log("Administration byecode size: ", Administration.deployedBytecode.length);

    console.log("ProjectStorageAccess bytecode size: ", ProjectStorageAccess.deployedBytecode.length);
    console.log("DeveloperStorageAccess bytecode size: ", DeveloperStorageAccess.deployedBytecode.length);
    console.log("ContributionStorageAccess bytecode size: ", ContributionStorageAccess.deployedBytecode.length);

    console.log("ProjectTimelineHelpersLibrary bytecode size: ", ProjectTimelineHelpersLibrary.deployedBytecode.length);
    console.log("ProjectContributionTierHelpersLibrary bytecode size: ", ProjectContributionTierHelpersLibrary.deployedBytecode.length);
    console.log("ProjectRegistrationHelpersLibrary bytecode size: ", ProjectRegistrationHelpersLibrary.deployedBytecode.length);
    console.log("ProjectMilestoneCompletionHelpersLibrary bytecode size: ", ProjectMilestoneCompletionHelpersLibrary.deployedBytecode.length);

    console.log("ProjectBase bytecode size: ", ProjectBase.deployedBytecode.length);
    console.log("ProjectRegistration bytecode size: ", ProjectRegistration.deployedBytecode.length);
    console.log("ProjectTimeline bytecode size: ", ProjectTimeline.deployedBytecode.length);
    console.log("ProjectContributionTier bytecode size: ", ProjectContributionTier.deployedBytecode.length);
    console.log("ProjectMilestoneCompletion bytecode size: ", ProjectMilestoneCompletion.deployedBytecode.length);
    console.log("ProjectMilestoneCompletionVoting bytecode size: ", ProjectMilestoneCompletionVoting.deployedBytecode.length);
    console.log("ProjectTimelineProposal bytecode size: ", ProjectTimelineProposal.deployedBytecode.length);
    console.log("ProjectTimelineProposalVoting bytecode size: ", ProjectTimelineProposalVoting.deployedBytecode.length);

    console.log("Contribution bytecode size: ", Contribution.deployedBytecode.length);
    console.log("Developer bytecode size: ", Developer.deployedBytecode.length);
    console.log("Curation bytecode size: ", Curation.deployedBytecode.length);

    await deployer.deploy(FundingStorage);
    const fs = await FundingStorage.deployed();

    await deployer.deploy(FundingVault, fs.address);

    await deployer.deploy(Administration, fs.address);

    await deployer.deploy(ProjectStorageAccess);
    await deployer.link(ProjectStorageAccess, [ProjectBase, ProjectTimelineHelpersLibrary, ProjectContributionTierHelpersLibrary, ProjectMilestoneCompletionHelpersLibrary, ProjectRegistrationHelpersLibrary, Contribution, Curation]);

    await deployer.deploy(DeveloperStorageAccess);
    await deployer.link(DeveloperStorageAccess, [Developer, ProjectBase]);

    await deployer.deploy(ContributionStorageAccess);
    await deployer.link(ContributionStorageAccess, [Contribution, ProjectBase, ProjectTimelineProposalVoting, ProjectMilestoneCompletionVoting, ProjectMilestoneCompletionHelpersLibrary]);

    await deployer.deploy(CurationStorageAccess);
    await deployer.link(CurationStorageAccess, Curation);

    await deployer.deploy(ProjectTimelineHelpersLibrary);
    await deployer.link(ProjectTimelineHelpersLibrary, [ProjectTimeline, ProjectTimelineProposal, ProjectMilestoneCompletionVoting, ProjectTimelineProposalVoting, ProjectRegistration, ProjectMilestoneCompletionHelpersLibrary]);

    await deployer.deploy(ProjectContributionTierHelpersLibrary);
    await deployer.link(ProjectContributionTierHelpersLibrary, ProjectRegistration);

    await deployer.deploy(ProjectMilestoneCompletionHelpersLibrary);
    await deployer.link(ProjectMilestoneCompletionHelpersLibrary, [ProjectRegistration, ProjectMilestoneCompletionVoting]);

    await deployer.deploy(ProjectRegistrationHelpersLibrary);
    await deployer.link(ProjectRegistrationHelpersLibrary, ProjectRegistration);

    await deployer.deploy(ProjectRegistration, fs.address, true);
    await deployer.deploy(ProjectTimeline, fs.address, true);
    await deployer.deploy(ProjectContributionTier, fs.address, true);
    await deployer.deploy(ProjectMilestoneCompletion, fs.address, true);
    await deployer.deploy(ProjectMilestoneCompletionVoting, fs.address, true);
    await deployer.deploy(ProjectTimelineProposal, fs.address, true);
    await deployer.deploy(ProjectTimelineProposalVoting, fs.address, true);

    await deployer.deploy(Developer, fs.address, true);
    await deployer.deploy(Contribution, fs.address, true);
    await deployer.deploy(Curation, fs.address, true);
}

module.exports = function(deployer, network) {
    deployer.then(async () => {
        await doDeploy(deployer, network);
    });
};
