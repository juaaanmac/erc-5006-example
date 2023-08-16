// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/console.sol";
import "forge-std/Test.sol";
import {RYC} from "src/RYC.sol";
import {IERC5006} from "src/interfaces/IERC5006.sol";

contract RYCTest is Test {
    RYC public ryc;
    string internal constant _URI = "https://uri.com";
    address internal constant _OWNER = address(1);
    address internal constant _USER = address(2);

    function setUp() public {
        ryc = new RYC(_URI);
    }

    function _createUserRecord(address owner, address user, uint64 amount, uint64 expiry) internal returns (uint256) {
        vm.prank(owner);
        uint256 tokendId = ryc.mintCar(amount);

        vm.prank(owner);
        return ryc.createUserRecord(owner, user, tokendId, amount, expiry);
    }

    function testSupportsInterface() public {
        bool supportsInterface = ryc.supportsInterface(type(IERC5006).interfaceId);
        assertEq(supportsInterface, true);
    }
}
