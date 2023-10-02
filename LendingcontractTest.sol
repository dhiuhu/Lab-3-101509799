// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/LendingContract.sol";

contract LendingContractTest {
    LendingContract lendingContract = LendingContract(DeployedAddresses.LendingContract());

    function testDeposit() public {
        uint256 initialBalance = lendingContract.balances(address(this));
        uint256 depositAmount = 100;

        lendingContract.deposit{value: depositAmount}(depositAmount);

        uint256 finalBalance = lendingContract.balances(address(this));

        Assert.equal(finalBalance, initialBalance + depositAmount, "Deposit amount incorrect");
    }

    function testBorrowAndRepay() public {
        uint256 initialBalance = lendingContract.balances(address(this));
        uint256 borrowAmount = 50;

        lendingContract.borrow(borrowAmount);

        uint256 borrowedAmount = lendingContract.borrowings(address(this));

        Assert.equal(borrowedAmount, borrowAmount, "Borrowed amount incorrect");

        lendingContract.repay(borrowAmount);

        uint256 finalBalance = lendingContract.balances(address(this));
        borrowedAmount = lendingContract.borrowings(address(this));

        Assert.equal(finalBalance, initialBalance, "Repay did not restore the balance");
        Assert.equal(borrowedAmount, 0, "Borrowed amount should be zero after repay");
    }

    function testBorrowInsufficientBalance() public {
        uint256 initialBalance = lendingContract.balances(address(this));
        uint256 borrowAmount = initialBalance + 1;

        (bool success, ) = address(lendingContract).call(
            abi.encodeWithSignature("borrow(uint256)", borrowAmount)
        );

        Assert.isFalse(success, "Borrow with insufficient balance should fail");
    }

    function testRepayInsufficientBorrowings() public {
        uint256 borrowAmount = 50;
        lendingContract.borrow(borrowAmount);

        uint256 repayAmount = borrowAmount + 1;

        (bool success, ) = address(lendingContract).call(
            abi.encodeWithSignature("repay(uint256)", repayAmount)
        );

        Assert.isFalse(success, "Repay with insufficient borrowings should fail");
    }
}
