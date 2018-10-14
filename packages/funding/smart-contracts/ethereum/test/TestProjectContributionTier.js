const FundingStorage = artifacts.require("FundingStorage");
const ProjectRegistration = artifacts.require("ProjectRegistration");
const ProjectContributionTier = artifacts.require("ProjectContributionTier");
const Developer = artifacts.require("Developer");

const blankAddress = 0x0000000000000000000000000000000000000000;
const projectTitle = "BlockHub";
const projectDescription = "This is a description of BlockHub.";
const projectAbout = "This is all about BlockHub.";
const projectMinContributionGoal = 1000;
const projectMaxContributionGoal = 10000;
const projectContributionPeriod = 4;
const noRefunds = true;
const noTimeline = true;

contract('ProjectContributionTier', function(accounts) {
    let fundingStorage;
    let projectRegistrationContract;
    let projectContributionTierContract;
    let developerContract;
    let developerAccount;
    let developerId;
    let projectId;

    before(async () => {
        fundingStorage = await FundingStorage.deployed();

        projectRegistrationContract = await ProjectRegistration.deployed();
        await fundingStorage.registerContract("ProjectRegistration", blankAddress, projectRegistrationContract.address);
        await projectRegistrationContract.initialize();

        projectContributionTierContract = await ProjectContributionTier.deployed();
        await fundingStorage.registerContract("ProjectContributionTier", blankAddress, projectContributionTierContract.address);

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

        let projWatcher = projectRegistrationContract.ProjectCreated().watch(function (error, result) {
            if (!error) {
                projectId = result.args.projectId.toNumber();
            }
        });

        await projectRegistrationContract.createProject(projectTitle, projectDescription, projectAbout, { from: developerAccount });

        projWatcher.stopWatching();

        await projectRegistrationContract.setProjectContributionGoals(projectId, projectMinContributionGoal, projectMaxContributionGoal, projectContributionPeriod, { from: developerAccount });
        await projectRegistrationContract.setProjectTerms(projectId, noRefunds, false, { from: developerAccount });
    });

    it("developer can add a pending contribution tier", async () => {
        const contributorLimit = 1000;
        const maxContribution = 100;
        const minContribution = 10;
        const rewards = "Rewards!";

        try {
            let initialPendingContributionTiersLength = await projectContributionTierContract.getPendingContributionTiersLength(projectId);

            await projectContributionTierContract.addContributionTier(projectId, contributorLimit, maxContribution, minContribution, rewards, { from: developerAccount });

            let newPendingContributionTiersLength = await projectContributionTierContract.getPendingContributionTiersLength(projectId);

            assert.equal(newPendingContributionTiersLength.toNumber(), initialPendingContributionTiersLength.toNumber() + 1, "Contribution tier was not added.");

            let tier = await projectContributionTierContract.getPendingContributionTier(projectId, 0);

            assert.equal(tier[0].toNumber(), contributorLimit, "Contribution limit is incorrect.");
            assert.equal(tier[1].toNumber(), maxContribution, "Max contribution is incorrect.");
            assert.equal(tier[2].toNumber(), minContribution, "Min contribution is incorrect.");
            assert.equal(tier[3], rewards, "Rewards are incorrect.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("developer can edit a pending contribution tier", async () => {
        const newContributorLimit = 2000;
        const newMaxContribution = 200;
        const newMinContribution = 20;
        const newRewards = "More rewards!";

        try {
            await projectContributionTierContract.editContributionTier(projectId, 0, newContributorLimit, newMaxContribution, newMinContribution, newRewards, { from: developerAccount });

            let tier = await projectContributionTierContract.getPendingContributionTier(projectId, 0);

            assert.equal(tier[0].toNumber(), newContributorLimit, "Contribution limit is incorrect.");
            assert.equal(tier[1].toNumber(), newMaxContribution, "Max contribution is incorrect.");
            assert.equal(tier[2].toNumber(), newMinContribution, "Min contribution is incorrect.");
            assert.equal(tier[3], newRewards, "Rewards are incorrect.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("developer can clear pending contribution tiers", async () => {
        try {
            let initialPendingContributionTiersLength = await projectContributionTierContract.getPendingContributionTiersLength(projectId);
            assert.equal(initialPendingContributionTiersLength.toNumber(), 1, "There is no initial pending contribution tier.");

            await projectContributionTierContract.clearPendingContributionTiers(projectId, { from: developerAccount });

            let newPendingContributionTiersLength = await projectContributionTierContract.getPendingContributionTiersLength(projectId);
            assert.equal(newPendingContributionTiersLength.toNumber(), 0, "Pending contribution tiers were not cleared.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });
});
