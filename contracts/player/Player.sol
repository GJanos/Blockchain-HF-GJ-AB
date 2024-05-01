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
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can start this function");
        _;
    }

    function battlePlayers(uint256 ownCryptoID) public {
        // Battle logic here
    }


    function battleNPC(uint256 cryptoID) public {
        // NPC battle logic here
    }

    function attack(uint256 NFTID) public {
        // Attack logic here

        //GameManager(gameMgrAdr).attack(NFTID)
        // game manager has to decide which battle playter is part of, then 
        // emit an attack in its stead against the other player who is in the battle
    }

    function defend() public {
        // Defense logic here
    }

    function special() public {
        // Special move logic here
    }

    function buyCrypto(uint256 NFTID) public payable {
        address cryptoAdr = TransactionManager(tsxMgrAdr).buyCrypto(NFTID);
        cryptomons.push(cryptoAdr);
    }

    function listCryptos() public view {
        TransactionManager(tsxMgrAdr).listCryptoNFTs();
    }
}
