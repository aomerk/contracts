// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

/// @notice A standard interface allows any tokens on Ethereum to be re-used by
/// other applications: from wallets to decentralized exchanges.
contract ERC20Constants {
    string public constant ERR_BAD_ADDRESS = "BAD_ADDRESS";
    string public constant ERR_UNAUTHORIZED = "UNAUTH";
    string public constant ERR_TOKEN_EXISTS = "ERR_TOKEN_EXISTS";
    string public constant ERR_NOT_ENOUGH_TOKENS = "ERR_NOT_ENOUGH_TOKENS";
}

/// @title ERC-721 Non-Fungible Token Standard implementation.
/// @dev See https://eips.ethereum.org/EIPS/eip-721
///  Note: the ERC-165 identifier for this interface is 0x80ac58cd.
abstract contract ERC20Naive is ERC20Constants {
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
    /// @param value uint256 the amount of tokens to be transferred.
    /// @return success True if the transfer was successful.
    /// @notice Throws if the transfer is not successful. Throws if the
    /// message caller’s account balance does not have enough tokens to spend.
    /// MUST fire Transfer event.
    function transfer(address _to, uint256 value)
        public
        returns (bool success)
    {
        return _unsafeTransfer(msg.sender, _to, value);
    }

    /// @dev Transfers _value amount of tokens from address _from to address _to,
    ///  and MUST fire the Transfer event.
    /// @param _from address The address to transfer from.
    /// @param _to address The address the tokens are transferred to.
    /// @param value uint256 the amount of tokens to be transferred.
    /// @return success True if the transfer was successful.
    /// @notice Throws if the transfer is not successful. Throws if the
    /// message caller’s account balance does not have enough tokens to spend.
    /// Throws unless the _from account has deliberately authorized the sender
    /// of the message via some mechanism
    /// MUST fire Transfer event.
    function transferFrom(
        address _from,
        address _to,
        uint256 value
    ) public returns (bool success) {
        require(_checkAuth(_from, msg.sender, value), ERR_UNAUTHORIZED);

        return _unsafeTransfer(_from, _to, value);
    }

    function _checkAuth(
        address _from,
        address _spender,
        uint256 _value
    ) internal view returns (bool success) {
        return allowance[_from][_spender] >= _value || _from == _spender;
    }

    function _unsafeTransfer(
        address _from,
        address _to,
        uint256 _value
    ) internal returns (bool success) {
        if (balanceOf[_from] < _value) return false;

        unchecked {
            balanceOf[_from] -= _value;
            // balanceOf can't overflow, because totalSupply can't overflow.
            // max a person can have is totalSupply.
            balanceOf[_to] += _value;
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
        allowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;
    }

    /*


		MINTING AND BURNING


	 */

    function _mint(address to, uint256 amount) internal virtual {
        totalSupply += amount;

        // this one can't overflow because the above line would overflow first
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual {
        require(balanceOf[from] >= amount, ERR_NOT_ENOUGH_TOKENS);

        // this one can't overflow because the above line would overflow first
        unchecked {
            // amount is less then balanceOf[from], so it can't overflow
            balanceOf[from] -= amount;
            // total supply is at least balanceOf[from], so it can't overflow
            totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
    }
}
