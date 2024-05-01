// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "hardhat/console.sol";

import "../cryptomon/Cryptomon.sol";
import "../cryptomon/ICryptoAction.sol";
import "../cryptomon/CryptoStatAndItem.sol";

contract MintManager is ERC721URIStorage {
    //had to use own counter instead of Soliditys, it got removed from 
    //"@openzeppelin/contracts": +"5.0.0" onwards 
    uint256 private newItemId = 0;

    string[] private NFTURIs = [
        "https://ipfs.io/ipfs/QmZ17y3ju3yav3T1LqrcF9o1vct5U5J28ZWPSbSzTFAtpx",
        "https://ipfs.io/ipfs/QmSWuLmVkBzRWTiuqYu3f8gKKRQafuhq8fR3ZJaid1Hb34",
        "https://ipfs.io/ipfs/QmfF1Tv7ZytfEfm3ZrhEfwFrSnewJLwxdZ8iMF7g2rPYB6",
        "https://ipfs.io/ipfs/QmT6TYcaSy8taWpeKw8JbJNBXeoMbNE7MRQFxczAyDjN7Y",
        "https://ipfs.io/ipfs/QmPv6Xycdz4bo6f9PijKuqmJc5eJLVbdc4khgtvEaJAK1g"
    ];

    mapping (uint256 => address) public allMintedCryptomonAddresses;
    uint public storedNFTCnt = 0;
    uint public totalSupply = NFTURIs.length;

    constructor() ERC721("CryptomonNFT", "CM") {
        mintAllNFTs();
        require(storedNFTCnt == NFTURIs.length,
        "Not correct amount of Cryptomon NFTs minted");
    }

    function mintCryptomonNFT(
        uint256 price,
        Stats memory _baseStats,
        Stats memory _lvlIncStats,
        Stats memory _evoIncStats
    ) private {
        require(newItemId <= NFTURIs.length,
        "URI index is out of bounds");

        uint256 NFTID = newItemId++;
        _mint(address(this), NFTID);
        _setTokenURI(NFTID, NFTURIs[NFTID]);

        Cryptomon newCryptomon = new Cryptomon(
            NFTID, NFTURIs[NFTID],
            price,
            _baseStats,
            _lvlIncStats,
            _evoIncStats,
            new NormalActions()
        );

        allMintedCryptomonAddresses[NFTID] = address(newCryptomon);
        storedNFTCnt++;
    }

    function mintAllNFTs() private {
        // Red Cryptomon
        mintCryptomonNFT(10 ether,
                        Stats(10, 3, 1),
                        Stats(2, 1, 1),
                        Stats(5, 3, 2));

        // White Cryptomon
        mintCryptomonNFT(9 ether,
                        Stats(8, 4, 1),
                        Stats(1, 2, 1),
                        Stats(4, 4, 1));

        // Black Cryptomon
        mintCryptomonNFT(15 ether,
                        Stats(12, 5, 2),
                        Stats(3, 2, 1),
                        Stats(10, 4, 2));

        // Blue Cryptomon
        mintCryptomonNFT(7 ether,
                        Stats(8, 2, 0),
                        Stats(2, 1, 1),
                        Stats(4, 3, 1));

        // Green Cryptomon
        mintCryptomonNFT(8 ether,
                        Stats(6, 2, 0),
                        Stats(5, 4, 1),
                        Stats(11, 7, 3));
    }

    function transferNFTto(address to, uint256 tokenId) public returns (address){
        // The contract itself is transferring, no need to approve since the contract is the owner and initiates the transfer
        _transfer(address(this), to, tokenId);
        address cryptoAdr = allMintedCryptomonAddresses[tokenId];
        allMintedCryptomonAddresses[tokenId] = address(0);
        storedNFTCnt--;
        return cryptoAdr;
    }


    function areNFTsAllSold() public view returns (bool) {
        return storedNFTCnt == 0;
    }

    
}
