// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "hardhat/console.sol";

import "../cryptomon/Cryptomon.sol";
import "../transactions/TransactionManager.sol";
import "../game/GameManager.sol";
import "./PlayerStates.sol";

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
        ownCryptoNFT(NFTID);
        states.handleEvent(CryptoEvent.ENTERINGBATTLE);
        GameManager(gameMgrAdr).addBattlingPlayer(NFTID);
    }

    function ownCryptoNFT(uint256 NFTID) internal view {
        bool ownsNFT = false;
        for (uint i = 0; i < cryptomons.length; i++) {
            if (Cryptomon(cryptomons[i]).NFTID() == NFTID) {
                ownsNFT = true;
                break;
            }
        }
        require(ownsNFT == true, "Player does not own the specified Cryptomon");
    }

    /*
    function battleNPC(uint256 cryptoID) public {
        // NPC battle logic here
    }
    */

    function attack(uint256 NFTID) onlyOwner public {
        // Attack logic here

        //GameManager(gameMgrAdr).attack(NFTID)
        // game manager has to decide which battle playter is part of, then 
        // emit an attack in its stead against the other player who is in the battle
    }

    function defend() onlyOwner public {
        // Defense logic here
    }

    function special() onlyOwner public {
        // Special move logic here
    }

    function receiveEvent(CryptoEvent _event) public {
        states.handleEvent(_event);
    }

    function pintCurrentState() public view {
        states.pintCurrentState();
    }
}
