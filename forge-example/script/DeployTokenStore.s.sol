// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {TokenStore} from "../src/TokenStore.sol";
import {TestToken} from "../src/TestToken.sol";

contract DeployStore is Script {
    uint256 internal OWNER_PK;
    address internal TOKEN_ADDR;

    function setUp() public {
        OWNER_PK  = vm.envUint("OWNER_PK");
        TOKEN_ADDR = vm.envAddress("TOKEN_ADDR");
    }

    function run() public {
        address owner = vm.addr(OWNER_PK);

        vm.startBroadcast(OWNER_PK);
        TokenStore store = new TokenStore(TOKEN_ADDR, owner);
        vm.stopBroadcast();

        console.log("== DeployStore ==");
        console.log("Owner:", owner);
        console.log("Token:", TOKEN_ADDR);
        console.log("Store:", address(store));
        console.log("Store balance (token):", TestToken(TOKEN_ADDR).balanceOf(address(store)));
    }
}
