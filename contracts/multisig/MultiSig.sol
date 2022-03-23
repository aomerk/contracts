// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.0;

contract MultiSig {
    /************************************
     *									*
     *				events				*
     *									*
     ************************************/
    event Submit(
        address indexed _owner,
        address indexed _to,
        uint256 indexed _transactionId,
        uint256 _value,
        bytes _data
    );

    event Confirm(
        address indexed _owner,
        address indexed _to,
        uint256 indexed _transactionId,
        uint256 _value,
        bytes _data
    );

    event Deposit(address indexed _owner, uint256 _value);
    event Execution(uint256 indexed _transactionId, bytes data);

    /************************************
     *									*
     *			definitions 			*
     *									*
     ************************************/
    struct Transaction {
        address _to;
        uint256 _value;
        bool _executed;
        bytes data;
    }

    /************************************
     *									*
     *			state variables			*
     *									*
     ************************************/
    /// @dev did the signer confirm the transaction.
    mapping(address => mapping(uint256 => bool)) public isConfirmed;

    /// @dev all transactions. see definition above.
    Transaction[] private transactions;
    /// @dev signers are the addresses that can approve transactions
    address[] public signers;

    /// @dev required is the number of signers that must approve a transaction for it to be valid
    uint256 public quorum;

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    constructor(address[] memory _signers, uint256 _quorum) {
        require(_signers.length > 0, "no signers provided");
        require(_quorum > 0, "quorum too low");
        require(_quorum <= _signers.length, "quorum too high");

        signers = _signers;
        quorum = _quorum;
    }
}
