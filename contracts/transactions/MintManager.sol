// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

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
    uint public mintedNFTCnt = 0;

    constructor() ERC721("CryptomonNFT", "CM") {
        mintAllNFTs();
        require(mintedNFTCnt == NFTURIs.length,
        "Not correct amount of Cryptomon NFTs minted");
    }

    function mintCryptomonNFT(
        uint256 price,
        BaseStats memory _baseStats,
        LvlIncStats memory _lvlIncStats,
        EvoIncStats memory _evoIncStats
    ) private {
        require(newItemId <= NFTURIs.length,
        "URI index is out of bounds");

        uint256 newItemIdUse = newItemId++;
        _mint(address(this), newItemIdUse);
        _setTokenURI(newItemIdUse, NFTURIs[newItemIdUse]);

        Cryptomon newCryptomon = new Cryptomon(
            newItemIdUse, NFTURIs[newItemIdUse],
            price,
            _baseStats,
            _lvlIncStats,
            _evoIncStats,
            new NormalActions()
        );
        allMintedCryptomonAddresses[newItemIdUse] = address(newCryptomon);
        mintedNFTCnt++;
    }

    function mintAllNFTs() private {
        // Red Cryptomon
        mintCryptomonNFT(10,
                        BaseStats(10, 3, 1),
                        LvlIncStats(2, 1, 1),
                        EvoIncStats(5, 3, 2));

        // White Cryptomon
        mintCryptomonNFT(9,
                        BaseStats(8, 4, 1),
                        LvlIncStats(1, 2, 1),
                        EvoIncStats(4, 4, 1));

        // Black Cryptomon
        mintCryptomonNFT(15,
                        BaseStats(12, 5, 2),
                        LvlIncStats(3, 2, 1),
                        EvoIncStats(10, 4, 2));

        // Blue Cryptomon
        mintCryptomonNFT(7,
                        BaseStats(8, 2, 0),
                        LvlIncStats(2, 1, 1),
                        EvoIncStats(4, 3, 1));

        // Green Cryptomon
        mintCryptomonNFT(8,
                        BaseStats(6, 2, 0),
                        LvlIncStats(5, 4, 1),
                        EvoIncStats(11, 7, 3));
    }


    function transferNFTto(address to, uint256 tokenId) public {
        approve(to, tokenId);
        transferFrom(to, address(this), tokenId);
        allMintedCryptomonAddresses[tokenId] = address(0);
    }
}
