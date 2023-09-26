// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.5;

import {Script} from "forge-std/Script.sol";
import "../src/guard.sol";
import "../src/BadERC20.sol";

contract deployStakerFactory is Script {
    customeGuard public guard;
    BadActors public baddies;
    address public deployer;

    function run() public returns (customeGuard, BadActors) {
        vm.startBroadcast();
        baddies = new BadActors();
        guard = new customeGuard(address(baddies));
        vm.stopBroadcast();
        return (guard, baddies);
    }
}
