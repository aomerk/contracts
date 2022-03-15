// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

import "../../token/ERC1155/ERC1155.sol";

contract MockERC1155 is ERC1155 {
    function mint(
        address to,
        uint256 tokenId,
        uint256 value,
        bytes memory data
    ) public {
        _mint(to, tokenId, value, data);
    }

    function batchMint(
        address to,
        uint256[] memory tokenIds,
        uint256[] memory values,
        bytes memory data
    ) public {
        _batchMint(to, tokenIds, values, data);
    }

    function burn(
        address _from,
        uint256 _tokenId,
        uint256 _amount
    ) public {
        _burn(_from, _tokenId, _amount);
    }

    function batchBurn(
        address _from,
        uint256[] memory _ids,
        uint256[] memory _amounts
    ) public {
        _batchBurn(_from, _ids, _amounts);
    }
}
