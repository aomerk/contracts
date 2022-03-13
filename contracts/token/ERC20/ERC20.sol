// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

/// @notice A standard interface allows any tokens on Ethereum to be re-used by
/// other applications: from wallets to decentralized exchanges.
contract ERC20Constants {
    string public constant ERR_BAD_ADDRESS = "BAD_ADDRESS";
    string public constant ERR_UNAUTHORIZED = "UNAUTH";
    string public constant ERR_TOKEN_EXISTS = "ERR_TOKEN_EXISTS";
    string public constant ERR_TOKEN_NOT_EXISTS = "ERR_TOKEN_NOT_EXISTS";
}

/// @title ERC-721 Non-Fungible Token Standard implementation.
/// @dev See https://eips.ethereum.org/EIPS/eip-721
///  Note: the ERC-165 identifier for this interface is 0x80ac58cd.
abstract contract ERC20 is ERC20Constants {
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

    /*

		EVENTS

	 */
	/// @dev A token contract which creates new tokens SHOULD trigger a Transfer
	/// event with the _from address set to 0x0 when tokens are created.
	/// @notice MUST trigger when tokens are transferred, including zero value transfers.
	/// @param _from address The address the tokens are transferred from.
	/// @param _to address The address the tokens are transferred to.
	/// @param _value uint256 the amount of tokens transferred.
	 event Transfer(address indexed _from, address indexed _to, uint256 _value)

	/// @dev A token contract which creates new tokens SHOULD trigger a Transfer
	///  event with the _from address set to 0x0 when tokens are created.
	/// @notice MUST trigger on any successful call to approve(address _spender, uint256 _value).
	/// @param _owner address The address the approval is for.
	/// @param _spender address The address that is able to spend the funds.
	/// @param _value uint256 The amount of tokens that are approved for the spender.
	 event Approval(address indexed _owner, address indexed _spender, uint256 _value)
}
