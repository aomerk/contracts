// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;
import "./ERC721.sol";

abstract contract ERC721Enumerable is ERC721 {
    /**
     * @dev returns the total number of tokens in existence
     */
    function totalSupply() external view returns (uint256 result) {
        for (uint256 i = 0; i < tokenIDs.length; i++) {
            if (ownerOf[tokenIDs[i]] != address(0)) result++;
        }
    }

    /**
     * @dev returns the token of id with the given owner
     * @param _owner address of the owner
     * @param _index i'th token of the owner
     */
    function tokenOfOwnerByIndex(address _owner, uint256 _index)
        external
        view
        returns (uint256 result)
    {
        require(_index < tokenIDs.length, "index out of range");

        // iterate all tokens and return the i'th token of the owner
        for (uint256 i = 0; i < tokenIDs.length; i++) {
            if (ownerOf[tokenIDs[i]] != _owner) {
                continue;
            }

            if (_index == 0) {
                result = tokenIDs[i];
                return result;
            }

            _index--;
        }

        revert("no such token");
    }

    /**
     * @dev returns i'th (unburned) token in that ever minted.
     */
    function tokenByIndex(uint256 index)
        external
        view
        returns (uint256 result)
    {
        // iterate all tokens that exists
        for (uint256 i = 0; i < tokenIDs.length; ) {
            uint256 token = tokenIDs[i];

            // ignore burned tokens from index, since we don't really burn them.
            if (ownerOf[token] == address(0)) {
                continue;
            }

            if (i == index) {
                return token;
            }

            // iterate to next token
            i++;
        }

        revert("no such token");
    }
}
