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

    /// @dev reverts if sender is not an owner
    modifier onlySigners() {
        for (uint256 i = 0; i < signers.length; i++) {
            if (msg.sender != signers[i]) {
                continue;
            }

            _;
            return;
        }

        revert("not a signer");
    }

    /// @dev submits a transaction to the multisig wallet.
    /// @param _to the address to send the transaction to
    /// @param _amount the amount of ether to send
    /// @return _newId the transaction id just submitted
    function submitTransaction(
        address _to,
        uint256 _amount,
        bytes memory data
    ) public onlySigners returns (uint256 _newId) {
        transactions.push(Transaction(_to, _amount, false, data));

        emit Submit(msg.sender, _to, transactions.length - 1, _amount, data);

        return transactions.length - 1;
    }

    /// @dev sender confirms or denies a transaction. Emits Confirm event.
    /// @param _transactionId the id of the transaction to confirm or deny, Reverts
    /// if the transaction is not found.
    /// @param _confirmed true if the transaction should be confirmed, false if it should be denied.
    function confirmTransaction(uint256 _transactionId, bool _confirmed)
        public
        onlySigners
    {
        require(_transactionId < transactions.length, "no such transaction");

        isConfirmed[msg.sender][_transactionId] = _confirmed;

        emit Confirm(
            msg.sender,
            transactions[_transactionId]._to,
            _transactionId,
            transactions[_transactionId]._value,
            transactions[_transactionId].data
        );
    }

}
