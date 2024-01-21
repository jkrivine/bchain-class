// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

///@title Voting contract that refunds voters for their gas processing costs.
///@dev This code is for pedagogical purpose and contains vulnerabilities. Do not use for anything else than teachning!

contract Ballot {
    enum Vote {
        ABS, // Abstain
        YES, // YES
        NO // NO
    }

    ///@notice Mapping of votes to their count.
    mapping(Vote vote => uint256 count) public votes;

    ///@notice List of addresses that are still allowed to vote.
    address[] public whitelist;

    ///@notice Amount of wei to refund to each voter.
    uint256 public refundPerVote;

    ///@notice Address of the admin of the contract.
    address public admin;

    ///@notice Event emitted when the admin is changed.
    event SetAdmin(address);

    ///@notice Event emitted when a vote is opened.
    event OpenVote(uint256 bounty, address[] whitelist);

    ///@notice Event emitted when a vote is cast.
    event LogVote(address voter, uint256 voterId, Vote t);

    ///@notice Event emitted when a vote is closed.
    event CloseVote(Vote winningVote);

    ///@notice Constructor that sets the admin to the deployer.
    constructor() {
        admin = msg.sender;
    }

    ///@notice Function to get the number of participants.
    function participants() external view returns (uint256) {
        return whitelist.length;
    }

    ///@notice Function to change the admin of the contract.
    ///@param admin_ Address of the new admin.
    function setAdmin(address admin_) external {
        require(admin_ != admin && admin != address(0), "Ballot/InvalidAdmin");
        admin = admin_;
        emit SetAdmin(admin_);
    }

    ///@notice Function to open a vote.
    ///@param bounty Bounty to be paid to each voter.
    ///@param whitelist_ List of addresses that are allowed to vote.
    function open(uint256 bounty, address[] calldata whitelist_) external payable {
        require(msg.sender == admin, "Ballot/Unauthorized");
        require(bounty * whitelist_.length <= msg.value, "Ballot/NotEnoughFunds");
        refundPerVote = bounty;
        whitelist = new address[](whitelist_.length);
        for (uint256 i; i < whitelist_.length; i++) {
            whitelist[i] = whitelist_[i];
        }
        emit OpenVote(bounty, whitelist_);
    }

    ///@notice Function to get the id of a voter.
    ///@param voter Address of the voter.
    ///@return id Id of the voter.
    function getId(address voter) external view returns (uint256 id) {
        for (uint256 i; i < whitelist.length; i++) {
            if (whitelist[i] == voter) {
                return i;
            }
        }
        require(false, "Ballot/NotFound");
    }

    ///@notice Function to close a vote.
    ///@return winningVote Vote that won. Vote ABS if there was a tie.
    ///@dev Refunds the admin for their gas processing costs.
    function closeVote() external returns (Vote winningVote) {
        require(msg.sender == admin, "Ballot/Unauthorized");
        (bool success,) = admin.call{value: address(this).balance}("");
        require(success, "Ballot/FailedToWithdraw");
        whitelist = new address[](0);
        winningVote =
            votes[Vote.YES] > votes[Vote.NO] ? Vote.YES : votes[Vote.YES] < votes[Vote.NO] ? Vote.NO : Vote.ABS;
        // reset votes mapping
        votes[Vote.YES] = 0;
        votes[Vote.NO] = 0;
        votes[Vote.ABS] = 0;
        refundPerVote = 0;
        emit CloseVote(winningVote);
    }

    ///@notice Function to vote.
    ///@param voterId Id of the voter.
    ///@param t Vote of the voter.
    ///@dev Refunds the voter for their gas processing costs according to the `refundPerVote` parameter.
    function vote(uint256 voterId, Vote t) external {
        require(whitelist[voterId] == msg.sender, "Ballot/Unauthorized");
        votes[t]++;
        whitelist[voterId] = address(0);
        emit LogVote(msg.sender, voterId, t);
        (bool success,) = msg.sender.call{value: refundPerVote}("");
        require(success, "Ballot/CouldNotRefundVoter");
    }
}
