// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

import "../ERC165/IERC165.sol";
import "./IERC721TokenReceiver.sol";

contract Constants {
    string public constant ERR_BAD_ADDRESS = "BAD_ADDRESS";
    string public constant ERR_UNAUTHORIZED = "UNAUTH";
    string public constant ERR_TOKEN_EXISTS = "ERR_TOKEN_EXISTS";
    string public constant ERR_TOKEN_NOT_EXISTS = "ERR_TOKEN_NOT_EXISTS";
}

/// @title ERC-721 Non-Fungible Token Standard implementation.
/// @dev See https://eips.ethereum.org/EIPS/eip-721
///  Note: the ERC-165 identifier for this interface is 0x80ac58cd.
abstract contract ERC721 is Constants {
    /*
     * Events
     */
    /// @dev This emits when ownership of any NFT changes by any mechanism.
    ///  This event emits when NFTs are created (`from` == 0) and destroyed
    ///  (`to` == 0). Exception: during contract creation, any number of NFTs
    ///  may be created and assigned without emitting Transfer. At the time of
    ///  any transfer, the approved address for that NFT (if any) is reset to none.
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 indexed _tokenId
    );

    /// @dev This emits when the approved address for an NFT is changed or
    ///  reaffirmed. The zero address indicates there is no approved address.
    ///  When a Transfer event emits, this also indicates that the approved
    ///  address for that NFT (if any) is reset to none.
    event Approval(
        address indexed _owner,
        address indexed _approved,
        uint256 indexed _tokenId
    );

    /// @dev This emits when an operator is enabled or disabled for an owner.
    ///  The operator can manage all NFTs of the owner.
    event ApprovalForAll(
        address indexed _owner,
        address indexed _operator,
        bool _approved
    );

    /*
     *
     *	Variable declarations
     *
     */
    /// @dev instead of writing a function, we can use a public variable and solidity
    /// will handle the getter.
    /// @notice function balanceOf(address _owner) external view returns (uint256)
    mapping(address => uint256) public balanceOf;

    /// @notice function ownerOf(uint256 _tokenId) external view returns (address)
    /// @dev instead of writing a function, we can use a public variable and solidity
    /// will handle the getter.
    mapping(uint256 => address) public ownerOf;

    /// @notice function getApproved(uint256 _tokenId) external view returns (address);
    /// @dev instead of writing a function, we can use a public variable and solidity
    /// will handle the getter.
    mapping(uint256 => address) public getApproved;

    /// @notice function isApprovedForAll(address _owner, address _operator) external view returns (bool);
    ///
    mapping(address => mapping(address => bool)) public isApprovedForAll;

    /*
     *
     * ERC165 Implementation
     *
     */
    bytes4 private _interfaceIdERC165 = 0x01ffc9a7;
    bytes4 private _interfaceIdERC721 = 0x80ac58cd;

    function supportsInterface(bytes4 _interfaceId) public view returns (bool) {
        require(_interfaceId != 0xffffffff, "bad interface id");
        return
            _interfaceId == _interfaceIdERC165 ||
            _interfaceId == _interfaceIdERC721;
    }

    /*
     *
     * ERC721 Implementation
     *
     */
    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT. When transfer is complete, this function
    ///  checks if `_to` is a smart contract (code size > 0). If so, it calls
    ///  `onERC721Received` on `_to` and throws if the return value is not
    ///  `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    /// @param data Additional data with no specified format, sent in call to `_to`
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory data
    ) external payable {
        // transfer nft
        _transferFrom(_from, _to, _tokenId);
        // When transfer is complete, this function
        ///  checks if `_to` is a smart contract
        if (_to.code.length == 0) {
            return;
        }

        require(
            IERC721TokenReceiver(_to).onERC721Received(
                msg.sender,
                _from,
                _tokenId,
                data
            ) == IERC721TokenReceiver.onERC721Received.selector,
            ERR_BAD_ADDRESS
        );
    }

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT. When transfer is complete, this function
    ///  checks if `_to` is a smart contract (code size > 0). If so, it calls
    ///  `onERC721Received` on `_to` and throws if the return value is not
    ///  `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable {
        // transfer nft
        _transferFrom(_from, _to, _tokenId);
        // When transfer is complete, this function
        //  checks if `_to` is a smart contract that can receive tokens.
        checkERC721TokenReceiver(address(0), _to, _tokenId, "");
    }

    /// @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE
    ///  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
    ///  THEY MAY BE PERMANENTLY LOST
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable {
        require(_authorize(_tokenId, msg.sender, _from), ERR_UNAUTHORIZED);
        _transferFrom(_from, _to, _tokenId);
    }

    /// @notice Change or reaffirm the approved address for an NFT
    /// @dev The zero address indicates there is no approved address.
    ///  Throws unless `msg.sender` is the current NFT owner, or an authorized
    ///  operator of the current owner.
    /// @param _approved The new approved NFT controller
    /// @param _tokenId The NFT to approve
    function approve(address _approved, uint256 _tokenId) external payable {
        address _owner = ownerOf[_tokenId];
        require(
            _owner == msg.sender || isApprovedForAll[_owner][msg.sender],
            ERR_UNAUTHORIZED
        );

        getApproved[_tokenId] = _approved;
    }

    /// @notice Enable or disable approval for a third party ("operator") to manage
    ///  all of `msg.sender`'s assets
    /// @dev Emits the ApprovalForAll event. The contract MUST allow
    ///  multiple operators per owner.
    /// @param _operator Address to add to the set of authorized operators
    /// @param _approved True if the operator is approved, false to revoke approval
    function setApprovalForAll(address _operator, bool _approved) external {
        isApprovedForAll[msg.sender][_operator] = _approved;

        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    /*
     *
     *
     *
     *		Extra functions
     *
     *
     *
     */

    /// @notice Creation of NFTs (“minting”) and destruction of NFTs (“burning”) is not included in the specification
    /// @dev Creates a token send sends to _to Throws if `_to` is the zero address. Throws if `_tokenId` already exists.
    /// @param _to The address to send the token to
    /// @param _tokenId The token ID to mint
    function _mint(address _to, uint256 _tokenId) internal virtual {
        require(_to != address(0), ERR_BAD_ADDRESS);
        require(ownerOf[_tokenId] == address(0), ERR_TOKEN_EXISTS);

        // let's be serious
        unchecked {
            balanceOf[_to]++;
        }

        ownerOf[_tokenId] = _to;

        emit Transfer(address(0), _to, _tokenId);
    }

    /// @notice see _mint. Throws if _to is unable to receive the token.
    /// @dev Creates a token send sends to _to Throws if `_to` is the zero address. Throws if `_tokenId` already exists.
    /// @param _to The address to send the token to
    /// @param _tokenId The token ID to mint
    function _safeMint(
        address _to,
        uint256 _tokenId,
        bytes memory data
    ) internal virtual {
        _mint(_to, _tokenId);

        checkERC721TokenReceiver(address(0), _to, _tokenId, data);
    }

    /// @notice Creation of NFTs (“minting”) and destruction of NFTs (“burning”) is not included in the specification
    /// @dev Burns a token
    /// @param _tokenId The token ID to burn
    function _burn(uint256 _tokenId) internal virtual {
        address owner = ownerOf[_tokenId];

        require(owner != address(0), ERR_TOKEN_NOT_EXISTS);

        // let's be serious
        unchecked {
            balanceOf[owner]--;
        }

        // remove all approvals
        getApproved[_tokenId] = address(0);

        // remove token ownership
        delete ownerOf[_tokenId];

        emit Transfer(owner, address(0), _tokenId);
    }

    /// @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE
    ///  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
    ///  THEY MAY BE PERMANENTLY LOST
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function _transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) internal virtual {
        _checkTransferInput(_to, _tokenId);
        _authorize(_tokenId, msg.sender, _from);

        unchecked {
            // it is imposible to overflow since _from is guarenteed to be the owner
            // of transfering token
            balanceOf[_from]--;

            // it is possible to overflow, but come on.
            balanceOf[_to]++;
        }

        // set owner of token to _to
        ownerOf[_tokenId] = _to;

        // Clear approvals from the previous owner
        delete getApproved[_tokenId];

        emit Transfer(_from, _to, _tokenId);
    }

    /// @dev Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT.
    function _checkTransferInput(address _to, uint256 _tokenId) internal view {
        require(_to != address(0), ERR_BAD_ADDRESS);
        require(ownerOf[_tokenId] != address(0), "BAD_TOKEN");
    }

    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner.
    function _authorize(
        uint256 _tokenId,
        address _operator,
        address _from
    ) public view returns (bool) {
        return
            (
                ((getApproved[_tokenId] == _operator) ||
                    ownerOf[_tokenId] == _operator ||
                    isApprovedForAll[ownerOf[_tokenId]][_operator])
            ) && ownerOf[_tokenId] == _from;
    }

    function checkERC721TokenReceiver(
        address _to,
        address _from,
        uint256 _tokenId,
        bytes memory data
    ) private {
        // When transfer is complete, this function
        ///  checks if `_to` is a smart contract
        if (_to.code.length == 0) {
            return;
        }

        require(
            IERC721TokenReceiver(_to).onERC721Received(
                _to,
                _from,
                _tokenId,
                data
            ) == IERC721TokenReceiver.onERC721Received.selector,
            ERR_BAD_ADDRESS
        );
    }
}
