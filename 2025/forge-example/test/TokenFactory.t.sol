// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/TokenFactory.sol";
import "../src/TestToken.sol";

contract TokenFactoryTest is Test {
    TokenFactory factory;
    address factoryOwner = address(0xA11CE);
    address tokenOwnerA = address(0xB0B);
    address tokenOwnerB = address(0xC0C);

    function setUp() public {
        factory = new TokenFactory(factoryOwner);
    }

    function testCreateToken() public {
        vm.prank(factoryOwner);
        address tokenAddr = factory.createToken("Alpha", "ALP", 18, 5000, tokenOwnerA);
        TestToken token = TestToken(tokenAddr);

        assertEq(token.name(), "Alpha");
        assertEq(token.symbol(), "ALP");
        assertEq(token.balanceOf(tokenOwnerA), 5000 * 1e18);
        assertEq(factory.tokensCount(), 1);
    }

    function test_RevertWhen_NotOwnerCreatesToken() public {
        vm.expectRevert("Only owner");
        factory.createToken("Beta", "BET", 18, 1000, tokenOwnerB);
    }
}
