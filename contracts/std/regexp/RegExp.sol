// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.0;

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
        uint256 i = 0;
        uint256 j = 0;

        while (i < pattern.length && j < expression.length) {
            uint8 patternToken = uint8(pattern[i]);
            uint8 expressionToken = uint8(expression[j]);

            // 0x2A = '*'
            if (patternToken == 0x2A) {
                // * matches zero or more of the previous token
                while (j < expression.length) {
                    if (
                        matchSingle(uint8(pattern[i - 1]), uint8(expression[j]))
                    ) {
                        j++;
                    } else {
                        break;
                    }
                }

                i++;
                continue;
            }

            // 0x2E = '.'
            if (patternToken == 0x2E) {
                // . matches any character
                j++;
                i++;
                continue;
            }

            if (matchSingle(patternToken, expressionToken)) {
                i++;
                j++;
            } else {
                return false;
            }
        }

        return true;
    }
}
