// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/console.sol";
import "forge-std/Test.sol";
import {RYC} from "src/RYC.sol";
import {IERC5006} from "src/interfaces/IERC5006.sol";
import {RYCTest} from "./RYC.t.sol";

contract RYCDeleteUserRecordTest is RYCTest {
    event CreateUserRecord(
        uint256 recordId, uint256 tokenId, uint64 amount, address owner, address user, uint64 expiry
    );

    event DeleteUserRecord(uint256 recordId);

    function testRevertIfNoAllowance() public {
        uint64 amountToMint = 10;
        uint64 expiry = 5;
        uint256 recordId = _createUserRecord(_OWNER, _USER, amountToMint, expiry);

        vm.prank(_USER);
        vm.expectRevert("RYC: the caller must have allowance");
        ryc.deleteUserRecord(recordId);
    }

    function testDeleteUserRecord() public {
        uint256 recordId = _createUserRecord(_OWNER, _USER, 1, 2);

        vm.prank(_OWNER);
        ryc.deleteUserRecord(recordId);
    }

    function testTransferFrom() public {
        uint64 amountToMint = 10;
        uint64 expiry = 5;

        uint256 recordId = _createUserRecord(_OWNER, _USER, amountToMint, expiry);

        uint256 mintedTokendId = 1;
        uint256 balance = ryc.balanceOf(address(ryc), mintedTokendId);
        assertEq(balance, amountToMint, "RYC Transfered Amount before delete");

        vm.prank(_OWNER);
        ryc.deleteUserRecord(recordId);

        balance = ryc.balanceOf(address(ryc), mintedTokendId);
        assertEq(balance, 0, "RYC Transfered Amount after delete");

        uint256 userBalance = ryc.balanceOf(address(_OWNER), mintedTokendId);
        assertEq(userBalance, amountToMint, "User Transfered Amount after delete");
    }

    function testFrozenBalance() public {
        uint64 amountToMint = 10;
        uint64 expiry = 5;

        uint256 recordId = _createUserRecord(_OWNER, _USER, amountToMint, expiry);

        uint256 mintedTokendId = 1;
        uint256 frozenBalance = ryc.frozenBalanceOf(_OWNER, mintedTokendId);
        assertEq(frozenBalance, amountToMint, "Frozen Amount before delete");

        vm.prank(_OWNER);
        ryc.deleteUserRecord(recordId);

        frozenBalance = ryc.frozenBalanceOf(_OWNER, mintedTokendId);
        assertEq(frozenBalance, 0, "Frozen Amount after delete");
    }

    function testUserRecord() public {
        uint64 amountToMint = 10;
        uint64 expiry = 5;
        uint256 recordId = _createUserRecord(_OWNER, _USER, amountToMint, expiry);

        vm.prank(_OWNER);
        ryc.deleteUserRecord(recordId);

        IERC5006.UserRecord memory userRecord = ryc.userRecordOf(recordId);

        assertEq(userRecord.owner, address(0), "Owner");
        assertEq(userRecord.user, address(0), "User");
        assertEq(userRecord.amount, 0, "Amount");
        assertEq(userRecord.expiry, 0, "Expiry");
    }

    function testDeleteUserRecordEvent() public {
        uint64 amountToMint = 10;
        uint64 expiry = 5;
        uint256 recordId = _createUserRecord(_OWNER, _USER, amountToMint, expiry);

        vm.expectEmit(true, false, false, false);

        emit DeleteUserRecord(recordId);

        vm.prank(_OWNER);
        ryc.deleteUserRecord(recordId);
    }
}
