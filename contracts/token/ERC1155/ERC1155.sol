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
	// TransferSingle(address,address,address,uint256,uint256)
	uint256 internal constant SINGLE_TRANSFER_EVENT_HASH = 0xc3d58168c5ae7397731d063d5bbf3d657854427343f4c083240f7aacaa2d0f62;

    /**
        @dev Either `TransferSingle` or `TransferBatch` MUST emit when tokens are transferred, including zero value transfers as well as minting or burning (see "Safe Transfer Rules" section of the standard).
        The `_operator` argument MUST be the address of an account/contract that is approved to make the transfer (SHOULD be msg.sender).
        The `_from` argument MUST be the address of the holder whose balance is decreased.
        The `_to` argument MUST be the address of the recipient whose balance is increased.
        The `_ids` argument MUST be the list of tokens being transferred.
        The `_values` argument MUST be the list of number of tokens (matching the list and order of tokens specified in _ids) the holder balance is decreased by and match what the recipient balance is increased by.
        When minting/creating tokens, the `_from` argument MUST be set to `0x0` (i.e. zero address).
        When burning/destroying tokens, the `_to` argument MUST be set to `0x0` (i.e. zero address).

		@notice uses 5370 gas
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
	// ApprovalForAll(address,address,bool)
	uint256 internal constant APPROVAL_FOR_ALL_EVENT_HASH = 0x17307eab39ab6107e8899845ad3d59bd9653f200f220920489ca2b5937696c31;

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

    uint8 constant ERR_CODE_UNAUTH = 0x01;

    /*
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

		assembly {
            /************************************
             *									*
             *		utility functions 			*
             *									*
             ************************************/
			// Caller must be approved to manage the tokens being transferred
			function authorize(_f) -> result{
				// leave true if the from is caller
				if eq(caller(),_f){
					leave
				}

				mstore(0x0,_f)
				mstore(0x20, isApprovedForAll.slot)
				mstore(0x20,keccak256(0x0,0x40))
				mstore(0x0,caller())
				// leave if approved is true
				if sload(keccak256(0x0,0x40)) {
					leave
				}

				revert(0,0)
			}

       		 // Do transfer work
            function balanceOf(_f, _i) -> offset, value {
                mstore(0x0, _f)
                mstore(0x20, balanceOf.slot)
                offset := keccak256(0x0, 0x40)
                mstore(0x0, _i)
                mstore(0x20, offset)

                offset := keccak256(0x0, 0x40)
                value := sload(offset)
            }

			/************************************
             *									*
             *		control recipient			*
             *									*
             ************************************/
			// MUST revert if `_to` is the zero address.
			if eq(_to, 0x0) {
				revert(0,0)
			}

			pop(authorize(_from))


			/************************************
             *									*
             *		check _from balance			*
             *									*
             ************************************/
            // remove balance from _from.
            // it is possible for this operation to underflow
            let offset, balanceOfFrom := balanceOf(_from, _id)

            // MUST revert if balance of holder for token `_id` is lower than the `_value` sent.
            // underflow possible.
            if gt(_value, balanceOfFrom) {
                revert(0, 0)
            }


			/************************************
             *									*
             *		decrease _from balance		*
             *									*
             ************************************/
            // decrease balance of _from
            sstore(offset, sub(balanceOfFrom, _value))


			/************************************
             *									*
             *		increase _to balance		*
             *									*
             ************************************/

            // add balance to target
            // balanceOf++ can't overflow, because totalSupply can't overflow.
            // there is not enough value to overflow.
           let offsetTo, balanceOfTo := balanceOf(_to, _id)

            // balance value is sload(toOffset)
            let newToBalance := add(balanceOfTo, _value)

            // overflow test
            if lt(newToBalance, balanceOfTo) {
                revert(0, 0)
            }

            // set balance of _to to new value
            sstore(offsetTo, newToBalance)

		/************************************
		*									*
		*		emit TransferSingle event	*
		*									*
		************************************/
        //	MUST emit TransferSingle or TransferBatch event(s) such that
        //	all the balance changes are reflected
        //	(see “TransferSingle and TransferBatch event rules” section).
		mstore(0x00, _id)
		mstore(0x20, _value)
        log4(0x00, 0x40, SINGLE_TRANSFER_EVENT_HASH, caller(),_from, _to)
        }

		/************************************
        *									*
        *	post transfer safety check		*
        *									*
        ************************************/
        // if this is not a contract, don't check
        // the ability to receive ERC1155 tokens
        assembly {
            if eq(extcodesize(_to), 0x0) {
                return(0, 0)
            }
        }

        require(
            ERC1155TokenReceiver(_to).onERC1155Received(
                msg.sender,
                _from,
                _id,
                _value,
                _data
            ) == ERC1155TokenReceiver.onERC1155Received.selector,
            "422"
        );
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
        uint256[] memory _ids,
        uint256[] memory _values,
        bytes calldata _data
    ) external {
        // Caller must be approved to manage the tokens being transferred out of the `_from` account
        // An owner SHOULD be assumed to always be able to operate on their own tokens regardless of approval status,
        // so should SHOULD NOT have to call setApprovalForAll to approve themselves as an operator before they can operate on them.
        require(
            isApprovedForAll[_from][msg.sender] || msg.sender == _from,
            "403"
        );

        // Do transfer work
        assembly {
			/************************************
             *									*
             *		check input parameters		*
             *									*
             ************************************/

			// MUST revert if `_to` is the zero address.
			if eq(_to, 0x0){
				revert(0, 0)
			}
            // Load the length (first 32 bytes)
            let lenIds := mload(_ids)
            let lenValues := mload(_values)

			// MUST revert if length of `_ids` is not the same as length of `_values`.
            if iszero(eq(lenIds, lenValues)) {
                revert(0, 0)
            }

			/************************************
             *									*
             *		iterate ids/values			*
             *									*
             ************************************/
            // Skip over the length field.
            //
            // Keep temporary variable so it can be incremented in place.
            //
            // NOTE: incrementing _data would result in an unusable
            //       _data variable after this assembly block
            let ids := add(_ids, 0x20)
            let values := add(_values, 0x20)

            for {
                let end := add(ids, mul(lenIds, 0x20))
				// compute pointer to _to
				mstore(0x0, _to)
				mstore(0x20, balanceOf.slot)
				//
				// keep pointer to _to at memory location 0x20
				// so the id must be at memory location 0x00
				//
				let toBalLoc := keccak256(0x0, 0x40)
				// switch pointer _to => _from
				mstore(0x00, _from)
				// compute pointer to _from
				//
				// keep pointer to _from at memory location 0x60
				let fromBalLoc := keccak256(0x00, 0x40)
            }
			lt(ids, end)
			 {
                ids := add(ids, 0x20)
                values := add(values, 0x20)
            }{
				mstore(0x0, mload(ids))
                mstore(0x20, toBalLoc)
				let value := mload(values)

				/************************************
				*									*
				*		increase _to balance		*
				*									*
				************************************/
				//  0x00 == id balanceOf[_][id], 0x20 == balanceOf[_to]
                let toBalanceLoc := keccak256(0x0, 0x40)
                let toBalance := sload(toBalanceLoc)

                let newBalance := add(toBalance, value)

				//	check for overflow
                if lt(newBalance, toBalance) {
                    revert(0, 0)
                }

				sstore(toBalanceLoc, newBalance)

				/************************************
				*									*
				*		decrease _from balance		*
				*									*
				************************************/
				//  0x00 == id balanceOf[_][id], 0x20 == balanceOf[_from]
				mstore(0x20, fromBalLoc)

				let fromBalanceLoc := keccak256(0x00, 0x40)
				let fromBalance := sload(fromBalanceLoc)

				// MUST revert if any of the balance(s) of the holder(s) for
                //  token(s) in `_ids` is lower than the respective amount(s)
                // in `_values` sent to the recipient.
                if gt(value, fromBalance) {
                    revert(0, 0)
                }

				// decrease _from balance if all is ok
                sstore(fromBalanceLoc, sub(fromBalance, value))
            }


        }

        // After the above conditions are met, this function MUST check if _to
        // is a smart contract (e.g. code size > 0). If so, it MUST call onERC1155Received
        //  or onERC1155BatchReceived on _to and act appropriately (see
        // “onERC1155Received and onERC1155BatchReceived rules” section).

        //		The _data argument provided by the sender for the transfer MUST
        //  be passed with its contents unaltered to the ERC1155TokenReceiver
        // hook function(s) via their _data argument.
        _batchSafetyCheck(_from, _to, _ids, _values, _data);

		/************************************
		*									*
		*		emit TransferBatch event	*
		*									*
		************************************/
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
     *			ERC165				*
     *								*
     ********************************/
	function supportsInterface(bytes4 interfaceId) public pure virtual returns (bool) {
        return
            interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
            interfaceId == 0xd9b67a26;  // ERC165 Interface ID for ERC1155
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
		assembly{
			/************************************
             *									*
             *		check input parameters		*
             *									*
             ************************************/
			//  _to can't be the zero address
			if eq(_to, 0x00000000000000000000000000000000) {
				revert(0, 0)
			}

			/************************************
             *									*
             *		retrieve _to balance		*
             *									*
             ************************************/
			// get balance
			mstore(0x0, _to)
			mstore(0x20, balanceOf.slot)
			mstore(0x20, keccak256(0x0, 0x40))
			mstore(0x0, _id)
			let balanceOffset := keccak256(0x0, 0x40)
			let balanceAmount := sload(balanceOffset)

			/************************************
             *									*
             *		update _to balance 			*
             *									*
             ************************************/
			sstore(balanceOffset, add(balanceAmount, _value))

			// check for overflow: if new value is less than old value, revert
			if lt(sload(balanceOffset), balanceAmount) {
				revert(0, 0)
			}


		/************************************
		*									*
		*		emit TransferSingle event	*
		*									*
		************************************/
        //	MUST emit TransferSingle or TransferBatch event(s) such that
        //	all the balance changes are reflected
        //	(see “TransferSingle and TransferBatch event rules” section).
		mstore(0x00, _id)
		mstore(0x20, _value)
        log4(0x00, 0x40, SINGLE_TRANSFER_EVENT_HASH, caller(),0x00, _to)
		}

        // if this is not a contract, don't check
        // the ability to receive ERC1155 tokens
        assembly {
            if eq(extcodesize(_to), 0x0) {
                return(0, 0)
            }
        }

        // After the above conditions are met, this function MUST check if _to
        // is a smart contract (e.g. code size > 0). If so, it MUST call onERC1155Received
        //  or onERC1155BatchReceived on _to and act appropriately (see
        // “onERC1155Received and onERC1155BatchReceived rules” section).
        //		The _data argument provided by the sender for the transfer MUST
        //	be passed with its contents unaltered to the ERC1155TokenReceiver
        // 	hook function(s) via their _data argument
      require(
            ERC1155TokenReceiver(_to).onERC1155Received(
                msg.sender,
                address(0),
                _id,
                _value,
                _data
            ) == ERC1155TokenReceiver.onERC1155Received.selector,
            "422"
        );
	}

    function _batchMint(
        address _to,
        uint256[] memory _ids,
        uint256[] memory _values,
        bytes memory _data
    ) internal virtual {
        assembly {
			/************************************
             *									*
             *		check input parameters		*
             *									*
             ************************************/
			// MUST throw if _to is the zero address
            if eq(_to, 0x00000000000000000000000000000000) {
                revert(0, 0)
            }

            let ids_len := mload(_ids)
            let values_len := mload(_values)

			// MUST throw if length of `_ids` is not the same as length of `_values`.
            if iszero(eq(ids_len, values_len)) {
                revert(0, 0)
            }

			/************************************
             *									*
             *		iterate ids/values			*
             *									*
             ************************************/
			// skip first one since it stores the length
            let ids := add(_ids, 0x20)
            let values := add(_values, 0x20)

            for
			{
				// word size is 0x20
				let end := add(ids, mul(ids_len, 0x20))
				mstore(0x0, _to)
				mstore(0x20, balanceOf.slot)

				// keep pointer to _to at memory location 0x20
				mstore(0x20, keccak256(0x0, 0x40))
            }
				lt(ids, end)
			 {
                ids := add(ids, 0x20)
                values := add(values, 0x20)
            } {
			/************************************
             *									*
             *			update _to balance		*
             *									*
             ************************************/
				// get balance
                mstore(0x0, mload(ids))
                let balanceOffset := keccak256(0x0, 0x40)

                let toBalance := sload(balanceOffset)

                // add the value to the balance
                let newBalance := add(toBalance, mload(values))
                sstore(balanceOffset, newBalance)

                //	check for overflow
                if lt(newBalance, toBalance) {
                    revert(0, 0)
                }
            }
        }

		/************************************
		*									*
		*		emit Transfer event			*
		*									*
		************************************/
        emit TransferBatch(msg.sender, address(0), _to, _ids, _values);


		/************************************
		*									*
		*		check transfer safety		*
		*									*
		************************************/
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
		assembly{
			/************************************
			*									*
			*		check input parameters		*
			*									*
			************************************/
			// Must throw if _from is the zero address
			if eq(_from, 0x00000000000000000000000000000000) {
				revert(0, 0)
			}

			/************************************
			*									*
			*		update _from balance		*
			*									*
			************************************/
			// get balance
			mstore(0x0, _from)
			mstore(0x20, balanceOf.slot)
			mstore(0x20, keccak256(0x0, 0x40))
			mstore(0x0, _id)
			let balanceOffset := keccak256(0x0, 0x40)
			let balanceAmount := sload(balanceOffset)

			// check for underflow
			if lt(balanceAmount, _amount) {
				revert(0, 0)
			}

			// subtract the value from the balance
			sstore(balanceOffset, sub(balanceAmount, _amount))


			/************************************
			*									*
			*		emit TransferSingle event	*
			*									*
			************************************/
			//	MUST emit TransferSingle or TransferBatch event(s) such that
			//	all the balance changes are reflected
			//	(see “TransferSingle and TransferBatch event rules” section).
			mstore(0x00, _id)
			mstore(0x20, _amount)
			log4(0x00, 0x40, SINGLE_TRANSFER_EVENT_HASH, caller(),_from, 0x00)
		}
    }

    function _batchBurn(
        address _from,
        uint256[] memory _ids,
        uint256[] memory _values
    ) internal virtual {
		   assembly {
			/************************************
			*									*
			*		check input parameters		*
			*									*
			************************************/
			// MUST throw if _to is the zero address
            if eq(_from, 0x00000000000000000000000000000000) {
                revert(0, 0)
            }

            let ids_len := mload(_ids)
            let values_len := mload(_values)

			// MUST throw if length of `_ids` is not the same as length of `_values`.
            if xor(ids_len, values_len) {
                revert(0, 0)
            }

			/************************************
			*									*
			*		iterate ids/values			*
			*									*
			************************************/
			// skip first one since it stores the length
            let ids := add(_ids, 0x20)
            let values := add(_values, 0x20)

            for
			{
				// word size is 0x20
				let end := add(ids, mul(ids_len, 0x20))
				mstore(0x0, _from)
				mstore(0x20, balanceOf.slot)

				// keep pointer to _to at memory location 0x20
				mstore(0x20, keccak256(0x0, 0x40))
            }
				lt(ids, end)
			 {
                ids := add(ids, 0x20)
                values := add(values, 0x20)
            } {
				/************************************
				*									*
				*			update balance			*
				*									*
				************************************/
				// get balance
                mstore(0x0, mload(ids))
                let balanceOffset := keccak256(0x0, 0x40)

                let fromBalance := sload(balanceOffset)


                //	check for underflow
                if lt(fromBalance, mload(values)) {
                    revert(0, 0)
                }

                // add the value to the balance
                let newBalance := sub(fromBalance, mload(values))
                sstore(balanceOffset, newBalance)

            }
        }

		/************************************
		*									*
		*		emit Transfer event 		*
		*									*
		************************************/
		emit TransferBatch(msg.sender, _from, address(0), _ids, _values);
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

    /// @dev uses 195 gas
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
