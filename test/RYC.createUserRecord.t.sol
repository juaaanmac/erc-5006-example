// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/console.sol";
import "forge-std/Test.sol";
import {RYC} from "src/RYC.sol";
import {IERC5006} from "src/interfaces/IERC5006.sol";
import {RYCTest} from "./RYC.t.sol";

contract RYCCreateUserRecordTest is RYCTest {
    event CreateUserRecord(
        uint256 recordId, uint256 tokenId, uint64 amount, address owner, address user, uint64 expiry
    );

    function testRevertIfUserAddressIsZero() public {
        address zeroAddress = address(0);
        vm.expectRevert("RYC: `user` cannot be the zero address");
        ryc.createUserRecord(_OWNER, zeroAddress, 1, 1, 1);
    }

    function testRevertIfAmountIsZero() public {
        uint64 amountToMint = 0;
        vm.expectRevert("RYC: `amount` must be greater than 0");
        ryc.createUserRecord(_OWNER, _USER, 1, amountToMint, 1);
    }

    function testRevertIfExpiryIsInvalid() public {
        uint64 invalidExpiry = uint64(block.timestamp);
        vm.expectRevert("RYC: `expiry` must after the block timestamp");
        ryc.createUserRecord(_OWNER, _USER, 1, 1, invalidExpiry);
    }

    function testRevertIfBalanceIsInsufficient() public {
        vm.expectRevert("RYC: `owner` must have a balance of tokens of type `id` of at least `amount`");
        ryc.createUserRecord(_OWNER, _USER, 1, 1, 2);
    }

    function testRevertIfCallerIsNotOwnerOrApproved() public {
        address owner = _OWNER;
        address user = _USER;

        vm.prank(owner);
        uint256 tokendId = ryc.mintCar(1);

        vm.expectRevert("If the caller is not `owner`, it must be have been approved to spend ``owner``'s tokens");
        ryc.createUserRecord(owner, user, tokendId, 1, 2);
    }

    function testCreateUserRecord() public {
        _createUserRecord(_OWNER, _USER, 1, 2);
    }

    function testTransferFrom() public {
        uint64 amountToMint = 10;
        uint64 expiry = 5;
        _createUserRecord(_OWNER, _USER, amountToMint, expiry);

        uint256 mintedTokendId = 1;
        uint256 newBalance = ryc.balanceOf(address(ryc), mintedTokendId);
        assertEq(newBalance, amountToMint, "Transfered Amount");
    }

    function testFrozenBalance() public {
        uint64 amountToMint = 10;
        uint64 expiry = 5;
        _createUserRecord(_OWNER, _USER, amountToMint, expiry);

        uint256 mintedTokendId = 1;
        uint256 newFrozenBalance = ryc.frozenBalanceOf(_OWNER, mintedTokendId);
        assertEq(newFrozenBalance, amountToMint, "Frozen Amount");
    }

    function testUserRecord() public {
        uint64 amountToMint = 10;
        uint64 expiry = 5;
        uint256 recordId = _createUserRecord(_OWNER, _USER, amountToMint, expiry);
        IERC5006.UserRecord memory userRecord = ryc.userRecordOf(recordId);

        assertEq(userRecord.owner, _OWNER, "Owner");
        assertEq(userRecord.user, _USER, "User");
        assertEq(userRecord.amount, amountToMint, "Amount");
        assertEq(userRecord.expiry, expiry, "Expiry");

        uint256 mintedTokendId = 1;
        assertEq(userRecord.tokenId, mintedTokendId, "Token Id");
    }

    function testCreateUserRecordEvent() public {
        uint64 amountToMint = 10;
        uint64 expiry = 5;

        vm.prank(_OWNER);
        uint256 tokendId = ryc.mintCar(amountToMint);

        vm.expectEmit(true, true, true, false);
        emit CreateUserRecord(5, tokendId, amountToMint, _OWNER, _USER, expiry);

        vm.prank(_OWNER);
        ryc.createUserRecord(_OWNER, _USER, tokendId, amountToMint, expiry);
    }
}
