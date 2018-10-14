const FundingStorage = artifacts.require("FundingStorage");
const FundingVault = artifacts.require("FundingVault");
const ProjectRegistration = artifacts.require("ProjectRegistration");
const ProjectTimeline = artifacts.require("ProjectTimeline");
const ProjectContributionTier = artifacts.require("ProjectContributionTier");
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

contract('ProjectCreation', function(accounts) {
    let fundingStorage;
    let projectRegistrationContract;
    let developerContract;
    let developerAccount;
    let developerId;

    before(async () => {
        fundingStorage = await FundingStorage.deployed();

        projectRegistrationContract = await ProjectRegistration.deployed();
        await fundingStorage.registerContract("ProjectRegistration", blankAddress, projectRegistrationContract.address);
        await projectRegistrationContract.initialize();

        developerContract = await Developer.deployed();
        await fundingStorage.registerContract("Developer", blankAddress, developerContract.address);
        await developerContract.initialize();

        developerAccount = accounts[1];

        let watcher = developerContract.DeveloperCreated().watch(function (error, result) {
            if (!error) {
                developerId = result.args.developerId.toNumber();
            }
        });

        await developerContract.createDeveloper("Hyperbridge", { from: developerAccount });

        watcher.stopWatching();
    });

    it("developer should be able to create a project", async () => {
        try {
            let projectId;

            let watcher = projectRegistrationContract.ProjectCreated().watch(function (error, result) {
                if (!error) {
                    projectId = result.args.projectId.toNumber();
                }
            });

            await projectRegistrationContract.createProject(projectTitle, projectDescription, projectAbout, { from: developerAccount });

            watcher.stopWatching();

            await projectRegistrationContract.setProjectContributionGoals(projectId, projectMinContributionGoal, projectMaxContributionGoal, projectContributionPeriod, { from: developerAccount });
            await projectRegistrationContract.setProjectTerms(projectId, noRefunds, noTimeline, { from: developerAccount });

            const project = await projectRegistrationContract.getProject(projectId);

            assert.notEqual(project[0].toNumber(), 0, "Project ID 0 should be reserved.");
            assert.equal(project[0].toNumber(), projectId, "Project ID is incorrect.");
            assert.equal(project[1].toNumber(), 1, "Project should be set to Status: Draft.");
            assert.equal(project[2], projectTitle, "Project title is incorrect.");
            assert.equal(project[3], projectDescription, "Project description is incorrect.");
            assert.equal(project[4], projectAbout, "Project about is incorrect.");
            assert.equal(project[5].toNumber(), projectMinContributionGoal, "Project min contribution goal is incorrect.");
            assert.equal(project[6].toNumber(), projectMaxContributionGoal, "Project max contribution goal is incorrect.");
            assert.equal(project[7].toNumber(), projectContributionPeriod, "Project contribution period is incorrect.");
            assert.equal(project[8], noRefunds, "Project should not be set to no refunds.");
            assert.equal(project[9], noTimeline, "Project should not be set to no timeline.");
            assert.equal(project[10], developerAccount, "Project developer is incorrect.");
            assert.equal(project[11].toNumber(), developerId, "Project developer ID is incorrect.");

            const developer = await developerContract.getDeveloper(developerId);

            assert.equal(developer[3].length, 1, "Developer's owned projects length is incorrect.");
            assert.equal(developer[3][0], projectId, "Project should be in developer's owned projects.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("non-developer should not be able to create a project", async () => {
        try {
            await projectRegistrationContract.createProject(projectTitle, projectDescription, projectAbout, { from: accounts[2] });
            assert.fail();
        } catch (e) {
            console.log(e.message);
        }
    });
});

contract('ProjectEditing', function(accounts) {
    let fundingStorage;
    let projectRegistrationContract;
    let projectTimelineContract;
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

        projectTimelineContract = await ProjectTimeline.deployed();
        await fundingStorage.registerContract("ProjectTimeline", blankAddress, projectTimelineContract.address);

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

    it("project developer should be able to edit a draft project", async () => {
        const newTitle = "New BlockHub";
        const newDescription = "This is a new description of BlockHub.";
        const newAbout = "This is all about New BlockHub.";
        const newMinContributionGoal = 2000;
        const newMaxContributionGoal = 20000;
        const newContributionPeriod = 5;
        const newNoRefunds = false;
        const newNoTimeline = false;
        
        try {
            await projectRegistrationContract.editProjectInfo(projectId, newTitle, newDescription, newAbout, { from: developerAccount });
            await projectRegistrationContract.setProjectContributionGoals(projectId, newMinContributionGoal, newMaxContributionGoal, newContributionPeriod, { from: developerAccount });
            await projectRegistrationContract.setProjectTerms(projectId, newNoRefunds, newNoTimeline, { from: developerAccount });

            const project = await projectRegistrationContract.getProject(projectId);

            assert.notEqual(project[0].toNumber(), 0, "Project ID 0 should be reserved.");
            assert.equal(project[0].toNumber(), projectId, "Project ID is incorrect.");
            assert.equal(project[1].toNumber(), 1, "Project should be set to Status: Draft.");
            assert.equal(project[2], newTitle, "Project title is incorrect.");
            assert.equal(project[3], newDescription, "Project description is incorrect.");
            assert.equal(project[4], newAbout, "Project about is incorrect.");
            assert.equal(project[5].toNumber(), newMinContributionGoal, "Project min contribution goal is incorrect.");
            assert.equal(project[6].toNumber(), newMaxContributionGoal, "Project max contribution goal is incorrect.");
            assert.equal(project[7].toNumber(), newContributionPeriod, "Project contribution period is incorrect.");
            assert.equal(project[8], newNoRefunds, "Project should not be set to no refunds.");
            assert.equal(project[9], newNoTimeline, "Project should not be set to no timeline.");
            assert.equal(project[10], developerAccount, "Project developer is incorrect.");
            assert.equal(project[11].toNumber(), developerId, "Project developer ID is incorrect.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("non-project developer should not be able to edit a draft project", async () => {
        const newTitle = "New Improved BlockHub";
        const newDescription = "This is a new improved description of BlockHub.";
        const newAbout = "This is all about New Improved BlockHub.";
        
        try {
            await projectRegistrationContract.editProjectInfo(projectId, newTitle, newDescription, newAbout, { from: accounts[2] });

            assert.fail();
        } catch (e) {
            console.log(e.message);
        }
    });
    
    it("project developer should not be able to edit a non-draft project", async () => {
        const newTitle = "New Improved BlockHub";
        const newDescription = "This is a new improved description of BlockHub.";
        const newAbout = "This is all about New Improved BlockHub.";

        try {
            await projectTimelineContract.addMilestone(projectId, "Milestone Title", "Milestone Description", 100, { from: developerAccount });
            await projectContributionTierContract.addContributionTier(projectId, 1000, 100, 10, "Rewards!", { from: developerAccount });

            await projectRegistrationContract.submitProjectForReview(projectId, { from: developerAccount });

            await projectRegistrationContract.editProjectInfo(projectId, newTitle, newDescription, newAbout, { from: developerAccount });

            assert.fail();
        } catch (e) {
            console.log(e.message);
        }
    });
});

contract('ProjectStatus', function(accounts) {
    let fundingStorage;
    let fundingVault;
    let projectRegistrationContract;
    let projectTimelineContract;
    let projectContributionTierContract;
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
    });

    it("project can be submitted for review", async () => {
        try {
            await projectTimelineContract.addMilestone(projectId, "Milestone Title", "Milestone Description", 100, { from: developerAccount });
            await projectContributionTierContract.addContributionTier(projectId, 1000, 100, 10, "Rewards!", { from: developerAccount });

            let initialPendingContributionTiersLength = await projectContributionTierContract.getPendingContributionTiersLength(projectId);
            let initialPendingTimelineLength = await projectTimelineContract.getPendingTimelineLength(projectId);

            await projectRegistrationContract.submitProjectForReview(projectId, { from: developerAccount });

            let newPendingContributionTiersLength = await projectContributionTierContract.getPendingContributionTiersLength(projectId);
            let newContributionTiersLength = await projectContributionTierContract.getContributionTiersLength(projectId);

            let newPendingTimelineLength = await projectTimelineContract.getPendingTimelineLength(projectId);
            let newTimelineLength = await projectTimelineContract.getTimelineLength(projectId);

            assert.equal(newPendingContributionTiersLength.toNumber(), 0, "Pending contribution tiers were not removed.");
            assert.equal(newContributionTiersLength.toNumber(), initialPendingContributionTiersLength.toNumber(), "Pending contribution tiers were not moved into active tiers.");
            assert.equal(newPendingTimelineLength.toNumber(), 0, "Pending timeline was not removed.");
            assert.equal(newTimelineLength.toNumber(), initialPendingTimelineLength.toNumber(), "Pending milestones were not moved into active timeline.");

            const project = await projectRegistrationContract.getProject(projectId);
            assert.equal(project[1].toNumber(), 2, "Project should be set to Status: Pending.");

            const draftCuration = await curationContract.getDraftCuration(projectId);

            assert.equal(draftCuration[2], true, "Draft curation should be active.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("project with no tiers cannot be submitted for review", async () => {
        try {
            await projectTimelineContract.addMilestone(projectId, "Milestone Title", "Milestone Description", 100, { from: developerAccount });

            await projectRegistrationContract.submitProjectForReview(projectId, { from: developerAccount });

            assert.fail();
        } catch (e) {
            console.log(e.message);

            const project = await projectRegistrationContract.getProject(projectId);

            assert.equal(project[1].toNumber(), 1, "Project status should still be Status: Draft.");
        }
    });

    it("project with invalid milestones cannot be submitted for review", async () => {
        try {
            await projectTimelineContract.addMilestone(projectId, "Milestone Title", "Milestone Description", 99, { from: developerAccount });
            await projectContributionTierContract.addContributionTier(projectId, 1000, 100, 10, "Rewards!", { from: developerAccount });

            await projectRegistrationContract.submitProjectForReview(projectId, { from: developerAccount });

            assert.fail();
        } catch (e) {
            console.log(e.message);

            const project = await projectRegistrationContract.getProject(projectId);

            assert.equal(project[1].toNumber(), 1, "Project status should still be Status: Draft.");
        }
    });

    it("project with noTimeline term set can be submitted for review with no milestones", async () => {
        try {
            await projectRegistrationContract.setProjectTerms(projectId, noRefunds, true, { from: developerAccount });

            await projectContributionTierContract.addContributionTier(projectId, 1000, 100, 10, "Rewards!", { from: developerAccount });

            await projectRegistrationContract.submitProjectForReview(projectId, { from: developerAccount });

            const project = await projectRegistrationContract.getProject(projectId);
            assert.equal(project[1].toNumber(), 2, "Project should be set to Status: Pending.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("project can be transitioned from Contributable to InDevelopment if funding goals met", async () => {
        try {
            await projectTimelineContract.addMilestone(projectId, "Milestone Title", "Milestone Description", 100, { from: developerAccount });

            await projectContributionTierContract.addContributionTier(projectId, 1000, 100, 10, "Rewards!", { from: developerAccount });
            await projectRegistrationContract.submitProjectForReview(projectId, { from: developerAccount });
            await curationContract.curate(projectId, true, { from: curatorAddress });
            await curationContract.setTestTime(advanceTime(4.1));
            await curationContract.publishProject(projectId, { from: developerAccount });
            await contributionContract.contributeToProject(projectId, { from: contributorAccount, value: projectMinContributionGoal });
            await projectRegistrationContract.setTestTime(advanceTime(projectContributionPeriod + 0.1));
            await projectRegistrationContract.beginProjectDevelopment(projectId, { from: developerAccount });
            const project = await projectRegistrationContract.getProject(projectId);
            assert.equal(project[1].toNumber(), 4, "Project should be set to Status: InDevelopment.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("project can be transitioned from Contributable to Refundable if funding goals are not met", async () => {
        try {
            await projectTimelineContract.addMilestone(projectId, "Milestone Title", "Milestone Description", 100, { from: developerAccount });

            await projectContributionTierContract.addContributionTier(projectId, 1000, 100, 10, "Rewards!", { from: developerAccount });

            await projectRegistrationContract.submitProjectForReview(projectId, { from: developerAccount });

            await curationContract.curate(projectId, true, { from: curatorAddress });

            await curationContract.setTestTime(advanceTime(4.1));
            await curationContract.publishProject(projectId, { from: developerAccount });

            await contributionContract.contributeToProject(projectId, { from: contributorAccount, value: projectMinContributionGoal - 1 });

            await projectRegistrationContract.setTestTime(advanceTime(projectContributionPeriod + 0.1));
            await projectRegistrationContract.beginProjectDevelopment(projectId, { from: developerAccount });

            const project = await projectRegistrationContract.getProject(projectId);
            assert.equal(project[1].toNumber(), 5, "Project should be set to Status: Refundable.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });
});
