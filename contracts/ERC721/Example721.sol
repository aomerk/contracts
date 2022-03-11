// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

import "./ERC721.sol";

contract ExampleERC721 is ERC721 {
    function createToken(uint256 _tokenId) public {
        _safeMint(msg.sender, _tokenId, "");
    }
}
