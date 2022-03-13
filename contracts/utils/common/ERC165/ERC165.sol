// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

/// @notice https://eips.ethereum.org/EIPS/eip-165

interface ERC165 {
    /// @notice Query if a contract implements an interface
    /// @param interfaceID The interface identifier, specified as the 4 byte
    /// signature of the interface
    /// @dev Interface identification is specified in ERC-165.
    /// @return true if contract implements interface with given id, false if not
    /// implemented by contract or if the interface does not exist (0xff).
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}
