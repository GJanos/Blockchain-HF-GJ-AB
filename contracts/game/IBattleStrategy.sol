// SPDX-License-Identifier: UNLICENSED

/**
 * @title IBattleStrategy
 * @dev Interface for a battle strategy in the Cryptomon game.
 */
pragma solidity ^0.8.4;

import "hardhat/console.sol";

import "../cryptomon/Cryptomon.sol";
import "../player/Player.sol";

/**
 * @dev Enum representing the state of the battle.
 * - PLAYER1TURN: It's player 1's turn.
 * - PLAYER2TURN: It's player 2's turn.
 */
enum BattleState {
    PLAYER1TURN,
    PLAYER2TURN
}

/**
 * @dev Enum representing the events that can occur during a battle.
 * - PLAYER1ACTION: Player 1 performs an action.
 * - PLAYER2ACTION: Player 2 performs an action.
 */
enum BattleEvent {
    PLAYER1ACTION,
    PLAYER2ACTION
}

/**
 * @title IBattleStrategy
 * @dev Interface for a battle strategy in the Cryptomon game.
 */
interface IBattleStrategy {
    /**
     * @dev Handles a battle event.
     * @param _event The battle event to handle.
     */
    function handleEvent(BattleEvent _event) external;

    /**
     * @dev Rewards the loser of the battle.
     * @param crypto The Cryptomon of the loser.
     */
    function rewardLoser(Cryptomon crypto) external;

    /**
     * @dev Rewards the winner of the battle.
     * @param crypto The Cryptomon of the winner.
     */
    function rewardWinner(Cryptomon crypto) external;

    /**
     * @dev Gets the current state of the battle.
     * @return The current state of the battle.
     */
    function getState() external view returns(BattleState);
}

/**
 * @title TwoPlayerBattleStrategy
 * @dev Implementation of the IBattleStrategy interface for a two-player battle.
 */
contract TwoPlayerBattleStrategy is IBattleStrategy {
    BattleState public state;

    constructor() {
        state = BattleState.PLAYER1TURN;
    }

    /**
     * @dev Handles a battle event.
     * @param _event The battle event to handle.
     */
    function handleEvent(BattleEvent _event) external override {
        if (_event == BattleEvent.PLAYER1ACTION) {
            require(state == BattleState.PLAYER1TURN, "Not player 1's turn");
            state = BattleState.PLAYER2TURN;
        }
        else if (_event == BattleEvent.PLAYER2ACTION) {
            require(state == BattleState.PLAYER2TURN, "Not player 2's turn");
            state = BattleState.PLAYER1TURN;
        }
        else{
            revert("Unhandled or unknown battle event");
        }
    }

    /**
     * @dev Rewards the loser of the battle.
     * @param crypto The Cryptomon of the loser.
     */
    function rewardLoser(Cryptomon crypto) external override {
        bool winner = false;
        crypto.gainXp(winner);
        crypto.resetAfterBattle();
    }

    /**
     * @dev Rewards the winner of the battle.
     * @param crypto The Cryptomon of the winner.
     */
    function rewardWinner(Cryptomon crypto) external override {
        bool winner = true;
        crypto.gainXp(winner);
        crypto.resetAfterBattle();
    }

    /**
     * @dev Gets the current state of the battle.
     * @return The current state of the battle.
     */
    function getState() external view returns(BattleState){
        return state;
    }
}
