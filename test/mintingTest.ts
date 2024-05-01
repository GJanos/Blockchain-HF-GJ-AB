const { expect } = require("chai");
const { ethers } = require("hardhat");
const { loadFixture } = require("@nomicfoundation/hardhat-toolbox/network-helpers");

describe("Mint Cryptomons", function () {

    async function deployMintManagerCrtFxt() {
        const [owner, addr1] = await ethers.getSigners();
        const mintManager = await ethers.deployContract("MintManager");
        await mintManager.waitForDeployment();
        return { mintManager, owner, addr1 };
    }
    
    it("Should mint all initial NFTs and assign them to the contract itself", async function () {
        const { mintManager } = await loadFixture(deployMintManagerCrtFxt);

        const ownerOfFirst = await mintManager.ownerOf(1);
        const ownerOfSecond =await mintManager.ownerOf(2);
        const ownerOfThird = await mintManager.ownerOf(3);

        expect(ownerOfFirst).to.equal(mintManager);
        expect(ownerOfSecond).to.equal(mintManager);
        expect(ownerOfThird).to.equal(mintManager);

        const totalSupply = await mintManager.totalSupply();
        const storedNFT = await mintManager.storedNFTCnt();
        expect(totalSupply).to.equal(storedNFT);

        const allSold = await mintManager.areNFTsAllSold();
        expect(allSold).to.equal(false);
    });
        
    it("Should correctly mint all Cryptomons with their respective attributes", async function () {
        const { mintManager } = await loadFixture(deployMintManagerCrtFxt);

        const CRYPTOMONS = [
            {
                uri: "https://ipfs.io/ipfs/QmZ17y3ju3yav3T1LqrcF9o1vct5U5J28ZWPSbSzTFAtpx",
                price: ethers.parseEther("10.0"),
                baseStats: { hp: 10, dmg: 3, def: 1 },
                lvlIncStats: { hp: 2, dmg: 1, def: 1 },
                evoIncStats: { hp: 5, dmg: 3, def: 2 }
            },
            {
                uri: "https://ipfs.io/ipfs/QmSWuLmVkBzRWTiuqYu3f8gKKRQafuhq8fR3ZJaid1Hb34",
                price: ethers.parseEther("9.0"),
                baseStats: { hp: 8, dmg: 4, def: 1 },
                lvlIncStats: { hp: 1, dmg: 2, def: 1 },
                evoIncStats: { hp: 4, dmg: 4, def: 1 }
            },
            {
                uri: "https://ipfs.io/ipfs/QmfF1Tv7ZytfEfm3ZrhEfwFrSnewJLwxdZ8iMF7g2rPYB6",
                price: ethers.parseEther("15.0"),
                baseStats: { hp: 12, dmg: 5, def: 2 },
                lvlIncStats: { hp: 3, dmg: 2, def: 1 },
                evoIncStats: { hp: 10, dmg: 4, def: 2 }
            },
            {
                uri: "https://ipfs.io/ipfs/QmT6TYcaSy8taWpeKw8JbJNBXeoMbNE7MRQFxczAyDjN7Y",
                price: ethers.parseEther("7.0"),
                baseStats: { hp: 8, dmg: 2, def: 0 },
                lvlIncStats: { hp: 2, dmg: 1, def: 1 },
                evoIncStats: { hp: 4, dmg: 3, def: 1 }
            },
            {
                uri: "https://ipfs.io/ipfs/QmPv6Xycdz4bo6f9PijKuqmJc5eJLVbdc4khgtvEaJAK1g",
                price: ethers.parseEther("8.0"),
                baseStats: { hp: 6, dmg: 2, def: 0 },
                lvlIncStats: { hp: 5, dmg: 4, def: 1 },
                evoIncStats: { hp: 11, dmg: 7, def: 3 }
            }
        ];

        const expectedItem = { hp: 0, dmg: 0, def: 0 };

        for (let i = 0; i < CRYPTOMONS.length; i++) {
        const cryptomonAddress = await mintManager.allMintedCryptomonAddresses(i);
        const cryptomon = await ethers.getContractAt("Cryptomon", cryptomonAddress);

        const lvl = await cryptomon.lvl();
        const baseStats = await cryptomon.baseStats();
        const lvlIncStats = await cryptomon.lvlIncStats();
        const evoIncStats = await cryptomon.evoIncStats();
        const price = await cryptomon.price();
        const NFTID = await cryptomon.NFTID();
        const NFTURI = await cryptomon.NFTURI();
        const item = await cryptomon.item();
        const evolved = await cryptomon.evolved();


        expect(lvl).to.equal(1);
        expect(NFTURI).to.equal(CRYPTOMONS[i].uri);
        expect(NFTID).to.equal(i);
        expect(price).to.equal(CRYPTOMONS[i].price);
        expect(baseStats.hp).to.equal(CRYPTOMONS[i].baseStats.hp);
        expect(baseStats.dmg).to.equal(CRYPTOMONS[i].baseStats.dmg);
        expect(baseStats.def).to.equal(CRYPTOMONS[i].baseStats.def);
        expect(lvlIncStats.hp).to.equal(CRYPTOMONS[i].lvlIncStats.hp);
        expect(lvlIncStats.dmg).to.equal(CRYPTOMONS[i].lvlIncStats.dmg);
        expect(lvlIncStats.def).to.equal(CRYPTOMONS[i].lvlIncStats.def);
        expect(evoIncStats.hp).to.equal(CRYPTOMONS[i].evoIncStats.hp);
        expect(evoIncStats.dmg).to.equal(CRYPTOMONS[i].evoIncStats.dmg);
        expect(evoIncStats.def).to.equal(CRYPTOMONS[i].evoIncStats.def);
        expect(evolved).to.equal(false);
        expect(expectedItem.hp).to.equal(item.hp);
        expect(expectedItem.dmg).to.equal(item.dmg);
        expect(expectedItem.def).to.equal(item.def);
    }
    });
    
    it("Owner of minted Cryptomon NFT should change", async function () {
        const { mintManager, _, addr1 } = await loadFixture(deployMintManagerCrtFxt);
        console.log(mintManager);
        const initialOwner = await mintManager.ownerOf(1);
        expect(initialOwner).to.equal(mintManager);

        await mintManager.transferNFTto(addr1.address, 1);

        const newOwner = await mintManager.ownerOf(1);
        expect(newOwner).to.equal(addr1.address);

        const storedNFT = await mintManager.storedNFTCnt();
        expect(storedNFT).to.equal(4);
    });


});