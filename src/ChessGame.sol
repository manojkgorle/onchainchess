//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Chess.sol";

contract ChessGame {
    using ChessBoard for uint256;

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
    }
    gameData[] public allGames;
    mapping(uint256 => bool) public gameStatus;

    event gameStarted(
        uint256 gameId,
        address player0,
        address player1,
        uint256 stakeAmount
    );

    event moveApplied(uint256 gameId, bool turn, uint256 move);

    function startGame(address _player1) public payable {
        allGames.push(
            gameData(board, msg.sender, _player1, false, pastMoves, msg.value)
        );
        emit gameStarted(allGames.length, msg.sender, _player1, msg.value);
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
                        return true;
                    }
                }
            }
        }
        return false;
    }

    function endGame() public {
        // @todo validate all the cases of endgame
        // User withdrawl, or user mutual agree to draw
        // checkmate. i.e. king is not on the board.
        // do something creative on the server side, to auto kill the checkmated king. i.e by submitting the tx automatically.
    }
}
