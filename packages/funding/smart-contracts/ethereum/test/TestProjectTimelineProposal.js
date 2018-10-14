const FundingStorage = artifacts.require("FundingStorage");
const FundingVault = artifacts.require("FundingVault");
const ProjectRegistration = artifacts.require("ProjectRegistration");
const ProjectTimeline = artifacts.require("ProjectTimeline");
const ProjectContributionTier = artifacts.require("ProjectContributionTier");
const ProjectTimelineProposal = artifacts.require("ProjectTimelineProposal");
const ProjectMilestoneCompletion = artifacts.require("ProjectMilestoneCompletion");
const Developer = artifacts.require("Developer");
const Curation = artifacts.require("Curation");
const Contribution = artifacts.require("Contribution");

const blankAddress = 0x0000000000000000000000000000000000000000;
const projectTitle = "BlockHub";
const projectDescription = "This is a description of BlockHub.";
const projectAbout = "This is all about BlockHub.";
const projectMinContributionGoal = 1000;
const projectMaxContributionGoal = 10000;
const projectContributionPeriod = 4;
const noRefunds = true;
const noTimeline = true;

function advanceTime(numWeeks) {
    const week = 604800000;
    const currentTime = new Date().getTime();
    return new Date(currentTime + numWeeks * week).getTime();
}

contract('ProjectTimelineProposal', function(accounts) {
    let fundingStorage;
    let fundingVault;
    let projectRegistrationContract;
    let projectTimelineContract;
    let projectContributionTierContract;
    let projectTimelineProposalContract;
    let projectMilestoneCompletionContract;
    let developerContract;
    let developerAccount;
    let developerId;
    let projectId;
    let curationContract;
    let curatorAddress;
    let contributionContract;
    let contributorAccount;

    before(async () => {
        fundingStorage = await FundingStorage.deployed();
        fundingVault = await FundingVault.deployed();
        await fundingStorage.registerContract("FundingVault", blankAddress, fundingVault.address);

        projectRegistrationContract = await ProjectRegistration.deployed();
        await fundingStorage.registerContract("ProjectRegistration", blankAddress, projectRegistrationContract.address);
        await projectRegistrationContract.initialize();

        projectTimelineContract = await ProjectTimeline.deployed();
        await fundingStorage.registerContract("ProjectTimeline", blankAddress, projectTimelineContract.address);

        projectTimelineProposalContract = await ProjectTimelineProposal.deployed();
        await fundingStorage.registerContract("ProjectTimelineProposal", blankAddress, projectTimelineProposalContract.address);

        projectMilestoneCompletionContract = await ProjectMilestoneCompletion.deployed();
        await fundingStorage.registerContract("ProjectMilestoneCompletion", blankAddress, projectMilestoneCompletionContract.address);

        projectContributionTierContract = await ProjectContributionTier.deployed();
        await fundingStorage.registerContract("ProjectContributionTier", blankAddress, projectContributionTierContract.address);

        contributionContract = await Contribution.deployed();
        await fundingStorage.registerContract("Contribution", blankAddress, contributionContract.address);
        await contributionContract.initialize();
        contributorAccount = accounts[3];

        curationContract = await Curation.deployed();
        curatorAddress = accounts[2];
        await fundingStorage.registerContract("Curation", blankAddress, curationContract.address);
        await curationContract.setCurationThreshold(1);
        await curationContract.initialize();

        await curationContract.createCurator({ from: curatorAddress });

        developerContract = await Developer.deployed();
        await fundingStorage.registerContract("Developer", blankAddress, developerContract.address);
        await developerContract.initialize();

        developerAccount = accounts[1];

        let devWatcher = developerContract.DeveloperCreated().watch(function (error, result) {
            if (!error) {
                developerId = result.args.developerId.toNumber();
            }
        });

        await developerContract.createDeveloper("Hyperbridge", { from: developerAccount });

        devWatcher.stopWatching();
    });

    beforeEach(async () => {
        let projWatcher = projectRegistrationContract.ProjectCreated().watch(function (error, result) {
            if (!error) {
                projectId = result.args.projectId;
            }
        });

        await projectRegistrationContract.createProject(projectTitle, projectDescription, projectAbout, { from: developerAccount });
        projWatcher.stopWatching();

        await projectRegistrationContract.setProjectContributionGoals(projectId, projectMinContributionGoal, projectMaxContributionGoal, projectContributionPeriod, { from: developerAccount });
        await projectRegistrationContract.setProjectTerms(projectId, noRefunds, false, { from: developerAccount });

        await projectTimelineContract.addMilestone(projectId, "Milestone Title", "Milestone Description", 100, { from: developerAccount });
        await projectContributionTierContract.addContributionTier(projectId, 1000, 100, 10, "Rewards!", { from: developerAccount });
        await projectRegistrationContract.submitProjectForReview(projectId, { from: developerAccount });
        await curationContract.curate(projectId, true, { from: curatorAddress });
    });

    it("developer can propose new timeline", async () => {
        try {
            await curationContract.setTestTime(advanceTime(4.1));
            await curationContract.publishProject(projectId, { from: developerAccount });
            await contributionContract.contributeToProject(projectId, { from: contributorAccount, value: projectMinContributionGoal });
            await projectRegistrationContract.setTestTime(advanceTime(projectContributionPeriod + 0.1));
            await projectRegistrationContract.beginProjectDevelopment(projectId, { from: developerAccount });

            await projectTimelineContract.addMilestone(projectId, "Milestone Title", "Milestone Description", 50, { from: developerAccount });
            await projectTimelineContract.addMilestone(projectId, "Milestone Title", "Milestone Description", 50, { from: developerAccount });

            await projectTimelineProposalContract.proposeNewTimeline(projectId, { from: developerAccount });

            const proposal = await projectTimelineProposalContract.getTimelineProposal(projectId);

            assert.equal(proposal[3], true, "Proposal should be active.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("developer cannot propose new timeline unless project is InDevelopment", async () => {
        try {
            await curationContract.setTestTime(advanceTime(4.1));
            await curationContract.publishProject(projectId, { from: developerAccount });
            await contributionContract.contributeToProject(projectId, { from: contributorAccount, value: projectMinContributionGoal });

            await projectTimelineContract.addMilestone(projectId, "Milestone Title", "Milestone Description", 50, { from: developerAccount });
            await projectTimelineContract.addMilestone(projectId, "Milestone Title", "Milestone Description", 50, { from: developerAccount });

            await projectTimelineProposalContract.proposeNewTimeline(projectId, { from: developerAccount });

            assert.fail();
        } catch (e) {
            console.log(e.message);
        }
    });

    it("developer cannot propose new timeline if there is an active vote for milestone completion", async () => {
        try {
            await curationContract.setTestTime(advanceTime(4.1));
            await curationContract.publishProject(projectId, { from: developerAccount });

            await contributionContract.contributeToProject(projectId, { from: contributorAccount, value: projectMinContributionGoal });

            await projectRegistrationContract.setTestTime(advanceTime(projectContributionPeriod + 0.1));
            await projectRegistrationContract.beginProjectDevelopment(projectId, { from: developerAccount });

            await projectTimelineContract.addMilestone(projectId, "Milestone Title", "Milestone Description", 50, { from: developerAccount });
            await projectTimelineContract.addMilestone(projectId, "Milestone Title", "Milestone Description", 50, { from: developerAccount });

            await projectMilestoneCompletionContract.submitMilestoneCompletion(projectId, "Report", { from: developerAccount });

            await projectTimelineProposalContract.proposeNewTimeline(projectId, { from: developerAccount });

            assert.fail();
        } catch (e) {
            console.log(e.message);
        }
    });

    it("developer cannot propose new timeline if there is an active timeline proposal", async () => {
        try {
            await curationContract.setTestTime(advanceTime(4.1));
            await curationContract.publishProject(projectId, { from: developerAccount });
            await contributionContract.contributeToProject(projectId, { from: contributorAccount, value: projectMinContributionGoal });
            await projectRegistrationContract.setTestTime(advanceTime(projectContributionPeriod + 0.1));
            await projectRegistrationContract.beginProjectDevelopment(projectId, { from: developerAccount });

            await projectTimelineContract.addMilestone(projectId, "Milestone Title", "Milestone Description", 50, { from: developerAccount });
            await projectTimelineContract.addMilestone(projectId, "Milestone Title", "Milestone Description", 50, { from: developerAccount });

            await projectTimelineProposalContract.proposeNewTimeline(projectId, { from: developerAccount });

            await projectTimelineProposalContract.proposeNewTimeline(projectId, { from: developerAccount });

            assert.fail();
        } catch (e) {
            console.log(e.message);
        }
    });

    it("developer cannot propose new timeline if pending milestone percentages are invalid", async () => {
        try {
            await curationContract.setTestTime(advanceTime(4.1));
            await curationContract.publishProject(projectId, { from: developerAccount });
            await contributionContract.contributeToProject(projectId, { from: contributorAccount, value: projectMinContributionGoal });
            await projectRegistrationContract.setTestTime(advanceTime(projectContributionPeriod + 0.1));
            await projectRegistrationContract.beginProjectDevelopment(projectId, { from: developerAccount });

            await projectTimelineContract.addMilestone(projectId, "Milestone Title", "Milestone Description", 51, { from: developerAccount });
            await projectTimelineContract.addMilestone(projectId, "Milestone Title", "Milestone Description", 50, { from: developerAccount });

            await projectTimelineProposalContract.proposeNewTimeline(projectId, { from: developerAccount });

            assert.fail();
        } catch (e) {
            console.log(e.message);
        }
    });
});
