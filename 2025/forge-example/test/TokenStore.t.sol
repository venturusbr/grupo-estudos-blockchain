// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/TestToken.sol";
import "../src/TokenStore.sol";

contract TokenStoreTest is Test {
    TestToken token;
    TokenStore store;
    address owner = address(0xA11CE);
    address buyer = address(0xB0B);

    function setUp() public {
        token = new TestToken("TestToken", "TTK", 18, 10000, owner);
        store = new TokenStore(address(token), owner);

        vm.prank(owner);
        token.mint(buyer, 1000 * 1e18);

        vm.prank(owner);
        store.setItemPrice(100 * 1e18);
        vm.prank(owner);
        store.setPerAddressDailyLimit(250 * 1e18);

        vm.prank(buyer);
        token.approve(address(store), type(uint256).max);
    }

    function testPurchaseWithinLimit() public {
        vm.prank(buyer);
        store.purchaseItem();

        assertEq(token.balanceOf(buyer), 900 * 1e18);
        assertEq(token.balanceOf(address(store)), 100 * 1e18);
    }

    function test_RevertWhen_ExceedsDailyLimit() public {
        vm.prank(buyer);
        store.purchaseItem();
        vm.prank(buyer);
        store.purchaseItem();

        vm.prank(buyer);
        vm.expectRevert(bytes("Daily limit exceeded"));
        store.purchaseItem();
    }

    function testDailyLimitResets() public {
        vm.prank(buyer);
        store.purchaseItem();
        vm.prank(buyer);
        store.purchaseItem();

        vm.warp(block.timestamp + 1 days + 1);

        vm.prank(buyer);
        store.purchaseItem();
        assertEq(token.balanceOf(address(store)), 300 * 1e18);
    }

    function testWithdrawByOwner() public {
        vm.prank(buyer);
        store.purchaseItem();

        uint256 ownerBefore = token.balanceOf(owner);

        vm.prank(owner);
        store.withdraw(owner, 50 * 1e18);

        assertEq(token.balanceOf(owner), ownerBefore + 50 * 1e18);
        assertEq(token.balanceOf(address(store)), 50 * 1e18);
    }
}
