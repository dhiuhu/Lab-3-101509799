// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LendingContract {
    mapping(address => uint256) public balances;
    mapping(address => uint256) public borrowings;

    function deposit(uint256 amount) public payable {
        require(amount > 0, "Amount must be greater than 0");
        balances[msg.sender] += amount;
    }

    function borrow(uint256 amount) external {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        borrowings[msg.sender] += amount;
        balances[msg.sender] -= amount;
    }

    function repay(uint256 amount) external {
        require(borrowings[msg.sender] >= amount, "Insufficient borrowings");
        borrowings[msg.sender] -= amount;
        balances[msg.sender] += amount;
    }
}
