// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

/*

	Utility functions

 */

function isPeriod(uint8 c) pure returns (bool) {
    return c == 0x2e;
}

function isAsterisk(uint8 c) pure returns (bool) {
    return c == 0x2a;
}

function isDollar(uint8 c) pure returns (bool) {
    return c == 0x24;
}

function isPlus(uint8 c) pure returns (bool) {
    return c == 0x2b;
}

function isQuestionMark(uint8 c) pure returns (bool) {
    return c == 0x3f;
}

function isEscape(uint8 c) pure returns (bool) {
    return c == 0x5c;
}

function isEscapeSequence(uint8[] memory re) pure returns (bool) {
    return re.length > 1 && isEscape(re[0]);
}

function isLeftParanthesis(uint8 c) pure returns (bool) {
    return c == 0x28;
}

function isRightParanthesis(uint8 c) pure returns (bool) {
    return c == 0x29;
}

function isAlternation(uint8[] memory seq) pure returns (bool) {
    return
        seq.length > 1 &&
        isLeftParanthesis(seq[0]) &&
        isRightParanthesis(seq[seq.length - 1]);
}

function isSet(uint8[] memory seq) pure returns (bool) {
    return
        seq.length > 1 &&
        isLeftBracket(seq[0]) &&
        isRightBracket(seq[seq.length - 1]);
}

function isUnit(uint8[] memory seq) pure returns (bool) {
    return
        isEscapeSequence(seq) ||
        isSet(seq) ||
        isPeriod(seq[0]) ||
        isLiteral(seq[0]);
}

function isLeftBracket(uint8 c) pure returns (bool) {
    return c == 0x5b;
}

function isRightBracket(uint8 c) pure returns (bool) {
    return c == 0x5d;
}

function isPipe(uint8 c) pure returns (bool) {
    return c == 0x7c;
}

function isDigit(uint8 c) pure returns (bool) {
    return c >= 0x30 && c <= 0x39;
}

function isAlpha(uint8 c) pure returns (bool) {
    return (c >= 0x41 && c <= 0x5a) || (c >= 0x61 && c <= 0x7a);
}

function isLiteral(uint8 c) pure returns (bool) {
    // 0x3a is ':' 0x20 is ' ' 0x2f is '/'
    return isAlpha(c) || isDigit(c) || c == 0x3a || c == 0x20 || c == 0x2f;
}

function isOperator(uint8 c) pure returns (bool) {
    return isAsterisk(c) || isPlus(c) || isQuestionMark(c);
}

function isStart(uint8 c) pure returns (bool) {
    // '^' = 0x5e
    return c == 0x5e;
}
