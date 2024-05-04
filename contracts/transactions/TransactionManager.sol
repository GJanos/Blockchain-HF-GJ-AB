// SPDX-License-Identifier: UNLICENSED

/**
 * @title TransactionManager
 * @dev A contract for managing transactions related to buying and listing Cryptomon NFTs.
 */
pragma solidity ^0.8.4;

import "hardhat/console.sol";

import "./MintManager.sol";

contract TransactionManager {
    MintManager public mintManager;

    constructor() {
        mintManager = new MintManager();
    }

    /**
     * @dev Allows a user to buy a Cryptomon NFT by providing the NFT ID and the required payment.
     * @param NFTID The ID of the Cryptomon NFT to be bought.
     * @return The address of the bought Cryptomon NFT.
     */
    function buyCrypto(uint256 NFTID) public payable returns (address) {
        address cryptomonAddress = mintManager.allMintedCryptomonAddresses(NFTID);
        
        require(cryptomonAddress != address(0x0),
        "Tried to buy a Cryptomon, that is already sold");
        
        Cryptomon crypto = Cryptomon(cryptomonAddress);
        uint price = crypto.price();

        require(msg.value >= price,
        "Sent too few weis");

        if (msg.value > price) {
            // Refund the excess Ether sent by the buyer
            uint excessAmount = msg.value - price;
            (bool sent, ) = msg.sender.call{value: excessAmount}("");
            require(sent, "Failed to send excess Ether");
        }

        return mintManager.transferNFTto(msg.sender, NFTID);
    }

    /**
     * @dev Lists all the owned Cryptomon NFTs along with their addresses and additional information.
     */
    function listCryptoNFTs() public view {
        for (uint i = 0; i < mintManager.totalSupply(); i++) {
            address cryptomonAddress = mintManager.allMintedCryptomonAddresses(i);
            if(cryptomonAddress != address(0x0)){
                console.log("NFT address: %s",cryptomonAddress);
                Cryptomon(cryptomonAddress).print();
                console.log("\n---------------------\n---------------------\n");
            }
        }
    }
}
