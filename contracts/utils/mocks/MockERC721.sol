// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

// import "@rari-capital/solmate/src/tokens/ERC721.sol";

import "../../token/ERC721/ERC721.sol";

//
contract MockERC721 is ERC721 {
    string contractName;

    constructor(string memory _contractName)
    //  ERC721("Eat The Blocks NFTs", "ETBNFT")
    {
        contractName = _contractName;
    }

    // /**
    //  * @dev See {IERC721Metadata-tokenURI}.
    //  */
    // function tokenURI(uint256 tokenId)
    //     public
    //     view
    //     virtual
    //     override
    //     returns (string memory)
    // {
    //     return contractName;
    // }

    function mint(address to, uint256 tokenId) public virtual {
        _mint(to, tokenId);
    }

    function burn(uint256 tokenId) public virtual {
        _burn(tokenId);
    }

    function safeMint(address to, uint256 tokenId) public virtual {
        _safeMint(to, tokenId, "");
    }

    function safeMint(
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual {
        _safeMint(to, tokenId, data);
    }
}
