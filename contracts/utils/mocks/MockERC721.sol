// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

/*


keser mock contract


 */

import "../../token/ERC721/ERC721.sol";

contract MockERC721 is ERC721("Mock", "Mock ERC721") {
    string contractName;

    function tokenURI(uint256 _id)
        public
        view
        virtual
        override
        returns (string memory)
    {
        return contractName;
    }

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

/*


solmate mock contract


 */

/*
import "@rari-capital/solmate/src/tokens/ERC721.sol";

contract MockERC721 is ERC721("Mock", "Mock ERC721") {
    ///
    ///  @dev See {IERC721Metadata-tokenURI}.
    ///
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        return contractName;
    }

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
} */
/*
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MockERC721 is ERC721("Mock", "Mock ERC721") {
    ///
    ///  @dev See {IERC721Metadata-tokenURI}.
    ///
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        return contractName;
    }

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
 */
