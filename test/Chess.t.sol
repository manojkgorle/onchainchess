// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {ChessBoard} from "../src/Chess.sol";
import {ChessGame} from "../src/ChessGame.sol";

contract ChessBoardTest is Test {
    ChessGame public game;

    function setUp() public {
        vm.startBroadcast(0x35AeEb1cAc11D7C084e65F3217f111dA03493bB1);
        game = new ChessGame();
        game.startGame(0x49c9bc764d074f84c507637f90201928446C7A92);
        vm.stopBroadcast();
    }

    function testInitialGameState() public {
        (uint256 board, address player0, address player1, , , ) = game.allGames(
            0
        );
        assertEq(player0, 0x35AeEb1cAc11D7C084e65F3217f111dA03493bB1);
        assertEq(player1, 0x49c9bc764d074f84c507637f90201928446C7A92);
        assertEq(
            board,
            0x34265243111111110000000000000000000000000000000099999999BCAEDACB
        );
    }

    function testMove() public {
        vm.startBroadcast(0x35AeEb1cAc11D7C084e65F3217f111dA03493bB1);
        bool isMoveSuccessful = game.move(0, 528);
        assertEq(isMoveSuccessful, true, "Should be true");
        isMoveSuccessful = game.move(0, 528);
        assertEq(isMoveSuccessful, false, "should be false");
    }

    function testTurn() public {
        vm.startBroadcast(0x35AeEb1cAc11D7C084e65F3217f111dA03493bB1);
        bool _a = game.move(0, 528);
        _a;
        (, , , bool turn, , ) = game.allGames(0);
        assertEq(turn, true);
    }
}
