// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Ballot} from "../src/Ballot.sol";

contract BallotTest is Test {
    Ballot public ballot;
    event OpenVote(uint bounty, address[] whitelist);
    event LogVote(address voter, uint voterId, Ballot.Vote t);
    event CloseVote(Ballot.Vote winningVote);

    receive() external virtual payable {}

    function setUp() public {
        ballot = new Ballot();
        address[] memory participants = new address[](3);
        participants[0] = address(this);
        participants[1] = vm.addr(1);
        participants[2] = vm.addr(2);
        
        vm.expectEmit(true, true, true, true);
        emit OpenVote(0.01 ether, participants);

        ballot.open{value:1 ether}(0.01 ether, participants);
    }

    function test_vote() public {
        address voter1 = vm.addr(1);
        address voter2 = vm.addr(2);

        // this votes YES
        vm.expectEmit(true, true, true, true);
        emit LogVote(address(this), 0, Ballot.Vote.YES);
        ballot.vote(0, Ballot.Vote.YES);

        uint bal_before = voter1.balance;
        vm.prank(voter1);
        ballot.vote(1, Ballot.Vote.ABS);
        assertEq(voter1.balance, bal_before + 0.01 ether);
                
        vm.prank(voter2);
        ballot.vote(2,Ballot.Vote.NO);
        
        assertEq(ballot.votes(Ballot.Vote.YES), 1);
        assertTrue(ballot.whitelist(0)==address(0));

        vm.expectEmit(true, true, true, true);
        emit CloseVote(Ballot.Vote.ABS);

        Ballot.Vote winningVote = ballot.closeVote();
        assertEq(uint(winningVote), uint(Ballot.Vote.ABS));
    }
}
