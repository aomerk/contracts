// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

import "hardhat/console.sol";

/// @notice This contract is not optimized for gas usage. Use on your own risk.
/// @title provides an array structure with O(log n) for finding and O(n) for
/// insertion
contract SortedArray {
    /// @dev The how should finder react on not found values.
    enum FindMode {
        EXACT,
        NEXT,
        PREVIOUS
    }

    uint256[] internal _data;

    /// @param _initialData the preexisting data. Throws if not sorted.
    constructor(uint256[] memory _initialData) {
        if (_initialData.length == 0) return;

        for (uint256 i = 0; i < _initialData.length - 1; i++) {
            require(
                _initialData[i] <= _initialData[i + 1],
                "Array is not sorted"
            );

            _data.push(_initialData[i]);
        }
        _data.push(_initialData[_initialData.length - 1]);
    }

    /// @dev returns the item at the given index. Throws if index is out of bounds.
    function get(uint256 _index) public view returns (uint256) {
        require(_index < _data.length, "Index out of bounds");
        return _data[_index];
    }

    /// @dev adds a new value to the array without breaking the sort order.
    /// @return the index of inserted element's index.
    function insert(uint256 _element) public returns (uint256) {
        if (_data.length == 0) {
            _data.push(_element);

            return 0;
        }

        // to avoid O(n) complexity, we use binary search
        // to find the insertion point as well.
        uint256 insertionPoint = findSmallestBiggerIndex(_element);

        // enlarge array.
        _data.push(0);

        // shift array
        for (uint256 i = _data.length - 1; i > insertionPoint; i--) {
            _data[i] = _data[i - 1];
        }

        // insert element to correct index
        _data[insertionPoint] = _element;

        return insertionPoint;
    }

    /// @dev remove matching values from the array without breaking the sort order.
    /// @param _value is the value to remove.
    /// @param _num is the number of matchings to remove. if num is 0, removes all.
    function removeValues(uint256 _value, uint256 _num)
        public
        returns (uint256)
    {
        uint256 totalDeleted = 0;

        for (uint256 i = 0; i < _data.length; ) {
            // if we found a matching value, we need to remove it.
            // no need to increase index, since we are shifting the array
            // once we find it.
            if (_data[i] != _value) {
                i++;
                continue;
            }

            // remove as many as caller wants
            if ((totalDeleted > _num && _num != 0) || _num != 0) continue;

            // remove by shifting array
            for (uint256 j = i; j < _data.length - 1; j++) {
                _data[j] = _data[j + 1];
            }

            _data.pop();
            totalDeleted++;
        }

        return totalDeleted;
    }

    /// @notice Binary searches the data array
    /// Depending on feedbacks, returns the index of element, next element
    /// or previous element.
    /// @return idx is data.length if element is not found.
    function _find(uint256 element, FindMode _fallback)
        internal
        view
        returns (uint256 idx)
    {
        // if the array is empty, we can't find anything
        if (_data.length == 0) return (_data.length);

        // initialize left and right bounds
        uint256 left = 0;
        uint256 right = _data.length - 1;

        // binary search
        while (left <= right) {
            // reset middle element
            uint256 mid = left + (right - left) / 2;

            // if we found the element, return it.
            if (_data[mid] == element) return mid;

            // if element is bigger than the mid, search the right side
            if (element > _data[mid]) {
                left = mid + 1;
                continue;
            }

            // we are going to search the left side, so we need to
            // be sure that there is a left side
            if (mid == 0) break;

            // if element is smaller than the mid, search the left side
            right = mid - 1;
        }

        // handle fallback values,
        // 0 means no fallback.
        if (_fallback == FindMode.EXACT) idx = _data.length;

        // 1 means we want the smallest element that is bigger(or equal) than the
        // element we are looking for
        if (_fallback == FindMode.NEXT) idx = left;

        // 2 means we want the biggest element that is smaller(or equal) than the element
        // element we are looking for
        if (_fallback == FindMode.PREVIOUS) idx = right;

        return idx;
    }

    /// @dev returns the index of the given value in array. Throws if not found.
    /// @param _element the element to find
    /// @return the index of the element
    function find(uint256 _element) public view returns (uint256) {
        uint256 idx = _find(_element, FindMode.EXACT);
        require(idx < _data.length, "Element not found");

        return idx;
    }

    /// @dev returns the index of the smallest element that is bigger(or equal)
    /// in other words, returns the next item's index.
    /// @param _element the element to find
    /// @return the index of the next element
    /// @notice _element = 3, _data = [0, 1, 4, 5], this function returns 2
    function findSmallestBiggerIndex(uint256 _element)
        public
        view
        returns (uint256)
    {
        return _find(_element, FindMode.NEXT);
    }

    /// @dev returns the index of the biggest element that is smaller(or equal)
    /// in other words, returns the previous item's index.
    /// @param _element the element to find
    /// @return the index of the next element
    /// @notice _element = 3, _data = [0, 2, 4, 6], this function returns 1
    function findBiggestSmallerIndex(uint256 _element)
        public
        view
        returns (uint256)
    {
        return _find(_element, FindMode.NEXT);
    }

    function getLength() public view returns (uint256) {
        return _data.length;
    }

    /// @dev get all elements in the array
    function getAll() public view returns (uint256[] memory) {
        return _data;
    }

    // function print() public view {
    //     for (uint256 i = 0; i < _data.length; i++) {
    //         console.log("data[%d] = %d", i, _data[i]);
    //     }
    // }
}
