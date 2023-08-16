// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/console.sol";
import "forge-std/Test.sol";
import {RYC} from "../src/RYC.sol";
import {RYCTest} from "./RYC.t.sol";

contract RYCMintTest is RYCTest {
    function testUri() public {
        assertEq(ryc.uri(0), _URI, "URI");
    }

    function testMint() public {
        uint256 amountToMint = 5e18;
        address user = vm.addr(2);
        vm.prank(user);

        uint256 tokendId = ryc.mintCar(amountToMint);
        assertEq(ryc.balanceOf(user, tokendId), amountToMint, "Balance");
    }

    function testMintIncrement() public {
        uint256 amountToMint = 5e18;
        address user = vm.addr(2);

        vm.prank(user);
        uint256 tokendId = ryc.mintCar(amountToMint);
        assertEq(tokendId, 1);
        assertEq(ryc.balanceOf(user, tokendId), amountToMint, "Balance 1");

        vm.prank(user);
        tokendId = ryc.mintCar(amountToMint);
        assertEq(tokendId, 2);
        assertEq(ryc.balanceOf(user, tokendId), amountToMint, "Balance 2");
    }
}
