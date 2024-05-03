pragma solidity ^0.8.0;

contract Voting {
    struct Candidate {
        string name;
        uint voteCount;
    }

    struct AuditLog {
        address actor;
        string action;
        string details;
        uint timestamp;
    }

    mapping(address => bool) public hasVoted;
    mapping(string => Candidate) public candidates;
    string[] public candidateNames;
    address public admin;
    AuditLog[] public auditLogs;

    event Voted(address indexed voter, string candidateName);
    event CandidateRegistered(string name);
    event AuditLogAdded(address indexed actor, string action, string details, uint timestamp);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Apenas o administrador pode executar esta operação");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function registerCandidate(string memory _name) external onlyAdmin {
        require(bytes(_name).length > 0, "O nome do candidato não pode estar vazio");
        require(bytes(candidates[_name].name).length == 0, "Este candidato já está registrado");

        candidates[_name] = Candidate(_name, 0);
        candidateNames.push(_name);

        emit CandidateRegistered(_name);
        _addAuditLog(msg.sender, "Registrar Candidato", _name);
    }

    function vote(string memory _candidateName) external {
        require(bytes(_candidateName).length > 0, "O nome do candidato não pode estar vazio");
        require(bytes(candidates[_candidateName].name).length > 0, "Este candidato não está registrado");
        require(!hasVoted[msg.sender], "Você já votou");

        candidates[_candidateName].voteCount++;
        hasVoted[msg.sender] = true;

        emit Voted(msg.sender, _candidateName);
        _addAuditLog(msg.sender, "Votar", _candidateName);
    }

    function getVoteCount(string memory _candidateName) external view returns (uint) {
        require(bytes(_candidateName).length > 0, "O nome do candidato não pode estar vazio");
        require(bytes(candidates[_candidateName].name).length > 0, "Este candidato não está registrado");

        return candidates[_candidateName].voteCount;
    }

    function declareWinner() external view returns (string memory) {
        uint maxVotes = 0;
        string memory winnerName;

        for (uint i = 0; i < candidateNames.length; i++) {
            if (candidates[candidateNames[i]].voteCount > maxVotes) {
                maxVotes = candidates[candidateNames[i]].voteCount;
                winnerName = candidateNames[i];
            }
        }

        return winnerName;
    }

    function getAuditLogsCount() external view returns (uint) {
        return auditLogs.length;
    }

    function getAuditLog(uint index) external view returns (address, string memory, string memory, uint) {
        require(index < auditLogs.length, "Índice fora do intervalo");

        AuditLog memory log = auditLogs[index];
        return (log.actor, log.action, log.details, log.timestamp);
    }

    function _addAuditLog(address _actor, string memory _action, string memory _details) internal {
        auditLogs.push(AuditLog(_actor, _action, _details, block.timestamp));
        emit AuditLogAdded(_actor, _action, _details, block.timestamp);
    }
}
