// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {TokenFactory} from "../src/TokenFactory.sol";
import {TestToken} from "../src/TestToken.sol";

contract FactoryDemo is Script {
    uint256 internal FACTORY_OWNER_PK;
    uint256 internal TOKEN_OWNER_A_PK;
    uint256 internal TOKEN_OWNER_B_PK;

    function setUp() public {
        FACTORY_OWNER_PK = vm.envUint("FACTORY_OWNER_PK");
        TOKEN_OWNER_A_PK = vm.envUint("TOKEN_OWNER_A_PK");
        TOKEN_OWNER_B_PK = vm.envUint("TOKEN_OWNER_B_PK");
    }

    function run() public {
        address factoryOwner = vm.addr(FACTORY_OWNER_PK);
        address tokenOwnerA = vm.addr(TOKEN_OWNER_A_PK);
        address tokenOwnerB = vm.addr(TOKEN_OWNER_B_PK);

        vm.startBroadcast(FACTORY_OWNER_PK);
        TokenFactory factory = new TokenFactory(factoryOwner);
        console.log("Factory:", address(factory));

        address tokenA = factory.createToken("AlphaToken", "ALP", 18, 5_000, tokenOwnerA);
        console.log("Token A:", tokenA, "owner:", tokenOwnerA);

        address tokenB = factory.createToken("BetaToken", "BET", 6, 100_000, tokenOwnerB);
        console.log("Token B:", tokenB, "owner:", tokenOwnerB);

        console.log("Token A owner balance:", TestToken(tokenA).balanceOf(tokenOwnerA));
        console.log("Token B owner balance:", TestToken(tokenB).balanceOf(tokenOwnerB));
        console.log("Factory tokens count:", factory.tokensCount());

        vm.stopBroadcast();
    }
}
