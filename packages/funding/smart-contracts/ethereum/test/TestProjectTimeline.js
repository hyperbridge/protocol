const FundingStorage = artifacts.require("FundingStorage");
const ProjectRegistration = artifacts.require("ProjectRegistration");
const ProjectTimeline = artifacts.require("ProjectTimeline");
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

contract('ProjectTimeline', function(accounts) {
    let fundingStorage;
    let projectRegistrationContract;
    let projectTimelineContract;
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
                projectId = result.args.projectId;
            }
        });

        await projectRegistrationContract.createProject(projectTitle, projectDescription, projectAbout, { from: developerAccount });

        projWatcher.stopWatching();

        await projectRegistrationContract.setProjectContributionGoals(projectId, projectMinContributionGoal, projectMaxContributionGoal, projectContributionPeriod, { from: developerAccount });
        await projectRegistrationContract.setProjectTerms(projectId, noRefunds, false, { from: developerAccount });
    });

    it("developer can add a pending milestone", async () => {
        const milestoneTitle = "Milestone Title";
        const milestoneDescription = "Milestone Description";
        const milestonePercentage = 50;

        try {
            let initialPendingTimelineLength = await projectTimelineContract.getPendingTimelineLength(projectId);

            await projectTimelineContract.addMilestone(projectId, milestoneTitle, milestoneDescription, milestonePercentage, { from: developerAccount });

            let newPendingTimelineLength = await projectTimelineContract.getPendingTimelineLength(projectId);

            assert.equal(newPendingTimelineLength.toNumber(), initialPendingTimelineLength.toNumber() + 1, "Milestone was not added.");

            let milestone = await projectTimelineContract.getPendingTimelineMilestone(projectId, 0);

            assert.equal(milestone[0], milestoneTitle, "Milestone title is incorrect.");
            assert.equal(milestone[1], milestoneDescription, "Milestone description is incorrect.");
            assert.equal(milestone[2].toNumber(), milestonePercentage, "Milestone percentage is incorrect.");
            assert.equal(milestone[3], false, "Milestone should not be marked as complete.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("developer can edit a pending milestone", async () => {
        const newTitle = "New Milestone Title";
        const newDescription = "New Milestone Description";
        const newPercentage = 60;

        try {
            await projectTimelineContract.editMilestone(projectId, 0, newTitle, newDescription, newPercentage, { from: developerAccount });

            let milestone = await projectTimelineContract.getPendingTimelineMilestone(projectId, 0);

            assert.equal(milestone[0], newTitle, "Milestone title is incorrect.");
            assert.equal(milestone[1], newDescription, "Milestone description is incorrect.");
            assert.equal(milestone[2].toNumber(), newPercentage, "Milestone percentage is incorrect.");
            assert.equal(milestone[3], false, "Milestone should still be marked as complete.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("developer can clear the pending milestone", async () => {
        try {
            await projectTimelineContract.clearPendingTimeline(projectId, { from: developerAccount });

            let pendingTimelineLength = await projectTimelineContract.getPendingTimelineLength(projectId);

            assert.equal(pendingTimelineLength, 0, "Pending timeline was not cleared.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });
});
