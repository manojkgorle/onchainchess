## Roadmap

- **8x8 Chess Smart contract library** ✅
- **Rust server for connecting smartcontracts & backend** 
- **Front end supporting Account abstraction** 
- **Real time multiplayer game**
- **Zk implementation to verify if the board is a result of applied moves**

## Credits
This library design is highly inspired with 6-by-6 chess board of @fiveoutofnine.

## Usage Directions

### Game Initialisation

```Solidity
    function startGame(address _player1) public payable;
    event gameStarted(gameId, player0, player1, StakeAmount);
```
`msg.sender` is `player0`.
`player0` starts the game with `white`.

### Making moves
```Solidity
    function move(uint256 gameId,uint256 _move) public returns (bool isMoveSuccessful);
```

_move = decimal(bitPack(binary(6 bit fromPosition),binary(6 bit toPosition)))

Example: move from 5(000101) to 63(111111)

```
_move = decimal(000101111111)
_move = 383
```
## Initial Game State

#### Numerical representations of board positions

        0  1  2  3  4  5  6  7
        8  9  10 11 12 13 14 15 
        16 17 18 19 20 21 22 23
        24 25 26 27 28 29 30 31
        32 33 34 35 36 37 38 39 
        40 41 42 43 44 45 46 47
        48 49 50 51 52 53 54 55
        56 57 58 59 60 61 62 63

#### Representation of initial state of board
                                                White
        0011 0100 0010 0110 0101 0010 0100 0011        ♖ ♘ ♗ ♕ ♔ ♗ ♘ ♖
        0001 0001 0001 0001 0001 0001 0001 0001        ♙ ♙ ♙ ♙ ♙ ♙ ♙ ♙
        0000 0000 0000 0000 0000 0000 0000 0000
        0000 0000 0000 0000 0000 0000 0000 0000
        0000 0000 0000 0000 0000 0000 0000 0000
        0000 0000 0000 0000 0000 0000 0000 0000
        1001 1001 1001 1001 1001 1001 1001 1001        ♟ ♟ ♟ ♟ ♟ ♟ ♟ ♟
        1011 1100 1010 1110 1101 1010 1100 1011        ♜ ♞ ♝ ♛ ♚ ♝ ♞ ♜
                                                Black

Chess board is defined by a single `uint256`. Every 4 bits on the board represents a position on the board.
So, each piece on the board is also 4 bit.
First bit of a piece denotes color(0 is white and 1 is black).
Rest of the three bits denote type.
```
        | Bits | # | Type   |
        | ---- | - | ------ |
        | 000  | 0 | Empty  |
        | 001  | 1 | Pawn   |
        | 010  | 2 | Bishop |
        | 011  | 3 | Rook   |
        | 100  | 4 | Knight |
        | 101  | 5 | Queen  |
        | 110  | 6 | King   |
```

## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Woke import remappings

Command Pallet
```
 Tools for Solidity: Import Foundry Remappings
```

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
