// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

/// @title ERC-721 Non-Fungible Token Standard implementation.
/// @dev See https://eips.ethereum.org/EIPS/eip-721
///  Note: the ERC-165 identifier for this interface is 0x80ac58cd.
abstract contract ERC20ASM {
    /// @notice This method can be used to improve usability, but interfaces and
    ///  other contracts MUST NOT expect these values to be present
    /// @return name is the name of the token - e.g. "MyToken".
    string public name;

    /// @notice This method can be used to improve usability, but interfaces and
    //  other contracts MUST NOT expect these values to be present
    /// @return symbol is the symbol of the token - e.g. "HIX".
    string public symbol;

    /// @notice This method can be used to improve usability, but interfaces and
    ///  other contracts MUST NOT expect these values to be present
    /// @return decimals is the number of decimal places used for token
    /// eg. 8, means to divide the token amount by 100000000 to get its
    /// user representation.
    uint8 public decimals;

    /// @return totalSupply is the total amount of tokens in existence.
    uint256 public totalSupply;

    /// @return balanceOf is the amount of tokens that the given address has.
    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    /*

		EVENTS

	 */
    /// @dev A token contract which creates new tokens SHOULD trigger a Transfer
    /// event with the _from address set to 0x0 when tokens are created.
    /// @notice MUST trigger when tokens are transferred, including zero value transfers.
    /// @param _from address The address the tokens are transferred from.
    /// @param _to address The address the tokens are transferred to.
    /// @param _value uint256 the amount of tokens transferred.
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    /// @dev A token contract which creates new tokens SHOULD trigger a Transfer
    ///  event with the _from address set to 0x0 when tokens are created.
    /// @notice MUST trigger on any successful call to approve(address _spender, uint256 _value).
    /// @param _owner address The address the approval is for.
    /// @param _spender address The address that is able to spend the funds.
    /// @param _value uint256 The amount of tokens that are approved for the spender.
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    /*


		Transfer functions


	 */
    /// @dev Transfer tokens from sender.
    /// @param _to address The address the tokens are transferred to.
    /// @param _value uint256 the amount of tokens to be transferred.
    /// @return success True if the transfer was successful.
    /// @notice Throws if the transfer is not successful. Throws if the
    /// message caller’s account balance does not have enough tokens to spend.
    /// MUST fire Transfer event.
    function transfer(address _to, uint256 _value)
        public
        returns (bool success)
    {
        assembly {
            // remove balance from _from.
            // it is possible for this operation to underflow
            mstore(0, caller())
            mstore(32, balanceOf.slot)

            let fromOffset := keccak256(0, 64)
            let fromValue := sload(fromOffset)

            // underflow possible
            if gt(_value, fromValue) {
                revert(0, 0)
            }

            // decrease balance of _from
            sstore(fromOffset, sub(fromValue, _value))

            // add balance to target
            // balanceOf++ can't overflow, because totalSupply can't overflow.
            // there is not enough value to overflow.
            mstore(0, _to)
            mstore(32, balanceOf.slot)
            let toOffset := keccak256(0, 64)

            // balance value is sload(toOffset)
            sstore(toOffset, add(sload(toOffset), _value))
        }

        emit Transfer(msg.sender, _to, _value);

        return true;
    }

    /// @dev Transfers _value amount of tokens from address _from to address _to,
    ///  and MUST fire the Transfer event.
    /// @param _from address The address to transfer from.
    /// @param _to address The address the tokens are transferred to.
    /// @param _value uint256 the amount of tokens to be transferred.
    /// @return success True if the transfer was successful.
    /// @notice Throws if the transfer is not successful. Throws if the
    /// message caller’s account balance does not have enough tokens to spend.
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
            /*

				check allowance

			 */
            // load the value of the allowance
            mstore(0x0, _from)
            mstore(0x20, allowance.slot)
            let firstOffSet := keccak256(0x0, 0x40)
            mstore(0x0, caller())
            mstore(0x20, firstOffSet)

            let fromAllowanceOffset := keccak256(0x0, 0x40)
            let fromAllowance := sload(fromAllowanceOffset)

            // check if the sender has enough tokens to spend
            // if (fromAllowance >= value || from == msg.sender)
            if and(lt(fromAllowance, _value), not(eq(_from, caller()))) {
                revert(0, 0)
            }

            // reduce allowance of spender
            sstore(fromAllowanceOffset, sub(fromAllowance, _value))
            /*



			 */

            /*


			start transfer


			 */

            // remove balance from _from.
            // it is possible for this operation to underflow
            mstore(0, _from)
            mstore(32, balanceOf.slot)

            let fromOffset := keccak256(0, 64)
            let fromValue := sload(fromOffset)

            // underflow possible
            if gt(_value, fromValue) {
                revert(0, 0)
            }

            // decrease balance of _from
            sstore(fromOffset, sub(fromValue, _value))

            // add balance to target
            // balanceOf++ can't overflow, because totalSupply can't overflow.
            // there is not enough value to overflow.
            mstore(0, _to)
            mstore(32, balanceOf.slot)
            let toOffset := keccak256(0, 64)

            // balance value is sload(toOffset)
            sstore(toOffset, add(sload(toOffset), _value))
        }

        emit Transfer(_from, _to, _value);

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
            // load the value of the allowance
            mstore(0, caller())
            mstore(32, allowance.slot)
            let callerOffset := keccak256(0, 64)

            mstore(0, _spender)
            mstore(32, callerOffset)

            sstore(keccak256(0, 64), _value)
        }

        emit Approval(msg.sender, _spender, _value);

        return true;
    }

    /*


		MINTING AND BURNING


	 */

    function _mint(address to, uint256 amount) internal virtual {
        // increse the balance of the receiver
        assembly {
            // Store num in memory scratch space (note: lookup "free memory pointer" if you need to allocate space)
            mstore(0, to)

            // Store slot number in scratch space after num
            mstore(32, balanceOf.slot)

            // Create hash from previously stored num and slot
            let toAddressOffset := keccak256(0, 64)

            // increase balance of minted address
            sstore(toAddressOffset, add(sload(toAddressOffset), amount))

            // increase total supply
            let currentSupply := sload(totalSupply.slot)
            sstore(totalSupply.slot, add(currentSupply, amount))

            // overflow check
            if lt(sload(totalSupply.slot), currentSupply) {
                revert(0, 0)
            }
        }

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual {
        // reduce balance of from and total supply
        assembly {
            // Store num in memory scratch space (note: lookup "free memory pointer" if you need to allocate space)
            mstore(0, from)

            // Store slot number in scratch space after num
            mstore(32, balanceOf.slot)

            // Create hash from previously stored num and slot
            let fromAddressOffset := keccak256(0, 64)

            // Load mapping value using the just calculated hash
            let balanceOfAddress := sload(fromAddressOffset)

            // revert possible overflow
            if lt(balanceOfAddress, amount) {
                revert(0, 0)
            }

            // decrease balance of minted address
            // amount is less then balanceOf[from], so it can't overflow
            sstore(fromAddressOffset, sub(balanceOfAddress, amount))

            // total supply is at least balanceOf[from], so it can't overflow
            sstore(totalSupply.slot, sub(sload(totalSupply.slot), amount))
        }

        emit Transfer(from, address(0), amount);
    }
}
