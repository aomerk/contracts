// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

function concat(uint8[] memory a, uint8[] memory b)
    view
    returns (uint8[] memory)
{
    uint256 length = a.length + b.length;
    uint8[] memory result = new uint8[](length);

    for (uint256 i = 0; i < a.length; i++) {
        result[i] = a[i];
    }
    for (uint256 i = 0; i < b.length; i++) {
        result[i + a.length] = b[i];
    }

    return result;
}

function splice(
    uint8[] memory seq,
    uint256 start,
    uint256 end
) view returns (uint8[] memory) {
    uint256 length = end - start;
    uint8[] memory result = new uint8[](length);
    for (uint256 i = 0; i < length; i++) {
        result[i] = seq[start + i];
    }

    return result;
}

function multiplyStr(uint8[] memory seq, uint256 multiplier)
    view
    returns (uint8[] memory)
{
    uint256 length = seq.length * multiplier;
    uint8[] memory result = new uint8[](length);

    for (uint256 i = 0; i < length; i++) {
        result[i] = seq[i % seq.length];
    }

    return result;
}

function itoa(uint8[] memory seq) view returns (bytes memory) {
    uint256 length = seq.length;
    bytes memory result = new bytes(length);
    for (uint256 i = 0; i < length; i++) {
        result[i] = bytes1(seq[i]);
    }

    return result;
}

function splitPipes(uint8[] memory seq) view returns (uint8[][] memory) {
    // 0x7c = '|'
    return split(splice(seq, 1, seq.length - 1), 0x7c);
}

// Pipe, matches either the regular expression preceding it or the regular
//  expression following it. For example, the below regex matches the date format
//  of MM/DD/YYYY, MM.DD.YYYY and MM-DD-YYY. It also matches MM.DD-YYYY, etc.
function split(uint8[] memory seq, uint8 token)
    view
    returns (uint8[][] memory)
{
    /*

	Array initialization to avoid storage allocation

	 */
    uint256 numGroups = 1;
    uint256 iterator;

    while (iterator < seq.length) {
        // if you hit |,go to increase group count
        if (token == (seq[iterator])) {
            numGroups++;
        }

        iterator++;
    }
    uint8[][] memory result = new uint8[][](numGroups);

    uint256 groupIdx = 0;
    uint256 elementIdx = 0;
    iterator = 0;
    uint256 lastIdx = 0;
    while (iterator < seq.length) {
        if (token == seq[iterator]) {
            result[groupIdx] = new uint8[](elementIdx);
            groupIdx++;
            lastIdx = iterator;
        }
        elementIdx++;

        iterator++;
    }

    result[groupIdx] = new uint8[](seq.length - lastIdx - 1);

    /*

	Split the sequence into pipe arrays

 	*/
    groupIdx = 0;
    elementIdx = 0;
    iterator = 0;
    while (iterator < seq.length) {
        if (token != (seq[iterator])) {
            result[groupIdx][elementIdx] = seq[iterator];
            elementIdx++;
        }

        // next alternation group
        if (token == seq[iterator]) {
            groupIdx++;
            elementIdx = 0;
        }
        iterator++;
    }

    return result;
}

function find(uint8[] memory seq, uint8 token) view returns (uint256) {
    uint256 i;
    for (i = 0; i < seq.length; i++) {
        if (seq[i] == token) {
            return i;
        }
    }

    return seq.length;
}
