// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.0;
import "./Lex.sol";

import "./String.sol";

function scanExpression(uint8[] memory expression)
    pure
    returns (
        uint8[] memory,
        uint8[] memory,
        uint8
    )
{
    uint8[] memory head;
    uint8[] memory tail;
    uint256 expressionEnd;
    uint8 operator;

    // find alternation
    if (isLeftBracket(expression[0])) {
        // find set
        expressionEnd = find(expression, 0x5d) + 1;
        if (expressionEnd - 1 == expression.length) {
            revert("unmatched left bracket");
        }

        head = splice(expression, 0, expressionEnd);
    } else if (isLeftParanthesis(expression[0])) {
        expressionEnd = find(expression, 0x29) + 1;
        if (expressionEnd - 1 == expression.length) {
            revert("unmatched left parenthesis");
        }
        head = splice(expression, 0, expressionEnd);
    } else if (isEscape(expression[0])) {
        expressionEnd += 2;
        head = splice(expression, 0, 2);
    } else {
        expressionEnd = 1;
        head = splice(expression, 0, 1);
    }

    if (
        expressionEnd < expression.length &&
        isOperator(expression[expressionEnd])
    ) {
        operator = expression[expressionEnd];
        expressionEnd++;
    }

    tail = splice(expression, expressionEnd, expression.length);

    return (head, tail, operator);
}

function matchUnit(uint8[] memory expression, uint8[] memory seq)
    pure
    returns (bool)
{
    uint8[] memory head;
    uint8[] memory tail;
    uint8 operator;

    (head, tail, operator) = scanExpression(expression);
    if (seq.length == 0) return false;
    if (head.length == 1 && isLiteral(head[0])) {
        return expression[0] == seq[0];
    } else if (head.length == 1 && isPeriod(head[0])) {
        return true;
    } else if (isEscapeSequence(head)) {
        // \w matches alphanumeric characters
        if (head.length >= 2 && head[0] == 0x5c && head[1] == 0x77) {
            return isAlpha(seq[0]);
        } else if (head.length >= 2 && head[0] == 0x5c && head[1] == 0x64) {
            // \d matches digits
            return isDigit(seq[0]);
        } else if (head.length >= 2 && head[0] == 0x5c && head[1] == 0x2e) {
            // \. matches period
            return isPeriod(seq[0]);
        } else return false;
    } else if (head.length == 1 && isLeftBracket(head[0])) {
        for (uint256 i = 1; i < head.length - 1; i++) {
            if (head[i] == seq[0]) return true;
        }

        return false;
    }

    return false;
}

function matchWithUpperBound(
    uint8[] memory head,
    uint8[] memory seq,
    uint256 matchSize,
    uint256 maxMatchSize
) pure returns (uint256) {
    uint256 submatchLength;
    uint256 cursor = 0;
    while (submatchLength < maxMatchSize || maxMatchSize == 0) {
        bool subMatched;
        uint256 subExpressionSize;
        uint8[] memory newHead = multiplyStr(head, (submatchLength + 1));
        (subMatched, subExpressionSize) = matchExpression(
            newHead,
            seq,
            matchSize
        );
        cursor += subExpressionSize;
        if (subMatched) submatchLength++;
        else break;
    }

    return submatchLength;
}

function matchMultiple(
    uint8[] memory expression,
    uint8[] memory seq,
    uint256 matchSize,
    uint256 minMatchSize,
    uint256 maxMatchSize
) pure returns (bool, uint256) {
    uint8[] memory head;
    uint8[] memory tail;
    uint8 operator;

    (head, tail, operator) = scanExpression(expression);

    uint256 submatchLength = matchWithUpperBound(
        head,
        seq,
        matchSize,
        maxMatchSize
    );

    while (submatchLength >= minMatchSize) {
        bool subMatched;
        uint256 subExpressionSize;
        (subMatched, subExpressionSize) = matchExpression(
            concat(multiplyStr(head, (submatchLength)), tail),
            seq,
            matchSize
        );

        if (subMatched) return (true, subExpressionSize);

        submatchLength--;
    }

    return (false, 0);
}

function matchAsterisk(
    uint8[] memory expression,
    uint8[] memory seq,
    uint256 matchSize
) pure returns (bool, uint256) {
    return matchMultiple(expression, seq, matchSize, 0, 0);
}

function matchPlus(
    uint8[] memory expression,
    uint8[] memory seq,
    uint256 matchSize
) pure returns (bool, uint256) {
    return matchMultiple(expression, seq, matchSize, 1, 0);
}

function matchQuestionMark(
    uint8[] memory expression,
    uint8[] memory seq,
    uint256 matchSize
) pure returns (bool, uint256) {
    return matchMultiple(expression, seq, matchSize, 0, 1);
}

function matchAlternation(
    uint8[] memory expression,
    uint8[] memory seq,
    uint256 matchSize
) pure returns (bool, uint256) {
    uint8[] memory head;
    uint8[] memory tail;
    uint8 operator;

    (head, tail, operator) = scanExpression(expression);

    uint8[][] memory alternatives = splitPipes(head);

    // for at least one alternative, alt + tail must match
    for (uint256 i = 0; i < alternatives.length; i++) {
        bool isMatched;
        uint256 matchingSize;

        (isMatched, matchingSize) = matchExpression(
            concat(alternatives[i], tail),
            seq,
            matchSize
        );

        if (isMatched) return (true, matchingSize);
    }

    return (false, 0);
}

function matchExpression(
    uint8[] memory expression,
    uint8[] memory seq,
    uint256 matchSize
) pure returns (bool, uint256) {
    if (expression.length == 0) return (true, matchSize);
    else if (isDollar(expression[0])) return (seq.length == 0, matchSize);

    uint8[] memory head;
    uint8[] memory tail;
    uint8 operator;

    (head, tail, operator) = scanExpression(expression);

    if (isAsterisk(operator)) return matchAsterisk(expression, seq, matchSize);
    else if (isPlus(operator)) {
        return matchPlus(expression, seq, matchSize);
    } else if (isQuestionMark(operator))
        return matchQuestionMark(expression, seq, matchSize);
    else if (isAlternation(head))
        return matchAlternation(expression, seq, matchSize);
    else if (isUnit(head)) {
        if (matchUnit(expression, seq)) {
            return
                matchExpression(
                    tail,
                    splice(seq, 1, seq.length),
                    matchSize + 1
                );
        }
    } else {
        revert("unrecognized expression");
    }

    return (false, 0);
}

function matchRegExp(uint8[] memory expression, uint8[] memory seq)
    pure
    returns (
        bool,
        uint256,
        uint256
    )
{
    bool isMatched;
    uint256 position;
    uint256 matchLength;
    uint256 maxPosition;

    if (isStart(expression[0])) {
        expression = splice(expression, 1, expression.length);
    } else {
        maxPosition = seq.length - 1;
    }

    while (position <= maxPosition && !isMatched) {
        (isMatched, matchLength) = matchExpression(
            expression,
            splice(seq, position, seq.length),
            0
        );

        if (isMatched) return (true, position, matchLength);

        position++;
    }

    return (false, 0, 0);
}

contract RegExp {
    function matchSingle(uint8 pattern, uint8 expression)
        private
        pure
        returns (bool)
    {
        // empty pattern matches everything
        if (pattern == 0) {
            return true;
        }

        // empty expression matches nothing
        if (expression == 0) {
            return false;
        }

        // 0x2e = '.'
        return pattern == 0x2E || pattern == expression;
    }

    function MatchRegExp(string memory pattern, string memory expression)
        public
        pure
        returns (bool)
    {
        return matches(bytes(pattern), bytes(expression));
    }

    function matches(bytes memory pattern, bytes memory expression)
        public
        pure
        returns (bool)
    {
        bool isMatched;
        uint256 position;
        uint256 matchLength;
        uint8[] memory p = new uint8[](pattern.length);
        uint8[] memory e = new uint8[](expression.length);
        for (uint256 i = 0; i < pattern.length; i++) {
            p[i] = uint8(pattern[i]);
        }
        for (uint256 i = 0; i < expression.length; i++) {
            e[i] = uint8(expression[i]);
        }

        (isMatched, position, matchLength) = matchRegExp(p, e);

        return isMatched;
    }
}
