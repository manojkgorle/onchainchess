//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

//@todo for now create a workable model, later we may convert it to a library. & add multi game support
//@todo target 1: workable chessboard with all correct logic (no bugs)
//@todo target 2: reusable 8x8 module & gas optimisation
//@todo target 3: Chess engine --> in rust lang

/// @title 8-by-8 Chess board, with gas optimisations
/// @author manojkgorle
/// @notice Chess board libray to validate & apply moves of a chess game.

library ChessBoard {
    /// @notice Checks, if a move is legal.
    /// @param board, is bit packed with 4 bits representing a piece.
    /// @param  move, is bit packed with 6 bits representing from & to positon each.
    /// @return true if a legal move.

    function isLegalMove(
        uint256 board,
        uint256 move
    ) internal pure returns (bool) {
        uint256 fromIndex = move >> 6;
        uint256 toIndex = move & 0x3F;

        uint256 pieceAtFromIndex = (board >> ((fromIndex) << 2)) & 0xF;

        uint256 indexChange = fromIndex > toIndex
            ? fromIndex - toIndex
            : toIndex - fromIndex;

        if (indexChange == 0) return false;

        uint256 row = fromIndex / 8 + 1;
        uint256 column = (fromIndex % 8) + 1;

        uint256 pieceAtToIndex = (board >> (toIndex << 2)) & 0xF;

        // checks weather a piece is present at to index
        bool toIndexPiecePresent = pieceAtToIndex != 0 ? true : false;

        // checks weather piece at from & to index are of same color
        if (toIndexPiecePresent && pieceAtToIndex >> 3 == pieceAtFromIndex >> 3)
            return false;

        // @todo Pawn validation
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

        // @todo Knight validation
        if (pieceAtFromIndex & 7 == 4) {
            // @todo for knight, margin is 2 unlike others.

            // 101000010001000000_0_000000100010000101 (indexChange > 0)_0_(indexChange < 0)
            if (indexChange < 18) {
                uint256 knightLegalMoves = 0x1010000100010000000000000100010000101;
                // knightLegalMoves = (knightLegalMoves >> 18 ) << 18;
                // The above implementation is ignored to enable standardisation for 7 & 8 row & column
                if (row == 1) {
                    knightLegalMoves &= 0x1010000100010000000000000000000000000;
                } else if (row == 2) {
                    knightLegalMoves &= 0x1010000100010000000000000100010000000;
                } else if (row == 7) {
                    knightLegalMoves &= 0x0000000100010000000000000100010000101;
                } else if (row == 8) {
                    knightLegalMoves &= 0x0000000000000000000000000100010000101;
                }

                if (column == 1) {
                    knightLegalMoves &= 0x1000000100000000000000000100000000100;
                } else if (column == 2) {
                    knightLegalMoves &= 0x1010000100000000000000000100000000101;
                } else if (column == 7) {
                    knightLegalMoves &= 0x1010000000010000000000000000010000101;
                } else if (column == 8) {
                    knightLegalMoves &= 0x0010000000010000000000000000010000001;
                }

                return
                    fromIndex > toIndex
                        ? (((knightLegalMoves & 0x111111111111111111) >>
                            indexChange) &
                            1 ==
                            1)
                            ? true
                            : false
                        : ((knightLegalMoves >> (19 + indexChange)) & 1) == 1
                        ? true
                        : false;
            }

            return false;
        }

        // @todo King
        if (pieceAtFromIndex & 7 == 6) {
            bool topOrBottom;
            bool leftOrRight;
            bool isTop;
            bool isLeft;

            // @todo king has a very different approach, for edge & corner cases.

            if (row == 1 || row == 8) topOrBottom = true;
            if (column == 1 || column == 8) leftOrRight = true;
            if (row == 1) isTop = true;
            if (column == 1) isLeft = true;

            // @todo non boundary condition
            if (!topOrBottom && !leftOrRight)
                return (0x382 >> indexChange) & 1 == 1 ? true : false;

            // @todo boundary conditions

            if (topOrBottom && leftOrRight) {
                // @todo corner conditions
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

        // @todo Rook
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

        // @todo Bishop
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

        // @todo Queen, condtions for Queen = Rook + Bishop
        if (pieceAtFromIndex & 7 == 5) {
            // Rooks code of validation
            if ((row - 1) * 8 - 1 <= toIndex && toIndex <= (row) * 8 - 1)
                return true;

            if (
                column <= toIndex &&
                toIndex <= 55 + column &&
                indexChange % 8 == 0
            ) return true;

            // Bishops code of validation
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
        uint256 board,
        uint256 move
    ) internal pure returns (uint256) {
        unchecked {
            // Piece at the from index
            uint256 piece = (board >> ((move >> 6) << 2)) & 0xF;
            // Replace 4 bits at the from index with 0000
            board &= type(uint256).max ^ (0xF << ((move >> 6) << 2));
            // Replace 4 bits at the to index with 0000
            board &= type(uint256).max ^ (0xF << ((move & 0x3F) << 2));
            // Place the piece at the to index
            board |= (piece << ((move & 0x3F) << 2));

            return board;
        }
    }
}
