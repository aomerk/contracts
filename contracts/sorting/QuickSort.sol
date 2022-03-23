// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.0;

contract QuickSort {
    function sort(uint8[] memory input) public pure returns (uint8[] memory) {
        _quickSort8(input, int256(0), int256(input.length - 1));
        return input;
    }
}

function _quickSort256(
    uint256[] memory arr,
    int256 left,
    int256 right
) pure {
    int256 i = left;
    int256 j = right;
    if (i == j) return;

    uint256 pivot = arr[uint256(left + (right - left) / 2)];

    while (i <= j) {
        while (arr[uint256(i)] < pivot) i++;
        while (pivot < arr[uint256(j)]) j--;
        if (i <= j) {
            (arr[uint256(i)], arr[uint256(j)]) = (
                arr[uint256(j)],
                arr[uint256(i)]
            );
            i++;
            j--;
        }
    }
    if (left < j) _quickSort256(arr, left, j);
    if (i < right) _quickSort256(arr, i, right);
}

function _quickSort8(
    uint8[] memory arr,
    int256 left,
    int256 right
) pure {
    int256 i = left;
    int256 j = right;
    if (i == j) return;

    uint8 pivot = arr[uint256(left + (right - left) / 2)];

    while (i <= j) {
        while (arr[uint256(i)] < pivot) i++;
        while (pivot < arr[uint256(j)]) j--;
        if (i <= j) {
            (arr[uint256(i)], arr[uint256(j)]) = (
                arr[uint256(j)],
                arr[uint256(i)]
            );
            i++;
            j--;
        }
    }
    if (left < j) _quickSort8(arr, left, j);
    if (i < right) _quickSort8(arr, i, right);
}
