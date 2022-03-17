// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

import "../../token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) ERC20(_name, _symbol, _decimals) {
        totalSupply = 0;
    }

    function mint(address to, uint256 tokenId) public virtual {
        _mint(to, tokenId);
    }

    function burn(address _from, uint256 amount) public virtual {
        _burn(_from, amount);
    }
}

/*

solmate

 */
/* import "@rari-capital/solmate/src/tokens/ERC20.sol";

contract MockERC20 is ERC20 {
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) ERC20(_name, _symbol, _decimals) {
        totalSupply = 0;
    }

    function mint(address to, uint256 tokenId) public virtual {
        _mint(to, tokenId);
    }

    function burn(address _from, uint256 amount) public virtual {
        _burn(_from, amount);
    }
}
 */
