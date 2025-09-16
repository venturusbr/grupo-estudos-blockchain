// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./TestToken.sol";

contract TokenFactory {
    address public owner;
    address[] public allTokens;

    event OwnerChanged(address indexed previous, address indexed current);
    event TokenCreated(address indexed token, address indexed tokenOwner, string name, string symbol, uint8 decimals, uint256 initialSupply);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    constructor(address _owner) {
        require(_owner != address(0), "owner=0");
        owner = _owner;
        emit OwnerChanged(address(0), _owner);
    }

    function createToken(
        string calldata name,
        string calldata symbol,
        uint8 decimals,
        uint256 initialSupply,
        address tokenOwner
    ) external onlyOwner returns (address tokenAddr) {
        TestToken t = new TestToken(name, symbol, decimals, initialSupply, tokenOwner);
        tokenAddr = address(t);
        allTokens.push(tokenAddr);
        emit TokenCreated(tokenAddr, tokenOwner, name, symbol, decimals, initialSupply);
    }

    function tokensCount() external view returns (uint256) {
        return allTokens.length;
    }

    function transferFactoryOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "newOwner=0");
        emit OwnerChanged(owner, newOwner);
        owner = newOwner;
    }
}
