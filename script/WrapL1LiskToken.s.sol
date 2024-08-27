// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Script} from "../lib/forge-std/src/Script.sol";
import {Wrap_L1LiskToken} from "../src/L1/WrapL1LiskToken.sol";

contract WrapL1LiskToken is Script {
    Wrap_L1LiskToken public wraped;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        wraped = new Wrap_L1LiskToken();

        vm.stopBroadcast();
    }
}
