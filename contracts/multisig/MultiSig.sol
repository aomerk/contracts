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

}
