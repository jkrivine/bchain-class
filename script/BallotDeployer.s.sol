// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {Ballot} from "../src/Ballot.sol";

// To deploy:
// forge script --private-key <private_key> BallotDeployer \\
// --rpc-url https://polygon-mumbai.g.alchemy.com/v2/<API_KEY> --verify --etherscan-api-key <[chain]scan_api> --verifier-url <verifiyer_url: e.g https://api-testnet.polygonscan.com/api> \\
// --broadcast

contract BallotDeployer is Script {
    Ballot public ballot;

    function run() public {
        vm.broadcast();
        ballot = new Ballot();
    }
}
