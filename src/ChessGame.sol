//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Chess.sol";

contract ChessGame {
    using ChessBoard for uint256;

    // 0011010000100110010100100100001100010001000100010001000100010001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001001100110011001100110011001100110111100101011101101101011001011
    // decimal representation of board
    // 23587976066105624102652026731540702020911522231275872573279604863738831624907

    uint256 public board =
        0x34265243111111110000000000000000000000000000000099999999BCAEDACB;
    uint256[6] public pastMoves = [0, 0, 0, 0, 0, 0];

    struct gameData {
        uint256 board;
        address player0;
        address player1;
        bool turn;
        uint256[6] pastMoves;
        uint256 stakeAmount;
        address winner;
    }
    gameData[] public allGames;
    mapping(uint256 => bool) public gameStatus;

    event gameStarted(
        uint256 gameId,
        address player0,
        address player1,
        uint256 stakeAmount
    );

    event gameEnded(uint256 gameId, uint256 finalBoard, address winner);

    event moveApplied(uint256 gameId, bool turn, uint256 move);

    function startGame(address _player1) public payable {
        allGames.push(
            gameData(
                board,
                msg.sender,
                _player1,
                false,
                pastMoves,
                msg.value,
                address(0)
            )
        );
        emit gameStarted(allGames.length - 1, msg.sender, _player1, msg.value);
    }

    function move(
        uint256 gameId,
        uint256 _move
    ) public returns (bool isMoveSuccessful) {
        // validation
        if (gameStatus[gameId] == false) {
            // may not use require & get work done with if else statmenets, think of gas savings.
            gameData memory currentGameData = allGames[gameId];
            bool turn = currentGameData.turn;
            if (
                msg.sender == currentGameData.player0 ||
                msg.sender == currentGameData.player1
            ) {
                if (
                    msg.sender == currentGameData.player0
                        ? turn == false
                        : turn == true
                ) {
                    bool isLegalMove = (currentGameData.board).isLegalMove(
                        _move
                    );
                    if (isLegalMove) {
                        allGames[gameId].board = (currentGameData.board)
                            .applyMove(_move);

                        emit moveApplied(gameId, turn, _move);

                        allGames[gameId].turn = !turn;
                        //@todo push to past moves or keep track offline via events
                        return true;
                    }
                }
            }
        }
        return false;
    }

    /// @notice ends game.
    /// @param _condition 0 withdraw 1 draw 2 win
    /// endGame cases:
    /// player withdraws -> called by withdrawee
    /// game draws --> called by contract owner / server
    /// game won --> called by any
    function endGame(uint8 _condition, uint256 gameId) public returns (bool) {
        // @todo do something creative on the server side, to auto kill the checkmated king. i.e by submitting the tx automatically.
        gameData memory currentGameData = allGames[gameId];
        address player0 = currentGameData.player0;
        address player1 = currentGameData.player1;
        require(player0 == msg.sender || player1 == msg.sender, "Not a player");
        if (_condition == 0) {
            address winner = player0 == msg.sender ? player1 : player0;
            allGames[gameId].winner = winner;
            payable(winner).transfer(currentGameData.stakeAmount);
            emit gameEnded(gameId, currentGameData.board, winner);
            return true;
        } else if (_condition == 1) {
            allGames[gameId].winner = address(1);
            emit gameEnded(gameId, currentGameData.board, address(1));
            return true;
        } else if (_condition == 2) {
            /// @dev will check through board for king piece, if king is absent, the winner will be declared
            (bool isWhiteKingPresent, bool isBlackKingPresent) = currentGameData
                .board
                .isMate();
            if (isWhiteKingPresent && isBlackKingPresent) {
                return false;
            } else {
                address winner = isWhiteKingPresent ? player0 : player1;
                payable(winner).transfer(currentGameData.stakeAmount);
                emit gameEnded(gameId, currentGameData.board, winner);
                return true;
            }
        }
        return false;
    }
}
