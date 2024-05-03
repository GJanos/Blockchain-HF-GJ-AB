// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "hardhat/console.sol";

struct PlayersForBattle {
    address adr;
    uint256 NFTID;
}

contract Battle {

    PlayersForBattle player1;
    PlayersForBattle player2;

    constructor(PlayersForBattle memory _player1,
                PlayersForBattle memory _player2) {
        player1 = _player1;
        player2 = _player2;          
    }
}