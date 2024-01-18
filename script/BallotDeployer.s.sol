// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {Ballot} from "../src/Ballot.sol";

contract BallotDeployer is Script {
    Ballot public ballot;

    function run() public {
        vm.broadcast();
        ballot = new Ballot();
    }
}
