const FundingStorage = artifacts.require("FundingStorage");
const Curation = artifacts.require("Curation");
const ProjectRegistration = artifacts.require("ProjectRegistration");
const ProjectTimeline = artifacts.require("ProjectTimeline");
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

function advanceTime(numWeeks) {
    const week = 604800000;
    const currentTime = new Date().getTime();
    return new Date(currentTime + numWeeks * week).getTime();
}

contract('CuratorCreation', function(accounts) {
    let curationContract;
    let fundingStorage;
    let curatorAddress;

    before(async () => {
        curationContract = await Curation.deployed();
        fundingStorage = await FundingStorage.deployed();
        await fundingStorage.registerContract("Curation", blankAddress, curationContract.address);
        await curationContract.initialize();

        curatorAddress = accounts[1];
    });

    it("should deploy the curation contract", async () => {
        try {
            assert.ok(curationContract.address);
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("should be able to create a curator", async () => {
        let curatorId;

        try {
            let watcher = curationContract.CuratorCreated().watch(function (error, result) {
                if (!error) {
                    curatorId = result.args.curatorId.toNumber();
                }
            });

            await curationContract.createCurator({ from: curatorAddress });

            watcher.stopWatching();

            assert.notEqual(curatorId, 0, "Curator ID 0 is reserved.");
            assert.equal(curatorId, 1, "Curator ID is incorrect.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("should not be able to create a second curator from the same address", async () => {
        try {
            await curationContract.createCurator({ from: curatorAddress });
            assert.fail();
        } catch (e) {
            console.log(e.message);
        }
    });
});

contract('CuratingProjects', function(accounts) {
    let curationContract;
    let fundingStorage;
    let curatorAddress;
    let projectRegistrationContract;
    let projectTimelineContract;
    let projectContributionTierContract;
    let developerContract;
    let developerAccount;
    let developerId;
    let projectId;

    before(async () => {
        curationContract = await Curation.deployed();
        fundingStorage = await FundingStorage.deployed();
        await fundingStorage.registerContract("Curation", blankAddress, curationContract.address);
        await curationContract.initialize();
        curatorAddress = accounts[2];
        await curationContract.setCurationThreshold(1);
        await curationContract.createCurator({ from: curatorAddress });

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
    });

    beforeEach(async () => {
        let projWatcher = projectRegistrationContract.ProjectCreated().watch(function (error, result) {
            if (!error) {
                projectId = result.args.projectId.toNumber();
            }
        });

        await projectRegistrationContract.createProject(projectTitle, projectDescription, projectAbout, { from: developerAccount });

        projWatcher.stopWatching();

        await projectRegistrationContract.setProjectContributionGoals(projectId, projectMinContributionGoal, projectMaxContributionGoal, projectContributionPeriod, { from: developerAccount });
        await projectRegistrationContract.setProjectTerms(projectId, noRefunds, false, { from: developerAccount });

        await projectTimelineContract.addMilestone(projectId, "Milestone Title", "Milestone Description", 100, { from: developerAccount });
        await projectContributionTierContract.addContributionTier(projectId, 1000, 100, 10, "Rewards!", { from: developerAccount });
    });

    it("curator should be able to curate a project", async () => {
        try {
            await projectRegistrationContract.submitProjectForReview(projectId, { from: developerAccount });

            let draftCuration = await curationContract.getDraftCuration(projectId);
            const initialApprovalCount = draftCuration[1].toNumber();

            await curationContract.curate(projectId, true, { from: curatorAddress });

            draftCuration = await curationContract.getDraftCuration(projectId);
            const newApprovalCount = draftCuration[1].toNumber();

            assert.equal(newApprovalCount, initialApprovalCount + 1, "Curator vote was not registered.");

            await curationContract.curate(projectId, false, { from: curatorAddress });

            draftCuration = await curationContract.getDraftCuration(projectId);
            const newerApprovalCount = draftCuration[1].toNumber();

            assert.equal(newerApprovalCount, newApprovalCount - 1, "Curator vote was not registered.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("non-curator should not be able to curate a project", async () => {
        try {
            await projectRegistrationContract.submitProjectForReview(projectId, { from: developerAccount });

            await curationContract.curate(projectId, true);
            assert.fail();
        } catch (e) {
            console.log(e.message);
        }
    });

    it("curator should not be able to curate a project if project is not seeking curation", async () => {
        try {
            await curationContract.curate(projectId, true);
            assert.fail();
        } catch (e) {
            console.log(e.message);
        }
    });
});

contract('PublishingProjects', function(accounts) {
    let curationContract;
    let fundingStorage;
    let curatorAddress;
    let projectRegistrationContract;
    let projectTimelineContract;
    let projectContributionTierContract;
    let developerContract;
    let developerAccount;
    let developerId;
    let projectId;

    before(async () => {
        curationContract = await Curation.deployed();
        fundingStorage = await FundingStorage.deployed();
        await fundingStorage.registerContract("Curation", blankAddress, curationContract.address);
        await curationContract.initialize();
        curatorAddress = accounts[2];
        await curationContract.setCurationThreshold(1);
        await curationContract.createCurator({ from: curatorAddress });

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
    });

    beforeEach(async () => {
        let projWatcher = projectRegistrationContract.ProjectCreated().watch(function (error, result) {
            if (!error) {
                projectId = result.args.projectId.toNumber();
            }
        });

        await projectRegistrationContract.createProject(projectTitle, projectDescription, projectAbout, { from: developerAccount });

        projWatcher.stopWatching();

        await projectRegistrationContract.setProjectContributionGoals(projectId, projectMinContributionGoal, projectMaxContributionGoal, projectContributionPeriod, { from: developerAccount });
        await projectRegistrationContract.setProjectTerms(projectId, noRefunds, false, { from: developerAccount });

        await projectTimelineContract.addMilestone(projectId, "Milestone Title", "Milestone Description", 100, { from: developerAccount });
        await projectContributionTierContract.addContributionTier(projectId, 1000, 100, 10, "Rewards!", { from: developerAccount });
    });

    it("developer should be able to publish project (Pending -> Contributable)", async () => {
        try {
            await projectRegistrationContract.submitProjectForReview(projectId, { from: developerAccount });

            await curationContract.curate(projectId, true, { from: curatorAddress });

            await curationContract.setTestTime(advanceTime(4.1));

            await curationContract.publishProject(projectId, { from: developerAccount });

            const project = await projectRegistrationContract.getProject(projectId);
            const projectStatus = project[1].toNumber();
            assert.equal(projectStatus, 3, "Project status should be Contributable.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("developer should be able to attempt project publishing (Pending -> Rejected)", async () => {
        try {
            await projectRegistrationContract.submitProjectForReview(projectId, { from: developerAccount });

            await curationContract.curate(projectId, false, { from: curatorAddress });

            await curationContract.setTestTime(advanceTime(4.1));

            await curationContract.publishProject(projectId, { from: developerAccount });

            const project = await projectRegistrationContract.getProject(projectId);
            const projectStatus = project[1].toNumber();
            assert.equal(projectStatus, 6, "Project status should be Contributable.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("developer should not be able to publish project until curation period has passed", async () => {
        try {
            await projectRegistrationContract.submitProjectForReview(projectId, { from: developerAccount });

            await curationContract.curate(projectId, true, { from: curatorAddress });

            await curationContract.publishProject(projectId, { from: developerAccount });

            assert.fail();
        } catch (e) {
            console.log(e.message);
        }
    });
});
