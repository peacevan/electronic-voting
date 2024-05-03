// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Voting {
    struct Candidate {
        uint id;
        string name;
        uint voteCount;
    }

    struct Voter {
        bool hasVoted;
        uint votedCandidateId;
    }

    address public admin;
    mapping(address => Voter) public voters;
    mapping(uint => Candidate) public candidates;
    uint public candidatesCount;
    uint public totalVotes;

    event CandidateRegistered(uint indexed candidateId, string name);
    event VoteCast(address indexed voter, uint candidateId, string candidateName);
 

 
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this operation.");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function registerCandidate(string memory _name) public onlyAdmin {
        candidatesCount++;
        candidates[candidatesCount] = Candidate(candidatesCount, _name, 0);
        emit CandidateRegistered(candidatesCount, _name);
    }




    function getCandidateInfo(uint _candidateId) public view returns (uint, string memory, uint) {
        return (candidates[_candidateId].id, candidates[_candidateId].name, candidates[_candidateId].voteCount);
    }

    function getTotalVotes() public view returns (uint) {
        return totalVotes;
    }
}
