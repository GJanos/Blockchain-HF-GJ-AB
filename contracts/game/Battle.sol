// SPDX-License-Identifier: UNLICENSED

/**
 * @title Battle
 * @dev A contract that represents a battle between two players in the Cryptomon game.
 */
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

    /**
     * @dev Initializes a new Battle contract.
     * @param _player1 The address and crypto address of player 1.
     * @param _player2 The address and crypto address of player 2.
     * @param _strategy The battle strategy to be used.
     */
    constructor(
        PlayersForBattle memory _player1,
        PlayersForBattle memory _player2,
        IBattleStrategy _strategy
    ) {
        player1 = _player1;
        player2 = _player2;
        strategy = _strategy;
    }

    /**
     * @dev Handles a battle event.
     * @param _event The battle event to be handled.
     */
    function handleEvent(BattleEvent _event) public {
        strategy.handleEvent(_event);
    }

    /**
     * @dev Performs a player action during the battle.
     * @param _action The player action to be performed.
     */
    function playerAction(PlayerAction _action) public {
        Cryptomon crypto1 = Cryptomon(player1.crypto);
        Cryptomon crypto2 = Cryptomon(player2.crypto);

        if (strategy.getState() == BattleState.PLAYER2TURN) {
            // Player 2's turn
            if (_action == PlayerAction.ATTACK) {
                crypto1.attack(crypto1, crypto2);
            } else if (_action == PlayerAction.DEFEND) {
                crypto1.defend(crypto1);
            } else if (_action == PlayerAction.SPECIAL) {
                crypto1.special(crypto1, crypto2);
            } else {
                revert("Unknown player action");
            }
        } else if (strategy.getState() == BattleState.PLAYER1TURN) {
            // Player 1's turn
            if (_action == PlayerAction.ATTACK) {
                crypto2.attack(crypto2, crypto1);
            } else if (_action == PlayerAction.DEFEND) {
                crypto2.defend(crypto2);
            } else if (_action == PlayerAction.SPECIAL) {
                crypto2.special(crypto2, crypto1);
            } else {
                revert("Unknown player action");
            }
        } else {
            revert("This should not be happening");
        }

        printBattleStats();

        if (crypto1.isDead()) {
            // Player 1's crypto is dead
            console.log("Player 1's crypto is dead");
            console.log("Player 2 wins");
            console.log("\n----------!!-----------\n---!---------------!---\n");
            console.log("\n");
            strategy.rewardLoser(crypto1);
            strategy.rewardWinner(crypto2);
            endBattle(player1.adr, player2.adr);
        } else if (crypto2.isDead()) {
            // Player 2's crypto is dead
            console.log("Player 2's crypto is dead");
            console.log("Player 1 wins");
            console.log("\n----------!!-----------\n---!---------------!---\n");
            console.log("\n");
            strategy.rewardLoser(crypto2);
            strategy.rewardWinner(crypto1);
            endBattle(player1.adr, player2.adr);
        }
    }

    /**
     * @dev Prints the battle statistics.
     */
    function printBattleStats() public view {
        console.log("Player 1: ");
        Cryptomon(player1.crypto).printBattleStats();
        console.log("\n");
        console.log("Player 2: ");
        Cryptomon(player2.crypto).printBattleStats();
        console.log("\n---------------------\n---------------------\n");
        console.log("\n");
    }

    /**
     * @dev Ends the battle and performs necessary cleanup.
     * @param player1Adr The address of player 1.
     * @param player2Adr The address of player 2.
     */
    function endBattle(address player1Adr, address player2Adr) internal {
        Player(player1Adr).receiveEvent(CryptoEvent.BATTLEEND);
        Player(player2Adr).receiveEvent(CryptoEvent.BATTLEEND);
        player1 = PlayersForBattle(address(0), address(0));
        player2 = PlayersForBattle(address(0), address(0));
        finished = true;
    }

    /**
     * @dev Returns the address of player 1.
     * @return The address of player 1.
     */
    function getPlayer1Address() public view returns (address) {
        return player1.adr;
    }

    /**
     * @dev Returns the crypto address of player 1.
     * @return The crypto address of player 1.
     */
    function getPlayer1Crypto() public view returns (address) {
        return player1.crypto;
    }

    /**
     * @dev Returns the address of player 2.
     * @return The address of player 2.
     */
    function getPlayer2Address() public view returns (address) {
        return player2.adr;
    }

    /**
     * @dev Returns the crypto address of player 2.
     * @return The crypto address of player 2.
     */
    function getPlayer2Crypto() public view returns (address) {
        return player2.crypto;
    }
}