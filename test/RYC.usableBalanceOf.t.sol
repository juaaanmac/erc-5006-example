// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/console.sol";
import "forge-std/Test.sol";
import {RYC} from "src/RYC.sol";
import {IERC5006} from "src/interfaces/IERC5006.sol";
import {RYCTest} from "./RYC.t.sol";

contract RYCUsableBalanceOfTest is RYCTest {
    function testRevertByNotImplementedFunction() public {
        uint64 amountToMint = 10;
        uint64 expiry = 5;
        uint256 recordId = _createUserRecord(_OWNER, _USER, amountToMint, expiry);

        uint64 mintedTokendId = 1;

        vm.prank(_OWNER);
        vm.expectRevert("Not implemented yet");
        ryc.usableBalanceOf(_OWNER, mintedTokendId);
    }
}
