const FundingStorage = artifacts.require("FundingStorage");
const FundingVault = artifacts.require("FundingVault");
const Contribution = artifacts.require("Contribution");
const ProjectRegistration = artifacts.require("ProjectRegistration");
const ProjectTimeline = artifacts.require("ProjectTimeline");
const ProjectContributionTier = artifacts.require("ProjectContributionTier");
const Developer = artifacts.require("Developer");
const Curation = artifacts.require("Curation");
const ProjectMilestoneCompletion = artifacts.require("ProjectMilestoneCompletion");
const ProjectMilestoneCompletionVoting = artifacts.require("ProjectMilestoneCompletionVoting");

const blankAddress = 0x0000000000000000000000000000000000000000;
const projectTitle = "BlockHub";
const projectDescription = "This is a description of BlockHub.";
const projectAbout = "This is all about BlockHub.";
const projectMinContributionGoal = 1000000000000000000;
const projectMaxContributionGoal = 10000000000000000000;
const projectContributionPeriod = 4;
const noRefunds = false;
const noTimeline = false;

const projectMilestone0Percentage = 20;

function advanceTime(numWeeks) {
    const week = 604800000;
    const currentTime = new Date().getTime();
    return new Date(currentTime + numWeeks * week).getTime();
}

contract('Contribution', function(accounts) {
    let fundingStorage;
    let fundingVault;
    let curationContract;
    let curatorAddress;
    let contributionContract;
    let contributorAccount;
    let projectRegistrationContract;
    let projectTimelineContract;
    let projectContributionTierContract;
    let projectMilestoneCompletionContract;
    let projectMilestoneCompletionVotingContract;
    let developerContract;
    let developerAccount;
    let developerId;
    let projectId;

    before(async () => {
        fundingStorage = await FundingStorage.deployed();
        fundingVault = await FundingVault.deployed();
        await fundingStorage.registerContract("FundingVault", blankAddress, fundingVault.address);

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

        projectRegistrationContract = await ProjectRegistration.deployed();
        await fundingStorage.registerContract("ProjectRegistration", blankAddress, projectRegistrationContract.address);
        await projectRegistrationContract.initialize();

        projectTimelineContract = await ProjectTimeline.deployed();
        await fundingStorage.registerContract("ProjectTimeline", blankAddress, projectTimelineContract.address);

        projectContributionTierContract = await ProjectContributionTier.deployed();
        await fundingStorage.registerContract("ProjectContributionTier", blankAddress, projectContributionTierContract.address);

        projectMilestoneCompletionContract = await ProjectMilestoneCompletion.deployed();
        await fundingStorage.registerContract("ProjectMilestoneCompletion", blankAddress, projectMilestoneCompletionContract.address);

        projectMilestoneCompletionVotingContract = await ProjectMilestoneCompletionVoting.deployed();
        await fundingStorage.registerContract("ProjectMilestoneCompletionVoting", blankAddress, projectMilestoneCompletionVotingContract.address);

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
        await projectRegistrationContract.setProjectTerms(projectId, noRefunds, noTimeline, { from: developerAccount });

        await projectTimelineContract.addMilestone(projectId, "Milestone Title", "Milestone Description", projectMilestone0Percentage, { from: developerAccount });
        await projectTimelineContract.addMilestone(projectId, "Milestone Title", "Milestone Description", 30, { from: developerAccount });
        await projectTimelineContract.addMilestone(projectId, "Milestone Title", "Milestone Description", 50, { from: developerAccount });
        await projectContributionTierContract.addContributionTier(projectId, 1000, 100, 10, "Rewards!", { from: developerAccount });
        await projectRegistrationContract.submitProjectForReview(projectId, { from: developerAccount });
        await curationContract.curate(projectId, true, { from: curatorAddress });
    });

    it("should deploy the contribution contract", async () => {
        try {
            assert.ok(contributionContract.address);
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("user should be able to contribute to a project", async () => {
        try {
            await curationContract.setTestTime(advanceTime(4.1));
            await curationContract.publishProject(projectId, { from: developerAccount });

            const fundsToContribute = 10;

            const initialProjectFundsRaised = await contributionContract.getProjectFundsRaised(projectId);

            await contributionContract.contributeToProject(projectId, { from: contributorAccount, value: fundsToContribute });

            const newProjectFundsRaised = await contributionContract.getProjectFundsRaised(projectId);

            assert.equal(newProjectFundsRaised.toNumber(), initialProjectFundsRaised.toNumber() + fundsToContribute, "Project funds incorrect.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("user should be able to contribute to the same project more than once", async () => {
        try {
            await curationContract.setTestTime(advanceTime(4.1));
            await curationContract.publishProject(projectId, { from: developerAccount });

            const fundsToContribute = 10;

            const initialProjectFundsRaised = await contributionContract.getProjectFundsRaised(projectId);

            await contributionContract.contributeToProject(projectId, { from: contributorAccount, value: fundsToContribute });
            await contributionContract.contributeToProject(projectId, { from: contributorAccount, value: fundsToContribute });

            const newProjectFundsRaised = await contributionContract.getProjectFundsRaised(projectId);

            assert.equal(newProjectFundsRaised.toNumber(), initialProjectFundsRaised.toNumber() + fundsToContribute * 2, "Project funds incorrect.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("contribution value should be greater than 0", async () => {
        try {
            await curationContract.setTestTime(advanceTime(4.1));
            await curationContract.publishProject(projectId, { from: developerAccount });

            const fundsToContribute = 0;

            await contributionContract.contributeToProject(projectId, { from: contributorAccount, value: fundsToContribute });

            assert.fail();
        } catch (e) {
            console.log(e.message);
        }
    });

    it("should not be able to contribute to a project in a non-contributable state", async () => {
        try {
            const fundsToContribute = 0;

            await contributionContract.contributeToProject(projectId, { from: contributorAccount, value: fundsToContribute });

            assert.fail();
        } catch (e) {
            console.log(e.message);
        }
    });

    it("should not be able to contribute an amount that would exceed maximum goal", async () => {
        try {
            await curationContract.setTestTime(advanceTime(4.1));
            await curationContract.publishProject(projectId, { from: developerAccount });

            const fundsToContribute = projectMaxContributionGoal + 1;

            await contributionContract.contributeToProject(projectId, { from: contributorAccount, value: fundsToContribute });

            assert.fail();
        } catch (e) {
            console.log(e.message);
        }
    });

    it("contributor should be able to refund full contribution from Refundable project that does not meet funding goal.", async () => {
        try {
            await curationContract.setTestTime(advanceTime(4.1));
            await curationContract.publishProject(projectId, { from: developerAccount });

            const fundsToContribute = projectMinContributionGoal - 100;

            await contributionContract.contributeToProject(projectId, { from: contributorAccount, value: fundsToContribute });

            const initialContributorBalance = web3.eth.getBalance(contributorAccount);

            await projectRegistrationContract.setTestTime(advanceTime(projectContributionPeriod + 0.1));
            await projectRegistrationContract.beginProjectDevelopment(projectId, { from: developerAccount });

            let refundRecipient;
            let refundAmount;

            let vaultWatcher = fundingVault.EthWithdrawn().watch(function (error, result) {
                if (!error) {
                    refundRecipient = result.args.receiver;
                    refundAmount = result.args.amount.toNumber();
                }
            });

            await contributionContract.refund(projectId, { from: contributorAccount });

            vaultWatcher.stopWatching();

            assert.equal(refundRecipient, contributorAccount, "Refund went to wrong recipient.");
            assert.equal(refundAmount, fundsToContribute, "Refund was for wrong amount.");

            const newContributorBalance = web3.eth.getBalance(contributorAccount);

            assert.closeTo(newContributorBalance.toNumber(), initialContributorBalance.toNumber() + fundsToContribute, 6000000000000000, "Contributor balance incorrect after refund.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("contributor should be able to refund a portion of contribution from Refundable project that has already used some funds.", async () => {
        try {
            await curationContract.setTestTime(advanceTime(4.1));
            await curationContract.publishProject(projectId, { from: developerAccount });

            const fundsToContribute = projectMinContributionGoal;

            await contributionContract.contributeToProject(projectId, { from: contributorAccount, value: fundsToContribute });
            await contributionContract.contributeToProject(projectId, { from: accounts[4], value: fundsToContribute });
            await contributionContract.contributeToProject(projectId, { from: accounts[5], value: fundsToContribute });
            await contributionContract.contributeToProject(projectId, { from: accounts[6], value: fundsToContribute });

            const initialContributorBalance = web3.eth.getBalance(contributorAccount);

            await projectRegistrationContract.setTestTime(advanceTime(projectContributionPeriod + 0.1));
            await projectRegistrationContract.beginProjectDevelopment(projectId, { from: developerAccount });

            await projectMilestoneCompletionContract.submitMilestoneCompletion(projectId, "Report", { from: developerAccount });

            await projectMilestoneCompletionVotingContract.vote(projectId, false, { from: contributorAccount });
            await projectMilestoneCompletionVotingContract.vote(projectId, false, { from: accounts[4] });
            await projectMilestoneCompletionVotingContract.vote(projectId, false, { from: accounts[5] });
            await projectMilestoneCompletionVotingContract.vote(projectId, false, { from: accounts[6] });

            await projectMilestoneCompletionVotingContract.setTestTime(advanceTime(2.1));
            await projectMilestoneCompletionVotingContract.finalizeVoting(projectId, { from: developerAccount });

            let refundRecipient;
            let refundAmount;

            let vaultWatcher = fundingVault.EthWithdrawn().watch(function (error, result) {
                if (!error) {
                    refundRecipient = result.args.receiver;
                    refundAmount = result.args.amount.toNumber();
                }
            });

            await contributionContract.refund(projectId, { from: contributorAccount });

            vaultWatcher.stopWatching();

            let expectedRefundAmount = fundsToContribute * (100 - projectMilestone0Percentage) / 100;

            assert.equal(refundRecipient, contributorAccount, "Refund went to wrong recipient.");
            assert.equal(refundAmount, expectedRefundAmount, "Refund was for wrong amount.");

            const newContributorBalance = web3.eth.getBalance(contributorAccount);

            assert.closeTo(newContributorBalance.toNumber(), initialContributorBalance.toNumber() + expectedRefundAmount, 14518000000000000, "Contributor balance incorrect after refund.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("non-project contributor should not be able to refund money from Refundable project.", async () => {
        try {
            await curationContract.setTestTime(advanceTime(4.1));
            await curationContract.publishProject(projectId, { from: developerAccount });

            const fundsToContribute = projectMinContributionGoal - 1;

            await contributionContract.contributeToProject(projectId, { from: contributorAccount, value: fundsToContribute });

            await projectRegistrationContract.setTestTime(advanceTime(projectContributionPeriod + 0.1));
            await projectRegistrationContract.beginProjectDevelopment(projectId, { from: developerAccount });

            await contributionContract.refund(projectId, { from: accounts[4] });
            assert.fail();
        } catch (e) {
            console.log(e.message);
        }
    });

    it("contributor should not be able to refund money from non-Refundable project.", async () => {
        try {
            await curationContract.setTestTime(advanceTime(4.1));
            await curationContract.publishProject(projectId, { from: developerAccount });

            await contributionContract.contributeToProject(projectId, { from: contributorAccount, value: 10000 });

            await contributionContract.refund(projectId, { from: contributorAccount });
            assert.fail();
        } catch (e) {
            console.log(e.message);
        }
    });
});
