// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {TestToken} from "../src/TestToken.sol";

contract DeployToken is Script {
    uint256 internal OWNER_PK;

    string internal NAME = "TestToken";
    string internal SYMBOL = "TTK";
    uint8  internal DECIMALS = 18;
    uint256 internal INITIAL_SUPPLY = 1_000;

    function setUp() public {
        OWNER_PK = vm.envUint("OWNER_PK");
    }

    function run() public {
        address owner = vm.addr(OWNER_PK);

        vm.startBroadcast(OWNER_PK);
        TestToken token = new TestToken(NAME, SYMBOL, DECIMALS, INITIAL_SUPPLY, owner);
        vm.stopBroadcast();

        console.log("== DeployToken ==");
        console.log("Owner :", owner);
        console.log("Token :", address(token));
        console.log("Name  :", token.name());
        console.log("Symbol:", token.symbol());
        console.log("Dec   :", token.decimals());
        console.log("Supply:", token.totalSupply());
    }
}
