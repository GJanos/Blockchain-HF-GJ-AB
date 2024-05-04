// SPDX-License-Identifier: MIT
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

    constructor() {
        currentState = State.IDLE;
        eventNames[State.IDLE] = "IDLE";
        eventNames[State.WAITINGFORBATTLE] = "WAITINGFORBATTLE";
        eventNames[State.BATTLING] = "BATTLING";
    }

    function setState(State _state) public {
        currentState = _state;
    }

    function handleEvent(CryptoEvent _event) public {
        if (_event == CryptoEvent.BUY) {
            handleBuy(_event);
        } else if (_event == CryptoEvent.ENTERINGBATTLE) {
            handleEnteringBattle(_event);
        } else if (_event == CryptoEvent.BATTLESTART) {
            handleBattleStart(_event);
        } else if (_event == CryptoEvent.BATTLEEND) {
            handleBattleEnd(_event);
        }else{
            revert("Unhandled or unknown event");
        }
    }

    function handleBuy(CryptoEvent _event) private {
        require(currentState == State.IDLE, "Cannot buy while in a battle");
    }

    function handleEnteringBattle(CryptoEvent _event) private {
        require(currentState == State.IDLE, "Cannot enter battle while in another");
        currentState = State.WAITINGFORBATTLE;
    }

    function handleBattleStart(CryptoEvent _event) private {
        require(currentState == State.WAITINGFORBATTLE ||
                currentState == State.BATTLING, "Already in a battle");
        currentState = State.BATTLING;
    }

    function handleBattleEnd(CryptoEvent _event) private {
        require(currentState == State.BATTLING, "Not in a battle");
        currentState = State.IDLE;
    }

    function pintCurrentState() public view {
        console.log("Current state: [%s]", eventNames[currentState]);
    }
}