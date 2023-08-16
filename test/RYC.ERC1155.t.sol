// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/console.sol";
import "forge-std/Test.sol";
import {RYC} from "src/RYC.sol";
import {IERC5006} from "src/interfaces/IERC5006.sol";
import {RYCTest} from "./RYC.t.sol";

contract RYCERC1155Test is RYCTest {
    function testOnERC1155Received() public {
        bytes4 selector = ryc.onERC1155Received(_OWNER, _USER, 1, 1, "");
        assertEq(selector, bytes4(0xf23a6e61));
    }

    function testOnERC1155BatchReceived() public {
        uint256[] memory ids = new uint256[](1);
        uint256[] memory values = new uint256[](1);
        bytes4 selector = ryc.onERC1155BatchReceived(_OWNER, _USER, ids, values, "");
        assertEq(selector, bytes4(0xbc197c81));
    }
}
