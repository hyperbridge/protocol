const FundingStorage = artifacts.require("FundingStorage");
const Administration = artifacts.require("Administration");
const ProjectRegistration = artifacts.require("ProjectRegistration");
const Developer = artifacts.require("Developer");

const blankAddress = 0x0000000000000000000000000000000000000000;
const projectTitle = "BlockHub";
const projectDescription = "This is a description of BlockHub.";
const projectAbout = "This is all about BlockHub.";
const noRefunds = true;
const noTimeline = true;

contract('Administration', function(accounts) {
    let fundingStorage;
    let administrationContract;
    let projectRegistrationContract;
    let developerContract;
    let developerAccount;
    let developerId;
    let projectId;

    before(async () => {
        fundingStorage = await FundingStorage.deployed();

        administrationContract = await Administration.deployed();
        await fundingStorage.registerContract("Administration", blankAddress, administrationContract.address);

        projectRegistrationContract = await ProjectRegistration.deployed();
        await fundingStorage.registerContract("ProjectRegistration", blankAddress, projectRegistrationContract.address);
        await projectRegistrationContract.initialize();

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
    });

    it("should deploy the administration contract", async () => {
        try {
            assert.ok(administrationContract.address);
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("owner should be able to change project status manually", async () => {
        const newStatus = 2;

        try {
            let project = await projectRegistrationContract.getProject(projectId);

            assert.equal(project[1].toNumber(), 1, "Initial project status incorrect.");

            await administrationContract.setProjectStatus(projectId, newStatus);

            project = await projectRegistrationContract.getProject(projectId);

            assert.equal(project[1].toNumber(), newStatus, "Project status incorrect.");
        } catch (e) {
            console.log(e.message);
            assert.fail();
        }
    });

    it("non-owner should not be able to change project status manually", async () => {
        const newStatus = 2;

        try {
            let project = await projectRegistrationContract.getProject(projectId);

            assert.equal(project[1].toNumber(), 1, "Initial project status incorrect.");

            await administrationContract.setProjectStatus(projectId, newStatus, { from: accounts[1] });

            assert.fail();
        } catch (e) {
            console.log(e.message);
        }
    });
});
