// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/TestToken.sol";

contract TestTokenTest is Test {
    TestToken token;
    address owner = address(0xA11CE);
    address bob = address(0xB0B);

    function setUp() public {
        token = new TestToken("TestToken", "TTK", 18, 1000, owner);
    }

    function testInitialSupply() public view {
        assertEq(token.totalSupply(), 1000 * 1e18);
        assertEq(token.balanceOf(owner), 1000 * 1e18);
    }

    function testMintByOwner() public {
        vm.prank(owner);
        token.mint(bob, 200 * 1e18);
        assertEq(token.balanceOf(bob), 200 * 1e18);
    }

    function test_RevertWhen_NotOwnerMints() public {
        vm.expectRevert("Only owner"); // mesma mensagem do require no contrato
        token.mint(bob, 200 * 1e18);
    }

    function testTransfer() public {
        vm.startPrank(owner);
        token.transfer(owner, bob, 50 * 1e18);
        vm.stopPrank();

        assertEq(token.balanceOf(owner), 950 * 1e18);
        assertEq(token.balanceOf(bob), 50 * 1e18);
    }

    function testBurn() public {
        vm.startPrank(owner);
        token.burn(100 * 1e18);
        vm.stopPrank();

        assertEq(token.totalSupply(), 900 * 1e18);
        assertEq(token.balanceOf(owner), 900 * 1e18);
    }

    function testExpectEventOnMint() public {
        vm.expectEmit(true, true, false, true);
        emit TestToken.Mint(bob, 100 * 1e18);
        vm.prank(owner);
        token.mint(bob, 100 * 1e18);
    }
}
