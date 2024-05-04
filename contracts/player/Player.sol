// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "hardhat/console.sol";

import "../cryptomon/Cryptomon.sol";
import "../transactions/TransactionManager.sol";
import "../game/GameManager.sol";
import "./PlayerStates.sol";

enum PlayerAction {
    ATTACK,
    DEFEND,
    SPECIAL
}

contract Player {
    address public owner;
    address public tsxMgrAdr;
    address public gameMgrAdr;
    address[] public cryptomons;
    PlayerStates states;

    constructor(address _tsxMgrAdr, address _gameMgrAdr) {
        owner = msg.sender;
        tsxMgrAdr = _tsxMgrAdr;
        gameMgrAdr = _gameMgrAdr;
        states = new PlayerStates();
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can start this function");
        _;
    }

    function buyCrypto(uint256 NFTID) public payable {
        states.handleEvent(CryptoEvent.BUY);
        address cryptoAdr = TransactionManager(tsxMgrAdr).buyCrypto{value: msg.value}(NFTID);
        cryptomons.push(cryptoAdr);
    }

    function listCryptoNFTs() onlyOwner public {
        states.handleEvent(CryptoEvent.BUY);
        TransactionManager(tsxMgrAdr).listCryptoNFTs();
    }

    function battlePlayers(uint256 NFTID) onlyOwner public {
        address crypto = getCryptomonAddress(NFTID);
        states.handleEvent(CryptoEvent.ENTERINGBATTLE);
        GameManager(gameMgrAdr).addBattlingPlayer(crypto);
    }

    function getCryptomonAddress(uint256 NFTID) public view returns (address) {
        for (uint256 i = 0; i < cryptomons.length; i++) {
            if (Cryptomon(cryptomons[i]).NFTID() == NFTID) {
                return cryptomons[i];
            }
        }
        revert("Cryptomon with the given NFTID not found");
    }

    /*
    function battleNPC(uint256 cryptoID) public {
        // NPC battle logic here
    }
    */

    // player already registered into a battle with a crypto, so we dont need to specify it here
    function attack() onlyOwner public {
        states.handleEvent(CryptoEvent.BATTLESTART);
        GameManager(gameMgrAdr).playerAction(PlayerAction.ATTACK);
    }

    function defend() onlyOwner public {
        states.handleEvent(CryptoEvent.BATTLESTART);
        GameManager(gameMgrAdr).playerAction(PlayerAction.DEFEND);
    }

    function special() onlyOwner public {
        states.handleEvent(CryptoEvent.BATTLESTART);
        GameManager(gameMgrAdr).playerAction(PlayerAction.SPECIAL);
    }

    function receiveEvent(CryptoEvent _event) public {
        states.handleEvent(_event);
    }

    function pintCurrentState() public view {
        states.pintCurrentState();
    }
}
