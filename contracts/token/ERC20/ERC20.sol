// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

/// @title ERC20 Fungible Token Standard implementation.
/// @dev See https://eips.ethereum.org/EIPS/eip-20
/// Note: the implements eip2612 for permits.
abstract contract ERC20 {
    /// @notice This method can be used to improve usability, but interfaces and
    ///  other contracts MUST NOT expect these values to be present
    /// @return name is the name of the token - e.g. "MyToken".
    string public name;
    /// @notice This method can be used to improve usability, but interfaces and
    //  other contracts MUST NOT expect these values to be present
    /// @return symbol is the symbol of the token - e.g. "HIX".
    string public symbol;

    bytes32 private constant EIP712_DOMAIN_HASH =
        keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );

    bytes32 public constant PERMIT_TYPEHASH =
        keccak256(
            "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
        );

    bytes32 private constant VERSION_HASH = keccak256("1");

    uint256 internal immutable chainid;

    bytes32 internal immutable domainseparator;

    /// @return totalSupply is the total amount of tokens in existence.
    uint256 public totalSupply;

    /// @notice This method can be used to improve usability, but interfaces and
    ///  other contracts MUST NOT expect these values to be present
    /// @return decimals is the number of decimal places used for token
    /// eg. 8, means to divide the token amount by 100000000 to get its
    /// user representation.
    uint8 public decimals;

    /// @return balanceOf is the amount of tokens that the given address has.
    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => uint256) public nonces;

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        chainid = block.chainid;
        domainseparator = computeDomainSeparator();
    }

    /*

		EVENTS

	 */

    /// @dev A token contract which creates new tokens SHOULD trigger a Transfer
    /// event with the _from address set to 0x0 when tokens are created.
    /// @notice MUST trigger when tokens are transferred, including zero value transfers.
    /// _from address The address the tokens are transferred from.
    /// _to address The address the tokens are transferred to.
    /// _value uint256 the amount of tokens transferred.
    // event Transfer(address indexed _from, address indexed _to, uint256 _value);
    uint256 internal constant TRANSFER_EVENT_HASH =
        0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef;
    /// @dev A token contract which creates new tokens SHOULD trigger a Transfer
    ///  event with the _from address set to 0x0 when tokens are created.
    /// @notice MUST trigger on any successful call to approve(address _spender, uint256 _value).
    /// _owner address The address the approval is for.
    /// _spender address The address that is able to spend the funds.
    /// _value uint256 The amount of tokens that are approved for the spender.
    // event Approval(address indexed _owner,address indexed _spender,uint256 _value);
    uint256 internal constant APPROVAL_EVENT_HASH =
        0x8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925;

    /*


		Transfer functions


	 */
    /// @dev Transfer tokens from sender.
    /// @param _to address The address the tokens are transferred to.
    /// @param _value uint256 the amount of tokens to be transferred.
    /// @return success True if the transfer was successful.
    /// @notice Throws if the transfer is not successful. Throws if the
    /// message caller???s account balance does not have enough tokens to spend.
    /// MUST fire Transfer event.
    function transfer(address _to, uint256 _value)
        public
        returns (bool success)
    {
        assembly {
            /************************************
             *									*
             *		load caller's balance 		*
             *									*
             ************************************/
            // remove balance from _from.
            // it is possible for this operation to underflow
            mstore(0x0, caller())
            mstore(0x20, balanceOf.slot)

            let fromOffset := keccak256(0x00, 0x40)
            let fromValue := sload(fromOffset)

            /************************************
             *									*
             *		check caller's balance	*
             *									*
             ************************************/
            //	Throws if the message caller???s account balance
            //	does not have enough tokens to spend.
            if gt(_value, fromValue) {
                revert(0, 0)
            }

            /************************************
             *									*
             *		set caller's balance 		*
             *									*
             ************************************/

            // decrease balance of _from
            sstore(fromOffset, sub(fromValue, _value))

            /************************************
             *									*
             *		set recipient's balance		*
             *									*
             ************************************/
            // add balance to target
            // balanceOf++ can't overflow, because totalSupply can't overflow.
            // there is not enough value to overflow.
            mstore(0x00, _to)
            mstore(0x20, balanceOf.slot)
            let toOffset := keccak256(0x00, 0x40)
            // update balance of _to
            sstore(toOffset, add(sload(toOffset), _value))

            /************************************
             *									*
             *		emit transfer event			*
             *									*
             ************************************/
            mstore(0x20, _value)
            log3(0, 0x20, TRANSFER_EVENT_HASH, caller(), _to)
        }

        return true;
    }

    /// @dev Transfers _value amount of tokens from address _from to address _to,
    ///  and MUST fire the Transfer event.
    /// @param _from address The address to transfer from.
    /// @param _to address The address the tokens are transferred to.
    /// @param _value uint256 the amount of tokens to be transferred.
    /// @return success True if the transfer was successful.
    /// @notice Throws if the transfer is not successful. Throws if the
    /// message caller???s account balance does not have enough tokens to spend.
    /// Throws unless the _from account has deliberately authorized the sender
    /// of the message via some mechanism
    /// MUST fire Transfer event.
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        // check if the sender has enough tokens to spend
        assembly {
            /************************************
             *									*
             *		load caller's allowance		*
             *									*
             ************************************/
            // load the value of the allowance
            mstore(0x0, _from)
            mstore(0x20, allowance.slot)
            mstore(0x20, keccak256(0x0, 0x40))
            mstore(0x0, caller())
            let fromAllowanceOffset := keccak256(0x0, 0x40)
            let allowanceOfFrom := sload(fromAllowanceOffset)

            /************************************
             *									*
             *		check caller's allowance	*
             *									*
             ************************************/
            // authorize sender
            // either sender is from or is allowed to spend enough
            // fromAllowance < value, "bad"
            if lt(allowanceOfFrom, _value) {
                revert(0, 0)
            }

            /************************************
             *									*
             *		reduce allowance			*
             *									*
             ************************************/
            sstore(fromAllowanceOffset, sub(allowanceOfFrom, _value))

            /************************************
             *									*
             *		set _from balance			*
             *									*
             ************************************/
            // it is possible for this operation to underflow
            mstore(0x00, _from)
            mstore(0x20, balanceOf.slot)
            let fromOffset := keccak256(0x00, 0x40)
            let balanceOfFrom := sload(fromOffset)

            // check for underflow
            if gt(_value, balanceOfFrom) {
                revert(0, 0)
            }

            // decrease balance of _from
            sstore(fromOffset, sub(balanceOfFrom, _value))

            /************************************
             *									*
             *		set _to balance				*
             *									*
             ************************************/
            // add balance to target
            mstore(0x00, _to)
            mstore(0x20, balanceOf.slot)
            let offsetBalanceTo := keccak256(0x00, 0x40)

            // balance value is sload(toOffset)
            // balanceOf++ can't overflow, because totalSupply can't overflow.
            // there is not enough value to overflow.
            sstore(offsetBalanceTo, add(sload(offsetBalanceTo), _value))

            /************************************
             *									*
             *		emit transfer event			*
             *									*
             ************************************/
            mstore(0x20, _value)
            log3(0, 0x20, TRANSFER_EVENT_HASH, _from, _to)
        }

        return true;
    }

    /// @dev Allows _spender to withdraw from your account multiple times,
    /// up to the _value amount.
    /// @notice If this function is called again it overwrites the current allowance
    /// with _value
    function approve(address _spender, uint256 _value)
        public
        returns (bool success)
    {
        assembly {
            /************************************
             *									*
             *		set allowance value			*
             *									*
             ************************************/
            // load the value of the allowance
            mstore(0x00, caller())
            mstore(0x20, allowance.slot)
            mstore(0x20, keccak256(0x00, 0x40))
            mstore(0x00, _spender)
            // set value of allowance
            sstore(keccak256(0x00, 0x40), _value)

            /************************************
             *									*
             *		emit approval event			*
             *									*
             ************************************/
            mstore(0x20, _value)
            log3(0, 0x20, APPROVAL_EVENT_HASH, caller(), _spender)
        }

        return true;
    }

    /*


		MINTING AND BURNING


	 */

    function _mint(address to, uint256 amount) internal virtual {
        assembly {
            /************************************
             *									*
             *		increase total supply		*
             *									*
             ************************************/
            let currentSupply := sload(totalSupply.slot)
            let newSupply := add(currentSupply, amount)

            // overflow check
            if lt(newSupply, currentSupply) {
                revert(0, 0)
            }

            sstore(totalSupply.slot, newSupply)

            /************************************
             *									*
             *		increase _to balance		*
             *									*
             ************************************/
            mstore(0x00, to)

            // Store slot number in scratch space after num
            mstore(0x20, balanceOf.slot)

            // Create hash from previously stored num and slot
            let toAddressOffset := keccak256(0x00, 0x40)

            // increase balance of minted address
            sstore(toAddressOffset, add(sload(toAddressOffset), amount))

            /************************************
             *									*
             *		emit transfer event			*
             *									*
             ************************************/
            mstore(0x20, amount)
            log3(0, 0x20, TRANSFER_EVENT_HASH, 0x00, to)
        }
    }

    function _burn(address from, uint256 amount) internal virtual {
        // reduce balance of from and total supply
        assembly {
            /************************************
             *									*
             *		decrease from's balance		*
             *									*
             ************************************/
            mstore(0x00, from)
            // Store slot number in scratch space after num
            mstore(0x20, balanceOf.slot)
            // Create hash from previously stored num and slot
            let fromAddressOffset := keccak256(0x00, 0x40)
            // Load mapping value using the just calculated hash
            let balanceOfAddress := sload(fromAddressOffset)

            // revert possible overflow
            if lt(balanceOfAddress, amount) {
                revert(0, 0)
            }

            // decrease balance of minted address
            // amount is less then balanceOf[from], so it can't overflow
            sstore(fromAddressOffset, sub(balanceOfAddress, amount))

            /************************************
             *									*
             *		decrease total supply		*
             *									*
             ************************************/
            // total supply is at least balanceOf[from], so it can't overflow
            sstore(totalSupply.slot, sub(sload(totalSupply.slot), amount))

            /************************************
             *									*
             *		emit transfer event			*
             *									*
             ************************************/
            mstore(0x20, amount)
            log3(0, 0x20, TRANSFER_EVENT_HASH, from, 0x00)
        }
    }

    function computeDomainSeparator() internal view virtual returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    EIP712_DOMAIN_HASH,
                    keccak256(bytes(name)),
                    VERSION_HASH,
                    block.chainid,
                    address(this)
                )
            );
    }

    function detectChainChange() internal view virtual returns (bytes32) {
        if (block.chainid != chainid) {
            return domainseparator;
        }

        return computeDomainSeparator();
    }

    /// @dev For all addresses _owner, _spender, uint256s _value, _deadline and
    ///  _nonce, uint8 _v, bytes32 _r and _s, a call to
    /// permit(_owner, _spender, _value, _deadline, _v, _r, _s) will set approval[_owner][_spender]
    ///  to value, increment nonces[_owner] by 1
    ///  and emit an Approval event.
    /// @notice Throws is owner is the zero address, current blocktime is greater
    /// than the deadline, nopnces[owner] is not equal to the nonce, r,s and v
    ///	is not a valid secp256k1 signature from owner of the message.
    function permit(
        address _owner,
        address _spender,
        uint256 _value,
        uint256 _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public virtual returns (bool success) {
        require(_deadline > block.timestamp, "dealine is in the past");

        // Unchecked because the only math done is incrementing
        // the owner's nonce which cannot realistically overflow.
        unchecked {
            nonces[_owner]++;

            bytes32 digest = keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    /*
					detect changes in chain
					 */
                    detectChainChange(),
                    keccak256(
                        abi.encode(
                            PERMIT_TYPEHASH,
                            _owner,
                            _spender,
                            _value,
                            nonces[_owner],
                            _deadline
                        )
                    )
                )
            );

            address signer = ecrecover(digest, _v, _r, _s);

            require(signer != address(0) && signer == _owner, "invalid signer");

            allowance[signer][_spender] = _value;

            return success;
        }
    }
}
