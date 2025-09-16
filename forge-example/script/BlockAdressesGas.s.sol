// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {TestToken} from "../src/TestToken.sol";
import {TokenStore} from "../src/TokenStore.sol";

contract BlocksAddressesGasDemo is Script {
    uint256 internal OWNER_PK;
    uint256 internal BOB_PK;

    function setUp() public {
        OWNER_PK = vm.envUint("OWNER_PK");
        BOB_PK  = vm.envUint("BOB_PK");
    }

    function run() public {
        address owner = vm.addr(OWNER_PK);
        address user  = vm.addr(BOB_PK);

        vm.txGasPrice(10 gwei);

        console.log("== Contexto inicial ==");
        console.log("block.number :", block.number);
        console.log("block.time   :", block.timestamp);
        console.log("basefee      :", block.basefee);
        console.log("gasprice     :", tx.gasprice);

        vm.startBroadcast(OWNER_PK);
        uint256 g0 = gasleft();
        TestToken token = new TestToken("TestToken","TTK",18, 1_000, owner);
        uint256 g1 = gasleft();
        uint256 gasDeployToken = g0 - g1;
        console.log("Deployed Token:", address(token), "gas usado ~", gasDeployToken);

        g0 = gasleft();
        TokenStore store = new TokenStore(address(token), owner);
        g1 = gasleft();
        uint256 gasDeployStore = g0 - g1;
        console.log("Deployed Store:", address(store), "gas usado ~", gasDeployStore);

        vm.roll(block.number + 1);
        vm.warp(block.timestamp + 15);

        console.log("== Apos deploys ==");
        console.log("block.number :", block.number);
        console.log("block.time   :", block.timestamp);
        console.log("sender(owner):", msg.sender);
        vm.stopBroadcast();

        vm.startBroadcast(OWNER_PK);
        g0 = gasleft();
        token.mint(user, 500 * 1e18);
        g1 = gasleft();
        console.log("mint gas ~ %s", g0 - g1);
        console.log("user address:", user);
        console.log("user balance:", token.balanceOf(user));
        vm.stopBroadcast();

        vm.startBroadcast(BOB_PK);
        vm.stopBroadcast();
        vm.startBroadcast(OWNER_PK);
        store.setItemPrice(100 * 1e18);
        store.setPerAddressDailyLimit(1_000 * 1e18);
        vm.stopBroadcast();

        vm.startBroadcast(BOB_PK);
        g0 = gasleft();
        store.purchaseItem();
        g1 = gasleft();
        console.log("purchaseItem gas ~", (g0 - g1));
        console.log("buyer:", user, " store balance:", token.balanceOf(address(store)));
        console.log("tx.gasprice:", tx.gasprice);
        vm.stopBroadcast();

        console.log("== Addresses ==");
        console.log("owner:", owner);
        console.log("user :", user);
        console.log("token:", address(token));
        console.log("store:", address(store));
    }
}
