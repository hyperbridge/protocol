pragma solidity ^0.4.24;

interface IVoting {
    function vote(uint _projectId, bool _vote) external;

    function finalizeVoting(uint _projectId) external;
}
