// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

interface INode {
    function id() external view returns (uint256);

    function next() external view returns (uint256);

    function setNext(uint256) external;

    function value() external view returns (bytes memory);
}
