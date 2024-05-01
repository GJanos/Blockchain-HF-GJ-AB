// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "hardhat/console.sol";

import "./MintManager.sol";

contract TransactionManager {
    MintManager public mintManager;

    constructor() {
        mintManager = new MintManager();
    }

    function buyCrypto(uint256 NFTID) public payable returns (address) {
        address cryptomonAddress = mintManager.allMintedCryptomonAddresses(NFTID);
        
        require(cryptomonAddress != address(0x0),
        "Tried to buy a Cryptomon, that is already sold");
        
        Cryptomon crypto = Cryptomon(cryptomonAddress);
        uint price = crypto.price();

        require(msg.value >= price,
        "Sent too few weis");

        if (msg.value > price) {
            payable(msg.sender).transfer(msg.value - price);
        }

        return mintManager.transferNFTto(msg.sender, NFTID);
    }

    function listCryptoNFTs() public view {
        for (uint i = 0; i < mintManager.totalSupply(); i++) {
            address cryptomonAddress = mintManager.allMintedCryptomonAddresses(i);
            console.log("NFT address: %s",cryptomonAddress);
            Cryptomon(cryptomonAddress).print();
        }
    }
}
