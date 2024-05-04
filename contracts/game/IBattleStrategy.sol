// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "hardhat/console.sol";

import "../cryptomon/Cryptomon.sol";
import "../player/Player.sol";

enum BattleState {
    PLAYER1TURN,
    PLAYER2TURN
}

enum BattleEvent {
    PLAYER1ACTION,
    PLAYER2ACTION
}

// maybe move state here??
interface IBattleStrategy {
    function handleEvent(BattleEvent _event) external;
    function rewardLoser(address player, Cryptomon crypto) external;
    function rewardWinner(address player, Cryptomon crypto) external;
    function getState() external view returns(BattleState);
}


contract TwoPlayerBattleStrategy is IBattleStrategy {
    BattleState public state;

    constructor() {
        state = BattleState.PLAYER1TURN;
    }

    function handleEvent(BattleEvent _event) external override {
        if (_event == BattleEvent.PLAYER1ACTION) {
            require(state == BattleState.PLAYER1TURN, "Not player 1-s turn");
            state = BattleState.PLAYER2TURN;
        }
        else if (_event == BattleEvent.PLAYER2ACTION) {
            require(state == BattleState.PLAYER2TURN, "Not player 2-s turn");
            state = BattleState.PLAYER1TURN;
        }
        else{
            revert("Unhandled or unknown battle event");
        }
    }

    // even player can be compensated with something, currently not implemented
    function rewardLoser(address player, Cryptomon crypto) external override {
        bool winner = false;
        crypto.gainXp(winner);
        crypto.resetAfterBattle();
    }

    function rewardWinner(address player, Cryptomon crypto) external override {
        bool winner = true;
        crypto.gainXp(winner);
        crypto.resetAfterBattle();
    }

    function getState() external view returns(BattleState){
        return state;
    }
}

