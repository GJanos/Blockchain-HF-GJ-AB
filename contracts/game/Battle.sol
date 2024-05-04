// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "hardhat/console.sol";

import "./IBattleStrategy.sol";
import "../player/Player.sol";

struct PlayersForBattle {
    address adr;
    address crypto;
}

contract Battle {

    PlayersForBattle public player1;
    PlayersForBattle public player2;

    bool public finished = false;

    IBattleStrategy strategy;

    constructor(PlayersForBattle memory _player1,
                PlayersForBattle memory _player2,
                IBattleStrategy _strategy) {
        player1 = _player1;
        player2 = _player2;
        strategy = _strategy;
    }

    function handleEvent(BattleEvent _event) public {
        strategy.handleEvent(_event);
    }

    function playerAction(PlayerAction _action) public {
        Cryptomon crypto1 = Cryptomon(player1.crypto);
        Cryptomon crypto2 = Cryptomon(player2.crypto);

        // needed to switch player1 and player2 here
        if(strategy.getState() == BattleState.PLAYER2TURN){

            if (_action == PlayerAction.ATTACK){
                crypto1.attack(crypto1, crypto2);
            }else if(_action == PlayerAction.DEFEND){
                crypto1.defend(crypto1);
            }else if(_action == PlayerAction.SPECIAL){
                crypto1.special(crypto1, crypto2);
            }else{
                revert("Unknown player action");
            }
            
        }else if (strategy.getState() == BattleState.PLAYER1TURN){

            if (_action == PlayerAction.ATTACK){
                crypto2.attack(crypto2, crypto1);
            }else if(_action == PlayerAction.DEFEND){
                crypto2.defend(crypto2);
            }else if(_action == PlayerAction.SPECIAL){
                crypto2.special(crypto2, crypto1);
            }else{
                revert("Unknown player action");
            }

        }else{
            revert("This should not be happening");
        }
        printBattleStats();

        if(crypto1.isDead()){
            console.log("Player 1's crypto is dead");
            console.log("Player 2 wins");
            console.log("\n----------!!-----------\n---!---------------!---\n");
            console.log("\n");
            strategy.rewardLoser(player1.adr, crypto1);
            strategy.rewardWinner(player2.adr, crypto2);

            endBattle(player1.adr, player2.adr);
        }else if(crypto2.isDead()){
            console.log("Player 2's crypto is dead");
            console.log("Player 1 wins");
            console.log("\n----------!!-----------\n---!---------------!---\n");
            console.log("\n");
            strategy.rewardLoser(player2.adr, crypto2);
            strategy.rewardWinner(player1.adr, crypto1);

            endBattle(player1.adr, player2.adr);
        }
    }

    function printBattleStats() public view {
        console.log("Player 1: ");
        Cryptomon(player1.crypto).printBattleStats();
        console.log("\n");
        console.log("Player 2: ");
        Cryptomon(player2.crypto).printBattleStats();
        console.log("\n---------------------\n---------------------\n");
        console.log("\n");
    }

    function endBattle(address player1Adr, address player2Adr) internal {
        Player(player1Adr).receiveEvent(CryptoEvent.BATTLEEND);
        Player(player2Adr).receiveEvent(CryptoEvent.BATTLEEND);
        player1 = PlayersForBattle(address(0), address(0));
        player2 = PlayersForBattle(address(0), address(0));
        finished = true;
    }

    function getPlayer1Address() public view returns (address) {
        return player1.adr;
    }

    function getPlayer1Crypto() public view returns (address) {
        return player1.crypto;
    }

    function getPlayer2Address() public view returns (address) {
        return player2.adr;
    }

    function getPlayer2Crypto() public view returns (address) {
        return player2.crypto;
    }
}