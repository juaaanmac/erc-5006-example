// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/console.sol";
import "openzeppelin-contracts/token/ERC1155/ERC1155.sol";
import "openzeppelin-contracts/token/ERC1155/utils/ERC1155Receiver.sol";
import "openzeppelin-contracts/utils/Counters.sol";
import {IERC5006} from "src/interfaces/IERC5006.sol";

contract RYC is ERC1155, ERC1155Receiver, IERC5006 {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;
    Counters.Counter private _recordIds;

    mapping(uint256 => UserRecord) _records;

    mapping(uint256 => mapping(address => uint256)) private _frozens;

    constructor(string memory uri_) ERC1155(uri_) {}

    function mintCar(uint256 amount) external returns (uint256) {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _mint(msg.sender, newItemId, amount, "");

        return newItemId;
    }

    function createUserRecord(address owner, address user, uint256 tokenId, uint64 amount, uint64 expiry)
        external
        returns (uint256)
    {
        // on mainnet, make require messages shorter to save gas
        require(user != address(0), "RYC: `user` cannot be the zero address");
        require(amount > 0, "RYC: `amount` must be greater than 0");
        require(expiry > block.timestamp, "RYC: `expiry` must after the block timestamp");
        require(
            balanceOf(owner, tokenId) >= amount,
            "RYC: `owner` must have a balance of tokens of type `id` of at least `amount`"
        );
        require(
            isOwnerOrApprovedForAll(owner),
            "If the caller is not `owner`, it must be have been approved to spend ``owner``'s tokens"
        );

        _safeTransferFrom(msg.sender, address(this), tokenId, amount, "");
        _frozens[tokenId][owner] += amount;

        _recordIds.increment();
        uint256 recordId = _recordIds.current();

        _records[recordId] = UserRecord(tokenId, owner, amount, user, expiry);

        emit CreateUserRecord(recordId, tokenId, amount, owner, user, expiry);

        return recordId;
    }

    function deleteUserRecord(uint256 recordId) external {
        UserRecord storage record = _records[recordId];

        require(isOwnerOrApprovedForAll(record.owner), "RYC: the caller must have allowance");

        _safeTransferFrom(address(this), record.owner, record.tokenId, record.amount, "");
        _frozens[record.tokenId][record.owner] -= record.amount;

        delete _records[recordId];

        emit DeleteUserRecord(recordId);
    }

    function userRecordOf(uint256 recordId) external view returns (UserRecord memory) {
        return _records[recordId];
    }

    function frozenBalanceOf(address account, uint256 tokenId) external view returns (uint256) {
        return _frozens[tokenId][account];
    }

    function usableBalanceOf(address account, uint256 tokenId) external view returns (uint256) {
        revert("Not implemented yet");
    }

    function isOwnerOrApprovedForAll(address owner) public view returns (bool) {
        return owner == msg.sender || isApprovedForAll(owner, msg.sender);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC1155, ERC1155Receiver) returns (bool) {
        return interfaceId == type(IERC5006).interfaceId || ERC1155.supportsInterface(interfaceId)
            || ERC1155Receiver.supportsInterface(interfaceId);
    }

    function onERC1155Received(address operator, address from, uint256 tokenId, uint256 value, bytes calldata data)
        external
        pure
        override
        returns (bytes4)
    {
        return IERC1155Receiver.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external pure override returns (bytes4) {
        return IERC1155Receiver.onERC1155BatchReceived.selector;
    }
}
