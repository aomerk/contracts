// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

/// @dev This interface is used to test the functionality of the
/// target contract's availability of receiving tokens.
interface IERC721TokenReceiver {
    function onERC721Received(
        address _operator,
        address _from,
        uint256 _id,
        bytes calldata _data
    ) external returns (bytes4);
}
