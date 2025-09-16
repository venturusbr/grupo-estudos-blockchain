// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {TestToken} from "../src/TestToken.sol";
import {TokenStore} from "../src/TokenStore.sol";

contract PurchaseLimitDemo is Script {
    uint256 internal OWNER_PK;
    uint256 internal BOB_PK;

    function setUp() public {
        OWNER_PK = vm.envUint("OWNER_PK");
        BOB_PK = vm.envUint("BOB_PK");
    }

    function run() public {
        address owner = vm.addr(OWNER_PK);
        address buyer = vm.addr(BOB_PK);

        vm.startBroadcast(OWNER_PK);
        TestToken token = new TestToken("TestToken","TTK",18,10_000, owner);
        TokenStore store = new TokenStore(address(token), owner);
        console.log("Token:", address(token));
        console.log("Store:", address(store));

        store.setItemPrice(100 * 1e18);
        store.setPerAddressDailyLimit(250 * 1e18);

        token.mint(buyer, 1_000 * 1e18);
        console.log("Buyer balance before:", token.balanceOf(buyer));

        vm.stopBroadcast();

        vm.startBroadcast(BOB_PK);
        store.purchaseItem();
        store.purchaseItem();

        console.log("Buyer balance after 2 compras:", token.balanceOf(buyer));
        console.log("Store balance:", token.balanceOf(address(store)));

        try store.purchaseItem() {
            console.log("3rd purchase unexpectedly succeeded");
        } catch Error(string memory reason) {
            console.log("3rd purchase reverted as expected:", reason);
        } catch {
            console.log("3rd purchase reverted (no reason)");
        }

        uint256 ts = block.timestamp;
        vm.warp(ts + 1 days + 1); // garante nova janela
        console.log("Warped to:", block.timestamp);

        store.purchaseItem();
        console.log("Buyer balance after day change:", token.balanceOf(buyer));
        console.log("Store balance:", token.balanceOf(address(store)));

        vm.stopBroadcast();

        vm.startBroadcast(OWNER_PK);
        uint256 withdrawAmount = 150 * 1e18;
        bool ok = token.transfer(address(store), owner, withdrawAmount);
        console.log("Direct withdraw transfer ok?", ok);
        console.log("Owner balance:", token.balanceOf(owner));
        console.log("Store balance:", token.balanceOf(address(store)));
        vm.stopBroadcast();
    }
}
