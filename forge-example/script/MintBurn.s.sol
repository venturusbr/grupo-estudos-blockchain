// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {TestToken} from "../src/TestToken.sol";

contract MintBurnDemo is Script {
    uint256 internal OWNER_PK;
    uint256 internal ALICE_PK;

    function setUp() public {
        OWNER_PK = vm.envUint("OWNER_PK");
        ALICE_PK = vm.envUint("ALICE_PK");
    }

    function run() public {
        address owner = vm.addr(OWNER_PK);
        address alice = vm.addr(ALICE_PK);

        vm.startBroadcast(OWNER_PK);
        TestToken token = new TestToken(
            "TestToken",
            "TTK",        
            18,           
            1_000,        
            owner         
        );
        console.log("Token:", address(token));
        console.log("Owner :", owner);
        console.log("Alice :", alice);

        uint256 mintAmount = 250 * 1e18;
        token.mint(alice, mintAmount);
        console.log("Minted to Alice:", mintAmount);
        console.log("Alice balance :", token.balanceOf(alice));
        console.log("totalSupply    :", token.totalSupply());

        vm.stopBroadcast();
        vm.startBroadcast(ALICE_PK);
        uint256 transferAmount = 50 * 1e18;
        bool ok = token.transfer(alice, owner, transferAmount);
        console.log("Alice -> Owner transfer ok?", ok);
        console.log("Owner balance :", token.balanceOf(owner));
        console.log("Alice balance :", token.balanceOf(alice));

        uint256 burnAmount = 10 * 1e18;
        token.burn(burnAmount);
        console.log("Alice burned  :", burnAmount);
        console.log("Alice balance :", token.balanceOf(alice));
        console.log("totalSupply    :", token.totalSupply());

        vm.stopBroadcast();
    }
}
