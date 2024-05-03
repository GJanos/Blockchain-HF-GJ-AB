// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "hardhat/console.sol";

import "./Battle.sol";
import "../player/Player.sol";
import "../player/PlayerStates.sol";


contract GameManager {

    PlayersForBattle[] public battleQueue;
    Battle[] public activeBattles;

    constructor() {

    }

    // Function to add a player to the battle queue
    function addBattlingPlayer(uint256 NFTID) public {
        address player1Adr = msg.sender;

        if (battleQueue.length == 1) {
            address player2Adr = battleQueue[0].adr;

            PlayersForBattle memory player1 = PlayersForBattle(player1Adr, NFTID);
            PlayersForBattle memory player2 = PlayersForBattle(player2Adr, battleQueue[0].NFTID);

            Battle battle = new Battle(player1, player2);
            activeBattles.push(battle);

            Player(player1Adr).receiveEvent(CryptoEvent.BATTLESTART);
            Player(player2Adr).receiveEvent(CryptoEvent.BATTLESTART);

            battleQueue.pop();

        } else {
            battleQueue.push(PlayersForBattle(player1Adr, NFTID));
        }
    }
    

    // Function to simulate a battle between two players
    function battle2Players(address player1, uint NFTID1, address player2, uint NFTID2) internal {
        // Battle logic goes here
    }
    /*

    // Simulated battle with an NPC
    function battleNPC(address _addr, uint _cryptoID) public {
        // NPC battle logic goes here
        emit BattleStarted(_addr, address(0), _cryptoID, 0);
    }

    // Player actions during the battle
    function playerAttack(uint _NFTID) public {
        require(players[msg.sender].isBattling, "You are not currently in a battle.");
        emit PlayerAction(msg.sender, "attack");
    }

    function playerDefend(uint _NFTID) public {
        require(players[msg.sender].isBattling, "You are not currently in a battle.");
        emit PlayerAction(msg.sender, "defend");
    }

    function playerSpecial(uint _NFTID) public {
        require(players[msg.sender].isBattling, "You are not currently in a battle.");
        emit PlayerAction(msg.sender, "special");
    }
    */

    function getBattleQueueLength() public view returns (uint) {
        return battleQueue.length;
    }

    function getActiveBattlesLength() public view returns (uint) {
        return activeBattles.length;
    }
}

