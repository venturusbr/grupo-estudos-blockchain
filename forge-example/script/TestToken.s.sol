// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {TestToken} from "../src/TestToken.sol";
import {TokenStore} from "../src/TokenStore.sol";

contract TestTokenScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        TestToken testToken = new TestToken(1000);
        console.log("Contract deployed to:", address(testToken));

        TokenStore tokenStore = new TokenStore(address(testToken));
        console.log("Contract deployed to:", address(tokenStore));

        vm.stopBroadcast();
    }
}
