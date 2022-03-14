// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

import "./INode.sol";

contract Node is INode {
    uint256 public _id;
    uint256 public _next;
    uint256 public _value;

    constructor(
        uint256 i,
        uint256 n,
        uint256 v
    ) {
        _id = i;
        _next = n;
        _value = v;
    }

    function id() external view override returns (uint256) {
        return _id;
    }

    function next() external view override returns (uint256) {
        return _next;
    }

    function value() external view override returns (bytes memory) {
        bytes memory b = new bytes(32);
        uint256 v = _value | 1;
        assembly {
            mstore(add(b, 32), v)
        }
        return b;
    }

    function setNext(uint256 n) external override {
        _next = n;
    }
}
