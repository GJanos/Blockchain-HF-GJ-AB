// SPDX-License-Identifier: UNLICENSED

/**
 * @title Player
 * @dev This contract represents a player in the Cryptomon game.
 */
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

    /**
     * @dev Initializes the Player contract.
     * @param _tsxMgrAdr The address of the TransactionManager contract.
     * @param _gameMgrAdr The address of the GameManager contract.
     */
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

    /**
     * @dev Allows the player to buy a Cryptomon NFT.
     * @param NFTID The ID of the Cryptomon NFT to buy.
     */
    function buyCrypto(uint256 NFTID) public payable {
        states.handleEvent(CryptoEvent.BUY);
        address cryptoAdr = TransactionManager(tsxMgrAdr).buyCrypto{value: msg.value}(NFTID);
        cryptomons.push(cryptoAdr);
    }

    /**
     * @dev Lists the player's owned Cryptomon NFTs.
     * Only the owner of the contract can call this function.
     */
    function listCryptoNFTs() onlyOwner public {
        states.handleEvent(CryptoEvent.BUY);
        TransactionManager(tsxMgrAdr).listCryptoNFTs();
    }

    /**
     * @dev Allows the player to battle other players using their Cryptomon.
     * Only the owner of the contract can call this function.
     * @param NFTID The ID of the Cryptomon NFT to use in the battle.
     */
    function battlePlayers(uint256 NFTID) onlyOwner public {
        address crypto = getCryptomonAddress(NFTID);
        states.handleEvent(CryptoEvent.ENTERINGBATTLE);
        GameManager(gameMgrAdr).addBattlingPlayer(crypto);
    }

    /**
     * @dev Returns the address of the Cryptomon with the given NFTID.
     * @param NFTID The ID of the Cryptomon NFT.
     * @return The address of the Cryptomon.
     */
    function getCryptomonAddress(uint256 NFTID) public view returns (address) {
        for (uint256 i = 0; i < cryptomons.length; i++) {
            if (Cryptomon(cryptomons[i]).NFTID() == NFTID) {
                return cryptomons[i];
            }
        }
        revert("Cryptomon with the given NFTID not found");
    }

    /**
     * @dev Allows the player to perform an attack action in a battle.
     * Only the owner of the contract can call this function.
     */
    function attack() onlyOwner public {
        states.handleEvent(CryptoEvent.BATTLESTART);
        GameManager(gameMgrAdr).playerAction(PlayerAction.ATTACK);
    }

    /**
     * @dev Allows the player to perform a defend action in a battle.
     * Only the owner of the contract can call this function.
     */
    function defend() onlyOwner public {
        states.handleEvent(CryptoEvent.BATTLESTART);
        GameManager(gameMgrAdr).playerAction(PlayerAction.DEFEND);
    }

    /**
     * @dev Allows the player to perform a special action in a battle.
     * Only the owner of the contract can call this function.
     */
    function special() onlyOwner public {
        states.handleEvent(CryptoEvent.BATTLESTART);
        GameManager(gameMgrAdr).playerAction(PlayerAction.SPECIAL);
    }

    /**
     * @dev Receives a CryptoEvent and handles it in the PlayerStates contract.
     * @param _event The CryptoEvent to handle.
     */
    function receiveEvent(CryptoEvent _event) public {
        states.handleEvent(_event);
    }

    /**
     * @dev Prints the current state of the PlayerStates contract.
     */
    function pintCurrentState() public view {
        states.pintCurrentState();
    }
}
