pragma solidity ^0.4.24;

contract Testable {
    modifier onlyTest() {
        require(isTest);
        _;
    }

    bool internal isTest;
    uint private testTime;

    constructor(bool _isTest) internal {
        isTest = _isTest;
    }

    function getCurrentTime() internal view returns (uint) {
        return isTest ? testTime : now;
    }

    function setTestTime(uint _time) external onlyTest {
        testTime = _time;
    }
}