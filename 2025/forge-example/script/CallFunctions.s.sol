// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {TestToken} from "../src/TestToken.sol";
import {TokenStore} from "../src/TokenStore.sol";

contract CallFunctionsDemo is Script {
    uint256 internal OWNER_PK;
    uint256 internal ALICE_PK;
    uint256 internal BOB_PK;

    function setUp() public {
        OWNER_PK = vm.envUint("OWNER_PK");
        ALICE_PK = vm.envUint("ALICE_PK");
        BOB_PK = vm.envUint("BOB_PK");
    }

    function run() public {
        address owner = vm.addr(OWNER_PK);
        address alice = vm.addr(ALICE_PK);
        address buyer = vm.addr(BOB_PK);

        vm.startBroadcast(OWNER_PK);
        TestToken token = new TestToken("TestToken", "TTK", 18, 1_000, owner);
        TokenStore store = new TokenStore(address(token), owner);
        console.log("Deployed Token  :", address(token));
        console.log("Deployed Store  :", address(store));
        vm.stopBroadcast();

        vm.startBroadcast(OWNER_PK);
        token.mint(alice, 250 * 1e18);
        console.log("Mint -> Alice ok. Alice:", token.balanceOf(alice));
        vm.stopBroadcast();

        vm.startBroadcast(ALICE_PK);
        bool t1 = token.transfer(alice, buyer, 50 * 1e18);
        console.log("Alice -> Buyer transfer ok?", t1);
        vm.stopBroadcast();

        vm.startBroadcast(OWNER_PK);
        store.setItemPrice(100 * 1e18);
        store.setPerAddressDailyLimit(300 * 1e18);
        vm.stopBroadcast();

        vm.startBroadcast(BOB_PK);
        vm.stopBroadcast();
        vm.startBroadcast(OWNER_PK);
        token.mint(buyer, 1_000 * 1e18);
        vm.stopBroadcast();

        vm.startBroadcast(BOB_PK);
        store.purchaseItem();
        console.log("Buyer comprou 1 item. Buyer:", token.balanceOf(buyer), "Store:", token.balanceOf(address(store)));
        store.storeTokens(20 * 1e18);
        console.log("Buyer depositou 20 TTK. Store:", token.balanceOf(address(store)));
        vm.stopBroadcast();

        vm.startBroadcast(OWNER_PK);
        store.withdraw(owner, 50 * 1e18);
        console.log("Owner sacou 50. Owner:", token.balanceOf(owner), "Store:", token.balanceOf(address(store)));
        vm.stopBroadcast();
    }
}
