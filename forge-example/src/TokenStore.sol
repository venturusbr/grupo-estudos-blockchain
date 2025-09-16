// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./TestToken.sol";

contract TokenStore {
    TestToken public token;
    address public owner;

    uint256 public itemPrice = 100 * 10**18;
    uint256 public perAddressDailyLimit = 500 * 10**18;

    struct Window {
        uint256 windowStart;
        uint256 spentInWindow;
    }
    mapping(address => Window) private spendWindow;

    event Purchase(address indexed buyer, uint256 amountPaid, uint256 newSpentInWindow);
    event Withdraw(address indexed to, uint256 amount);
    event OwnerChanged(address indexed previous, address indexed current);
    event ItemPriceChanged(uint256 previous, uint256 current);
    event LimitChanged(uint256 previous, uint256 current);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    constructor(address tokenAddress, address _owner) {
        require(tokenAddress != address(0), "token=0");
        require(_owner != address(0), "owner=0");
        token = TestToken(tokenAddress);
        owner = _owner;
        emit OwnerChanged(address(0), _owner);
    }

    function purchaseItem() external {
        _enforceLimit(msg.sender, itemPrice);

        bool ok = token.transfer(msg.sender, address(this), itemPrice);
        require(ok, "Transfer failed");

        Window storage w = spendWindow[msg.sender];
        w.spentInWindow += itemPrice;

        emit Purchase(msg.sender, itemPrice, w.spentInWindow);
    }

    function storeTokens(uint256 amount) external {
        require(amount > 0, "amount=0");
        bool ok = token.transfer(msg.sender, address(this), amount);
        require(ok, "Transfer failed");
    }

    function withdraw(address to, uint256 amount) external onlyOwner {
        require(to != address(0), "to=0");
        bool ok = token.transfer(address(this), to, amount);
        require(ok, "Withdraw transfer failed");
        emit Withdraw(to, amount);
    }

    function setItemPrice(uint256 newPrice) external onlyOwner {
        emit ItemPriceChanged(itemPrice, newPrice);
        itemPrice = newPrice;
    }

    function setPerAddressDailyLimit(uint256 newLimit) external onlyOwner {
        emit LimitChanged(perAddressDailyLimit, newLimit);
        perAddressDailyLimit = newLimit;
    }

    function transferStoreOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "newOwner=0");
        emit OwnerChanged(owner, newOwner);
        owner = newOwner;
    }

    function getStoredBalance() external view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function getSpentInCurrentWindow(address buyer) external view returns (uint256 spent, uint256 windowStart) {
        Window memory w = _currentWindow(buyer);
        return (w.spentInWindow, w.windowStart);
    }

    function _enforceLimit(address buyer, uint256 toSpend) internal {
        Window memory w = _currentWindow(buyer);
        require(w.spentInWindow + toSpend <= perAddressDailyLimit, "Daily limit exceeded");

        Window storage ws = spendWindow[buyer];
        if (ws.windowStart != w.windowStart) {
            ws.windowStart = w.windowStart;
            ws.spentInWindow = w.spentInWindow;
        }
    }

    function _currentWindow(address buyer) internal view returns (Window memory w) {
        w = spendWindow[buyer];
        uint256 nowDay = block.timestamp / 1 days;
        uint256 start = nowDay * 1 days;

        if (w.windowStart < start) {
            w.windowStart = start;
            w.spentInWindow = 0;
        }
    }
}
