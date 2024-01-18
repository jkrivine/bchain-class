// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Ballot} from "../src/Ballot.sol";

contract BallotTest is Test {
    Ballot public ballot;

    receive() external virtual payable {}

    function setUp() public {
        ballot = new Ballot();
        address[] memory participants = new address[](3);
        participants[0] = address(this);
        participants[1] = vm.addr(1);
        participants[2] = vm.addr(2);
        ballot.open{value:1 ether}(0.01 ether, participants);
    }

    function test_vote() public {
        address voter1 = vm.addr(1);
        address voter2 = vm.addr(2);

        // this votes YES
        ballot.vote(0, Ballot.Vote.YES);

        uint bal_before = voter1.balance;
        vm.prank(voter1);
        ballot.vote(1, Ballot.Vote.ABS);
        assertEq(voter1.balance, bal_before + 0.01 ether);
                
        vm.prank(voter2);
        ballot.vote(2,Ballot.Vote.NO);
        
        assertEq(ballot.votes(Ballot.Vote.YES), 1);
        assertTrue(ballot.whitelist(0)==address(0));
    }

    function test_closeVote() public {
        ballot.closeVote();
        assertEq(ballot.refundPerVote(), 0);
        assertEq(ballot.participants(), 0);
    }
}
