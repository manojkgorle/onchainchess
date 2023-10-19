//SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

//@todo for now create a workable model, later we may convert it to a library. & add multi game support
//@todo target 1: workable chessboard with all correct logic (no bugs)
//@todo target 2: reusable 8x8 module & gas optimisation
//@todo target 3: Chess engine

//@dev inspired from fiveoutofnine/fiveoutofnine-chess
library ChessGame {
    // start board position
    // white on top, black on bottom. key starts from 0 lasts to 63. 8x8 chess board

    // 00110100001001100101001001000011
    // 00010001000100010001000100010001
    // 00000000000000000000000000000000
    // 00000000000000000000000000000000
    // 00000000000000000000000000000000
    // 00000000000000000000000000000000
    // 10011001100110011001100110011001
    // 10111100101011101101101011001011

    // 0011010000100110010100100100001100010001000100010001000100010001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001001100110011001100110011001100110111100101011101101101011001011
    // decimal representation of board
    // 23587976066105624102652026731540702020911522231275872573279604863738831624907
    // core var
    // uint256 public board = 0x34265243111111110000000000000000000000000000000099999999BCAEDACB;

    function makeMove(uint256 move) public returns (bool) {}

    /// @notice Check if a move is legal.
    /// @dev Explain to a developer any extra details
    /// @param  move, is bit packed with 6bits representing from & to positon each
    /// @return Documents the return variables of a contract’s function state variable

    function isLegalMove(
        uint256 board,
        uint256 move
    ) internal pure returns (bool) {
        // get piece
        uint256 fromIndex = move >> 6;
        uint256 toIndex = move & 0x3F; // try arranging at the appropriate place
        // the piece at from index
        uint256 pieceAtFromIndex = (board >> ((fromIndex) << 2)) & 0xF;
        // index change
        uint256 indexChange = fromIndex > toIndex
            ? fromIndex - toIndex
            : toIndex - fromIndex;
        // get row & column
        if (indexChange == 0) return false;
        uint256 row = fromIndex / 8 + 1;
        uint256 column = (fromIndex % 8) + 1;
        // get color
        uint256 pieceAtToIndex = (board >> (toIndex << 2)) & 0xF;
        bool toIndexPiecePresent = pieceAtToIndex != 0 ? true : false;
        if (pieceAtToIndex != 0 && pieceAtToIndex >> 3 == pieceAtFromIndex >> 3)
            return false; // if there is a piece at toIndex, check if the piece is of same color with piece at fromIndex

        // get valid diff
        // check if on edges: call a internal function which returns a bool, along side with the edge details
        //@todo below implementatin seems flawed. as it is not presenting the exact data. We need to rewrite isOnEdge to return data in detail

        // edge case not auto validated sceneraios

        // @todo pawn
        if (pieceAtFromIndex & 7 == 1) {
            //black or white pawn --> a pawn

            // @todo topOrBottom implementation
            if (fromIndex >= toIndex) return false;
            if (indexChange == 8) return true;

            if (column == 1) {
                if (indexChange == 9) return toIndexPiecePresent ? true : false;
            } else if (column == 8) {
                if (indexChange == 7) return toIndexPiecePresent ? true : false;
            }

            if (indexChange == 7 || indexChange == 9)
                return toIndexPiecePresent ? true : false;
        }

        // @todo knight
        if (pieceAtFromIndex & 7 == 4) {
            // @todo for knight the 2 margin rule
            // the corners
            if (
                (((row == 1 && column == 1) || (row == 1 && column == 8)) &&
                    toIndex > fromIndex) ||
                (((row == 8 && column == 1) || (row == 8 && column == 8)) &&
                    toIndex < fromIndex)
            ) return (0x810000 >> indexChange) & 1 == 1 ? true : false; // consider case of hardcoding the place values instead of performing multiple checks
            // for row 2 & 7
            if (
                (((row == 1 && column == 2) || (row == 1 && column == 7)) &&
                    toIndex > fromIndex) ||
                (((row == 8 && column == 2) || (row == 8 && column == 7)) &&
                    toIndex < fromIndex)
            ) return (0xA1000 >> indexChange) & 1 == 1 ? true : false;
            //@todo
            // 2 row 2 col things left
            // gen 2 col 2 row things left
            if (row == 1)
                // for column 2 & 7
                // for row 1 & 8
                return
                    toIndex > fromIndex
                        ? (0x28440 >> indexChange) & 1 == 1 ? true : false
                        : false;
            if (row == 8)
                return
                    toIndex < fromIndex
                        ? (0x28440 >> indexChange) & 1 == 1 ? true : false
                        : false;
            // for column 1 & column 8
            if (column == 1 || column == 8)
                return (0x8040 >> indexChange) & 1 == 1 ? true : false;

            return (0x28440 >> indexChange) & 1 == 1 ? true : false;
        }

        // @todo king
        if (pieceAtFromIndex & 7 == 6) {
            bool topOrBottom;
            bool leftOrRight;
            bool isTop;
            bool isLeft;
            // bool check
            if (row == 1 || row == 8) topOrBottom = true;
            if (column == 1 || column == 8) leftOrRight = true;
            if (row == 1) isTop = true;
            if (column == 1) isLeft = true;
            // bool check done
            //non boundary case
            if (!topOrBottom && !leftOrRight)
                return (0x382 >> indexChange) & 1 == 1 ? true : false;
            //code for boundary condition
            if (topOrBottom && leftOrRight) {
                if (isTop && isLeft && toIndex > fromIndex)
                    return (0xC002 >> indexChange) & 1 == 1 ? true : false;
                if (isTop && !isLeft && toIndex > fromIndex)
                    return (0xC000 >> indexChange) & 1 == 1 ? true : false;
                if (isTop && !isLeft && toIndex < fromIndex)
                    return indexChange == 1 ? true : false;
                if (!isTop && isLeft && toIndex < fromIndex)
                    return (0xC000 >> indexChange) & 1 == 1 ? true : false;
                if (!isTop && isLeft && toIndex > fromIndex)
                    return indexChange == 1 ? true : false;
                if (!isTop && !isLeft && toIndex < fromIndex)
                    return (0xC002 >> indexChange) & 1 == 1 ? true : false;
                return false;
            } else if (topOrBottom) {
                if (isTop)
                    return
                        toIndex > fromIndex
                            ? (0x382 >> indexChange) & 1 == 1 ? true : false
                            : indexChange == 1
                            ? true
                            : false;
                else
                    return
                        toIndex < fromIndex
                            ? (0x382 >> indexChange) & 1 == 1 ? true : false
                            : indexChange == 1
                            ? true
                            : false;
            } else if (leftOrRight) {
                if (isLeft)
                    return
                        toIndex > fromIndex
                            ? (0xC002 >> indexChange) & 1 == 1 ? true : false
                            : (0xC000 >> indexChange) & 1 == 1
                            ? true
                            : false;
                else
                    return
                        toIndex > fromIndex
                            ? (0xC000 >> indexChange) & 1 == 1 ? true : false
                            : (0xC002 >> indexChange) & 1 == 1
                            ? true
                            : false;
            }
            return false;
        }

        // @todo rook
        if (pieceAtFromIndex & 7 == 3) {
            if ((row - 1) * 8 - 1 <= toIndex && toIndex <= (row) * 8 - 1)
                return true;

            if (
                column <= toIndex &&
                toIndex <= 55 + column &&
                indexChange % 8 == 0
            ) return true;

            return false;
        }
        // @todo bishop
        if (pieceAtFromIndex & 7 == 2) {
            if (indexChange % 7 == 0) {
                if (toIndex <= fromIndex) {
                    uint256 maxL = row <= 9 - column ? row - 1 : 8 - column;
                    if (toIndex >= fromIndex - maxL * 7) return true;
                } else {
                    uint256 maxL = row <= 9 - column ? column - 1 : 8 - row;
                    if (toIndex <= fromIndex + maxL * 7) return true;
                }
                return false;
            }
            if (indexChange % 9 == 0) {
                if (toIndex <= fromIndex) {
                    uint256 maxL = row <= 9 - column ? column - 1 : 8 - row;
                    if (toIndex >= fromIndex - maxL * 9) return true;
                } else {
                    uint256 maxL = row <= 9 - column ? row - 1 : 8 - column;
                    if (toIndex <= fromIndex + maxL * 9) return true;
                }
            }
            return false;
        }
        // @todo queen = bishop + rook
        if (pieceAtFromIndex & 7 == 5) {
            // rooks code of validation
            if ((row - 1) * 8 - 1 <= toIndex && toIndex <= (row) * 8 - 1)
                return true;

            if (
                column <= toIndex &&
                toIndex <= 55 + column &&
                indexChange % 8 == 0
            ) return true;

            // bishops code of validation
            if (indexChange % 7 == 0) {
                if (toIndex <= fromIndex) {
                    uint256 maxL = row <= 9 - column ? row - 1 : 8 - column;
                    if (toIndex >= fromIndex - maxL * 7) return true;
                } else {
                    uint256 maxL = row <= 9 - column ? column - 1 : 8 - row;
                    if (toIndex <= fromIndex + maxL * 7) return true;
                }
                return false;
            }
            if (indexChange % 9 == 0) {
                if (toIndex <= fromIndex) {
                    uint256 maxL = row <= 9 - column ? column - 1 : 8 - row;
                    if (toIndex >= fromIndex - maxL * 9) return true;
                } else {
                    uint256 maxL = row <= 9 - column ? row - 1 : 8 - column;
                    if (toIndex <= fromIndex + maxL * 9) return true;
                }
            }
            return false;
        }
        return false;
    }

    function applyMove(
        uint256 _board,
        uint256 _move
    ) internal pure returns (uint256) {
        unchecked {
            // Get piece at the from index
            uint256 piece = (_board >> ((_move >> 6) << 2)) & 0xF;
            // Replace 4 bits at the from index with 0000
            _board &= type(uint256).max ^ (0xF << ((_move >> 6) << 2));
            // Replace 4 bits at the to index with 0000
            _board &= type(uint256).max ^ (0xF << ((_move & 0x3F) << 2));
            // Place the piece at the to index
            _board |= (piece << ((_move & 0x3F) << 2));

            return _board;
        }
    }

    function isCapture() internal {}

    function swapPawn(
        uint256 fromIndex,
        uint256 toIndex,
        uint256 indexChange,
        bool toIndexPiecePresent,
        bool isTop
    ) internal pure returns (bool) {}

    //@todo try developing many functions as pure & only applyMove as stateChanging function; we validate things off chain & later update on chain. But we need to have checks induced;
    //@todo convert pieceAtFromIndex to a var & reuse the variable
}
