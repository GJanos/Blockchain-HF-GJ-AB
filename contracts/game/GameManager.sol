// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "hardhat/console.sol";

import "./Battle.sol";
import "./IBattleStrategy.sol";
import "../player/Player.sol";
import "../player/PlayerStates.sol";


contract GameManager {

    struct SearchResult{
        uint8 whichPlayer;
        Battle battle;
    }

    PlayersForBattle[] public battleQueue;
    Battle[] public activeBattles;

    constructor() {
    }

    function addBattlingPlayer(address crypto) public {
        address secondPlayerAdr = msg.sender;

        if (battleQueue.length == 1) {
            address firstPlayerAdr = battleQueue[0].adr;

            PlayersForBattle memory secondPlayer = PlayersForBattle(secondPlayerAdr, crypto);
            PlayersForBattle memory firstPlayer = PlayersForBattle(firstPlayerAdr, battleQueue[0].crypto);
            
            Battle battle = new Battle(firstPlayer, secondPlayer, new TwoPlayerBattleStrategy());
            activeBattles.push(battle);

            Player(firstPlayerAdr).receiveEvent(CryptoEvent.BATTLESTART);
            Player(secondPlayerAdr).receiveEvent(CryptoEvent.BATTLESTART);
            
            battleQueue.pop();

        } else {
            battleQueue.push(PlayersForBattle(secondPlayerAdr, crypto));
        }
    }

    function playerAction(PlayerAction _action) public {
        SearchResult memory result = findPlayersBattle(msg.sender);

        result.battle.handleEvent(result.whichPlayer == 1
        ? BattleEvent.PLAYER1ACTION : BattleEvent.PLAYER2ACTION);

        result.battle.playerAction(_action);
    }

    function findPlayersBattle(address player) public view returns (SearchResult memory) {
        for (uint i = 0; i < activeBattles.length; i++) {
            if (activeBattles[i].getPlayer1Address() == player) {
                return SearchResult(1, activeBattles[i]);
            }else if(activeBattles[i].getPlayer2Address() == player) {
                return SearchResult(2, activeBattles[i]);
            }
        }
        revert("Player must be inside a battle");
    }
    /*
    // Simulated battle with an NPC
    function battleNPC(address _addr, uint _cryptoID) public {
        // NPC battle logic goes here
        emit BattleStarted(_addr, address(0), _cryptoID, 0);
    }
    */

    function getBattleQueueLength() public view returns (uint) {
        return battleQueue.length;
    }

    function getActiveBattlesLength() public view returns (uint) {
        return activeBattles.length;
    }
}

