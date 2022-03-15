// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

import "./ERC1155TokenReceiver.sol";

import "hardhat/console.sol";

/**
    @title ERC-1155 Multi Token Standard
    @dev See https://eips.ethereum.org/EIPS/eip-1155
    Note: The ERC-165 identifier for this interface is 0xd9b67a26.
 */
contract ERC1155 {
    /**
        @dev Either `TransferSingle` or `TransferBatch` MUST emit when tokens are transferred, including zero value transfers as well as minting or burning (see "Safe Transfer Rules" section of the standard).
        The `_operator` argument MUST be the address of an account/contract that is approved to make the transfer (SHOULD be msg.sender).
        The `_from` argument MUST be the address of the holder whose balance is decreased.
        The `_to` argument MUST be the address of the recipient whose balance is increased.
        The `_id` argument MUST be the token type being transferred.
        The `_value` argument MUST be the number of tokens the holder balance is decreased by and match what the recipient balance is increased by.
        When minting/creating tokens, the `_from` argument MUST be set to `0x0` (i.e. zero address).
        When burning/destroying tokens, the `_to` argument MUST be set to `0x0` (i.e. zero address).
    */
    event TransferSingle(
        address indexed _operator,
        address indexed _from,
        address indexed _to,
        uint256 _id,
        uint256 _value
    );

    /**
        @dev Either `TransferSingle` or `TransferBatch` MUST emit when tokens are transferred, including zero value transfers as well as minting or burning (see "Safe Transfer Rules" section of the standard).
        The `_operator` argument MUST be the address of an account/contract that is approved to make the transfer (SHOULD be msg.sender).
        The `_from` argument MUST be the address of the holder whose balance is decreased.
        The `_to` argument MUST be the address of the recipient whose balance is increased.
        The `_ids` argument MUST be the list of tokens being transferred.
        The `_values` argument MUST be the list of number of tokens (matching the list and order of tokens specified in _ids) the holder balance is decreased by and match what the recipient balance is increased by.
        When minting/creating tokens, the `_from` argument MUST be set to `0x0` (i.e. zero address).
        When burning/destroying tokens, the `_to` argument MUST be set to `0x0` (i.e. zero address).
    */
    event TransferBatch(
        address indexed _operator,
        address indexed _from,
        address indexed _to,
        uint256[] _ids,
        uint256[] _values
    );

    /**
        @dev MUST emit when approval for a second party/operator address to manage all tokens for an owner address is enabled or disabled (absence of an event assumes disabled).
    */
    event ApprovalForAll(
        address indexed _owner,
        address indexed _operator,
        bool _approved
    );

    /**
        @dev MUST emit when the URI is updated for a token ID.
        URIs are defined in RFC 3986.
        The URI MUST point to a JSON file that conforms to the "ERC-1155 Metadata URI JSON Schema".
    */
    event URI(string _value, uint256 indexed _id);

    /**
        @notice Queries the approval status of an operator for a given owner.
		True if the operator is approved, false if not
    */
    mapping(address => mapping(address => bool)) public isApprovedForAll;

    /// @dev balanceOf is the amount of tokens that the given address has.
    mapping(address => mapping(uint256 => uint256)) public balanceOf;

    /**
        @notice Transfers `_value` amount of an `_id` from the `_from` address to the `_to` address specified (with safety call).
        @dev Caller must be approved to manage the tokens being transferred out of the `_from` account (see "Approval" section of the standard).
        MUST revert if `_to` is the zero address.
        MUST revert if balance of holder for token `_id` is lower than the `_value` sent.
        MUST revert on any other error.
        MUST emit the `TransferSingle` event to reflect the balance change (see "Safe Transfer Rules" section of the standard).
        After the above conditions are met, this function MUST check if `_to` is a smart contract (e.g. code size > 0). If so, it MUST call `onERC1155Received` on `_to` and act appropriately (see "Safe Transfer Rules" section of the standard).
        @param _from    Source address
        @param _to      Target address
        @param _id      ID of the token type
        @param _value   Transfer amount
        @param _data    Additional data with no specified format, MUST be sent unaltered in call to `onERC1155Received` on `_to`
    */
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _id,
        uint256 _value,
        bytes calldata _data
    ) external {
        // MUST revert if `_to` is the zero address
        require(_to != address(0), "400");

        // Caller must be approved to manage the tokens being transferred out of the `_from` account (see "Approval" section of the standard).
        require(
            isApprovedForAll[_from][msg.sender] || msg.sender == _from,
            "403"
        );
        // MUST revert if balance of holder for token `_id` is lower than the `_value` sent.
        require(balanceOf[_from][_id] >= _value, "400");

        balanceOf[_from][_id] -= _value;
        balanceOf[_to][_id] += _value;

        // After the above conditions are met, this function MUST check if _to
        // is a smart contract (e.g. code size > 0). If so, it MUST call onERC1155Received
        //  or onERC1155BatchReceived on _to and act appropriately (see
        // “onERC1155Received and onERC1155BatchReceived rules” section).
        //		The _data argument provided by the sender for the transfer MUST
        //	be passed with its contents unaltered to the ERC1155TokenReceiver
        // 	hook function(s) via their _data argument.
        _singleSafetyCheck(_from, _to, _id, _value, _data);

        // MUST emit TransferSingle or TransferBatch event(s) such that all the balance changes are reflected
        // (see “TransferSingle and TransferBatch event rules” section).
        emit TransferSingle(msg.sender, _from, _to, _id, _value);
    }

    /**
        @notice Transfers `_values` amount(s) of `_ids` from the `_from` address to the `_to` address specified (with safety call).
        @dev Caller must be approved to manage the tokens being transferred out of the `_from` account (see "Approval" section of the standard).
        MUST revert if `_to` is the zero address.
        MUST revert if length of `_ids` is not the same as length of `_values`.
        MUST revert if any of the balance(s) of the holder(s) for token(s) in `_ids` is lower than the respective amount(s) in `_values` sent to the recipient.
        MUST revert on any other error.
        MUST emit `TransferSingle` or `TransferBatch` event(s) such that all the balance changes are reflected (see "Safe Transfer Rules" section of the standard).
        Balance changes and events MUST follow the ordering of the arrays (_ids[0]/_values[0] before _ids[1]/_values[1], etc).
        After the above conditions for the transfer(s) in the batch are met,
		this function MUST check if `_to` is a smart contract (e.g. code size > 0).
		If so, it MUST call the relevant `ERC1155TokenReceiver` hook(s) on `_to` and act appropriately (see "Safe Transfer Rules" section of the standard).
        @param _from    Source address
        @param _to      Target address
        @param _ids     IDs of each token type (order and length must match _values array)
        @param _values  Transfer amounts per token type (order and length must match _ids array)
        @param _data    Additional data with no specified format, MUST be sent unaltered in call to the `ERC1155TokenReceiver` hook(s) on `_to`
    */
    function safeBatchTransferFrom(
        address _from,
        address _to,
        uint256[] calldata _ids,
        uint256[] calldata _values,
        bytes calldata _data
    ) external {
        // MUST revert if `_to` is the zero address.
        require(_to != address(0), "400");

        // MUST revert if length of `_ids` is not the same as length of `_values`.
        require(_ids.length == _values.length, "400");

        // Caller must be approved to manage the tokens being transferred out of the `_from` account
        // An owner SHOULD be assumed to always be able to operate on their own tokens regardless of approval status,
        // so should SHOULD NOT have to call setApprovalForAll to approve themselves as an operator before they can operate on them.
        require(
            isApprovedForAll[_from][msg.sender] || msg.sender == _from,
            "403"
        );

        for (uint256 i = 0; i < _ids.length; i++) {
            // MUST revert if any of the balance(s) of the holder(s) for token(s) in `_ids` is lower than the respective amount(s) in `_values` sent to the recipient.
            require(balanceOf[_from][_ids[i]] >= _values[i], "400");

            balanceOf[_from][_ids[i]] -= _values[i];
            balanceOf[_to][_ids[i]] += _values[i];
        }

        // After the above conditions are met, this function MUST check if _to
        // is a smart contract (e.g. code size > 0). If so, it MUST call onERC1155Received
        //  or onERC1155BatchReceived on _to and act appropriately (see
        // “onERC1155Received and onERC1155BatchReceived rules” section).

        //		The _data argument provided by the sender for the transfer MUST
        //  be passed with its contents unaltered to the ERC1155TokenReceiver
        // hook function(s) via their _data argument.
        _batchSafetyCheck(_from, _to, _ids, _values, _data);

        // MUST emit TransferSingle or TransferBatch event(s) such that all the balance changes are reflected
        // (see “TransferSingle and TransferBatch event rules” section).
        emit TransferBatch(msg.sender, _from, _to, _ids, _values);
    }

    /**
        @notice Get the balance of multiple account/token pairs
        @param _owners The addresses of the token holders
        @param _ids    ID of the tokens
        @return result _owner's balance of the token types requested (i.e. balance for each (owner, id) pair)
     */
    function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids)
        external
        view
        returns (uint256[] memory result)
    {
        require(_owners.length == _ids.length, "422");
        result = new uint256[](_owners.length);

        for (uint256 i = 0; i < _owners.length; i++) {
            result[i] = balanceOf[_owners[i]][_ids[i]];
        }
    }

    /**
        @notice Enable or disable approval for a third party ("operator") to manage all of the caller's tokens.
        @dev MUST emit the ApprovalForAll event on success.
        @param _operator  Address to add to the set of authorized operators
        @param _approved  True if the operator is approved, false to revoke approval
    */
    function setApprovalForAll(address _operator, bool _approved) external {
        isApprovedForAll[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    /*******************************
     *								*
     *		minting and burning		*
     *								*
     ********************************/

    function _mint(
        address _to,
        uint256 _id,
        uint256 _value,
        bytes memory _data
    ) internal {
        require(_to != address(0), "422");

        balanceOf[_to][_id] += _value;

        emit TransferSingle(msg.sender, address(0), _to, _id, _value);

        // After the above conditions are met, this function MUST check if _to
        // is a smart contract (e.g. code size > 0). If so, it MUST call onERC1155Received
        //  or onERC1155BatchReceived on _to and act appropriately (see
        // “onERC1155Received and onERC1155BatchReceived rules” section).
        //		The _data argument provided by the sender for the transfer MUST
        //	be passed with its contents unaltered to the ERC1155TokenReceiver
        // 	hook function(s) via their _data argument.
        _singleSafetyCheck(address(0), _to, _id, _value, _data);
    }

    function _batchMint(
        address _to,
        uint256[] memory _ids,
        uint256[] memory _values,
        bytes memory _data
    ) internal virtual {
        require(_ids.length == _values.length, "422");
        require(_to != address(0), "422");

        for (uint256 i = 0; i < _ids.length; i++) {
            balanceOf[_to][_ids[i]] += _values[i];
        }

        emit TransferBatch(msg.sender, address(0), _to, _ids, _values);

        // After the above conditions are met, this function MUST check if _to
        // is a smart contract (e.g. code size > 0). If so, it MUST call onERC1155Received
        //  or onERC1155BatchReceived on _to and act appropriately (see
        // “onERC1155Received and onERC1155BatchReceived rules” section).
        //		The _data argument provided by the sender for the transfer MUST
        //	be passed with its contents unaltered to the ERC1155TokenReceiver
        // 	hook function(s) via their _data argument.
        _batchSafetyCheck(address(0), _to, _ids, _values, _data);
    }

    function _burn(
        address _from,
        uint256 _id,
        uint256 _amount
    ) internal virtual {
        require(_from != address(0), "403");
        require(balanceOf[_from][_id] >= _amount, "400");

        balanceOf[_from][_id] -= _amount;

        emit TransferSingle(msg.sender, _from, address(0), _id, _amount);
    }

    function _batchBurn(
        address _from,
        uint256[] memory _ids,
        uint256[] memory _amounts
    ) internal virtual {
        require(_from != address(0), "403");
        require(_ids.length == _amounts.length, "400");

        for (uint256 i = 0; i < _ids.length; i++) {
            require(balanceOf[_from][_ids[i]] >= _amounts[i], "400");
            balanceOf[_from][_ids[i]] -= _amounts[i];
        }
    }

    /*******************************
     *								*
     *		utility functions		*
     *								*
     ********************************/

    function _elemToArray(uint256 _elem)
        internal
        pure
        returns (uint256[] memory arr)
    {
        arr = new uint256[](1);
        arr[0] = _elem;
    }

    function _batchSafetyCheck(
        address _from,
        address _to,
        uint256[] memory _ids,
        uint256[] memory _values,
        bytes memory _data
    ) internal {
        // The recipient is not a contract
        if (_to.code.length == 0) {
            return;
        }

        // The transaction is not a mint/transfer of a token.
        if (_to == address(0)) {
            return;
        }

        require(
            ERC1155TokenReceiver(_to).onERC1155BatchReceived(
                msg.sender,
                _from,
                _ids,
                _values,
                _data
            ) == ERC1155TokenReceiver.onERC1155BatchReceived.selector,
            "400"
        );
    }

    function _singleSafetyCheck(
        address _from,
        address _to,
        uint256 _id,
        uint256 _value,
        bytes memory _data
    ) internal {
        // The recipient is not a contract
        if (_to.code.length == 0) {
            return;
        }

        // The transaction is not a mint/transfer of a token.
        if (_to == address(0)) {
            return;
        }

        require(
            ERC1155TokenReceiver(_to).onERC1155Received(
                msg.sender,
                _from,
                _id,
                _value,
                _data
            ) == ERC1155TokenReceiver.onERC1155Received.selector,
            "400"
        );
    }
}
