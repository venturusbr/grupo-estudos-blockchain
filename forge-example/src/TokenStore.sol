pragma solidity ^0.8.20;

import "./TestToken.sol";

contract TokenStore {
    TestToken public token;
    address public owner;
    uint256 public itemPrice = 100 * 10 ** 18;

    constructor(address tokenAddress) {
        token = TestToken(tokenAddress);
    }

    event Purchase(address indexed buyer, uint256 amount);

    function purchaseItem() public {
        require(token.transfer(msg.sender, address(this), itemPrice), "Transfer failed");
        emit Purchase(msg.sender, itemPrice);
    }

    function storeTokens(uint256 amount) public {
        require(token.transfer(msg.sender, address(this), amount), "Transfer failed");
    }

    function getStoredBalance() public view returns (uint256) {
        return token.balanceOf(address(this));
    }
}
