// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {TestToken} from "../src/TestToken.sol";
import {TokenStore} from "../src/TokenStore.sol";

contract StateChangesDemo is Script {
    uint256 internal OWNER_PK;
    uint256 internal USER_PK;

    function setUp() public {
        OWNER_PK = vm.envUint("OWNER_PK");
        USER_PK = vm.envUint("ALICE_PK");
    }

    function run() public {
        address owner = vm.addr(OWNER_PK);
        address user = vm.addr(USER_PK);

        vm.startBroadcast(OWNER_PK);
        TestToken token = new TestToken("TestToken", "TTK", 18, 500, owner);
        TokenStore store = new TokenStore(address(token), owner);
        store.setItemPrice(100 * 1e18);
        store.setPerAddressDailyLimit(250 * 1e18);
        vm.stopBroadcast();

        console.log("== Estado inicial ==");
        console.log("totalSupply:", token.totalSupply());
        console.log("owner      :", token.balanceOf(owner));
        console.log("user       :", token.balanceOf(user));
        console.log("store      :", token.balanceOf(address(store)));

        vm.startBroadcast(OWNER_PK);
        token.mint(user, 200 * 1e18);
        vm.stopBroadcast();

        console.log("== Apos mint (200 p/ user) ==");
        console.log("totalSupply:", token.totalSupply());
        console.log("owner      :", token.balanceOf(owner));
        console.log("user       :", token.balanceOf(user));

        vm.startBroadcast(USER_PK);
        store.purchaseItem();
        vm.stopBroadcast();

        console.log("== Apos 1 compra ==");
        console.log("user :", token.balanceOf(user));
        console.log("store:", token.balanceOf(address(store)));

        vm.startBroadcast(USER_PK);
        token.burn(25 * 1e18);
        vm.stopBroadcast();

        console.log("== Apos burn (25 do user) ==");
        console.log("totalSupply:", token.totalSupply());
        console.log("user       :", token.balanceOf(user));

        uint256 ts0 = block.timestamp;
        vm.warp(ts0 + 1 days + 1);

        console.log("== Apos warp 1 dia ==");
        console.log("timestamp:", block.timestamp);
        console.log("user     :", token.balanceOf(user));
        console.log("store    :", token.balanceOf(address(store)));
    }
}
