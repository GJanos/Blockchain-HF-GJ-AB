// SPDX-License-Identifier: UNLICENSED

/**
 * @title PlayerStates
 * @dev A contract that manages the states and events of a player in a game.
 */
pragma solidity ^0.8.4;

import "hardhat/console.sol";

enum State {
    IDLE,
    WAITINGFORBATTLE,
    BATTLING
}

enum CryptoEvent {
    BUY,
    ENTERINGBATTLE,
    BATTLESTART,
    BATTLEEND
}

contract PlayerStates {
    State currentState;
    mapping (State => string) public eventNames;

    /**
     * @dev Initializes the contract with the initial state and event names.
     */
    constructor() {
        currentState = State.IDLE;
        eventNames[State.IDLE] = "IDLE";
        eventNames[State.WAITINGFORBATTLE] = "WAITINGFORBATTLE";
        eventNames[State.BATTLING] = "BATTLING";
    }

    /**
     * @dev Sets the current state of the player.
     * @param _state The new state to set.
     */
    function setState(State _state) public {
        currentState = _state;
    }

    /**
     * @dev Handles the specified event and performs the necessary actions based on the current state.
     * @param _event The event to handle.
     */
    function handleEvent(CryptoEvent _event) public {
        if (_event == CryptoEvent.BUY) {
            handleBuy();
        } else if (_event == CryptoEvent.ENTERINGBATTLE) {
            handleEnteringBattle();
        } else if (_event == CryptoEvent.BATTLESTART) {
            handleBattleStart();
        } else if (_event == CryptoEvent.BATTLEEND) {
            handleBattleEnd();
        }else{
            revert("Unhandled or unknown event");
        }
    }

    /**
     * @dev Handles the "BUY" event.
     * @dev Throws an error if the current state is not IDLE.
     */
    function handleBuy() private view {
        require(currentState == State.IDLE, "Cannot buy while in a battle");
    }

    /**
     * @dev Handles the "ENTERINGBATTLE" event.
     * @dev Throws an error if the current state is not IDLE.
     * @dev Sets the current state to WAITINGFORBATTLE.
     */
    function handleEnteringBattle() private {
        require(currentState == State.IDLE, "Cannot enter battle while in another");
        currentState = State.WAITINGFORBATTLE;
    }

    /**
     * @dev Handles the "BATTLESTART" event.
     * @dev Throws an error if the current state is not WAITINGFORBATTLE or BATTLING.
     * @dev Sets the current state to BATTLING.
     */
    function handleBattleStart() private {
        require(currentState == State.WAITINGFORBATTLE ||
                currentState == State.BATTLING, "Already in a battle");
        currentState = State.BATTLING;
    }

    /**
     * @dev Handles the "BATTLEEND" event.
     * @dev Throws an error if the current state is not BATTLING.
     * @dev Sets the current state to IDLE.
     */
    function handleBattleEnd() private {
        require(currentState == State.BATTLING, "Not in a battle");
        currentState = State.IDLE;
    }

    /**
     * @dev Prints the current state of the player to the console.
     */
    function pintCurrentState() public view {
        console.log("Current state: [%s]", eventNames[currentState]);
    }
}