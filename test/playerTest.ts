const { expect } = require("chai");
const { ethers } = require("hardhat");
const { loadFixture } = require("@nomicfoundation/hardhat-toolbox/network-helpers");

describe("Player interactions", function () {

    const logSeparator = "\n---------------------\n---------------------\n"

    async function getmintMgrContract(address) {
        const mintMgr = await ethers.getContractFactory("MintManager");
        return mintMgr.attach(address);
    }

    async function playerBuysNFT(player, tsxMgr, NFTID: number, price: number) :Promise<any> {
        // player starts the transaction with the right amount of eth
        const buyersOfferPriceForNFT = ethers.parseEther(`${price}`); // eth is not enough for purchase
        await player.buyCrypto(NFTID, { value: buyersOfferPriceForNFT });

        const mintMgrAdr = await tsxMgr.mintManager();
        const mintMgr = await getmintMgrContract(mintMgrAdr)

        // end owner is the player who initiated the transfer
        const endOwnerAdr = await mintMgr.ownerOf(NFTID);
        expect(endOwnerAdr).to.equal(player);
    }

    async function deployPlayerCrtFxt() {
        const [playerOwner, player2] = await ethers.getSigners();

        const tsxMgr = await ethers.deployContract("TransactionManager");
        await tsxMgr.waitForDeployment();

        const gameMgr = await ethers.deployContract("GameManager");
        await gameMgr.waitForDeployment();

        // player depends on TransactionManager & GameManager contracts
        const Player = await ethers.getContractFactory("Player");
        const player = await Player.deploy(tsxMgr.target, gameMgr.target);
        await player.waitForDeployment();

        return { player, tsxMgr, gameMgr, playerOwner, player2 };
    }

    async function deployPlayerCrtAndGet1NFTFxt() {
        const [playerOwner, player2] = await ethers.getSigners();

        const tsxMgr = await ethers.deployContract("TransactionManager");
        await tsxMgr.waitForDeployment();

        const gameMgr = await ethers.deployContract("GameManager");
        await gameMgr.waitForDeployment();

        // player depends on TransactionManager & GameManager contracts
        const Player = await ethers.getContractFactory("Player");
        const player = await Player.deploy(tsxMgr.target, gameMgr.target);
        await player.waitForDeployment();

        await playerBuysNFT(player, tsxMgr, 2, 15);

        return { player, tsxMgr, gameMgr, playerOwner, player2 };
    }

    
    
    it("Player should lists all minted contracts", async function () {
        let { player, tsxMgr } = await deployPlayerCrtFxt();

        await playerBuysNFT(player, tsxMgr, 1, 9);
        // player begins in IDLE state, it can list/buy cryptos
        //await player.listCryptoNFTs();

        // after entering a battle, player can only continue the battle
        await player.battlePlayers(1);
        await expect(player.listCryptoNFTs()).to.be.revertedWith("Cannot buy while in a battle");
    });

    it("Player should buy a Cryptomon NFT", async function () {
        const { player, tsxMgr } = await deployPlayerCrtFxt();
        
        const mintMgrAdr = await tsxMgr.mintManager();
        const mintMgr = await getmintMgrContract(mintMgrAdr)

        // initial owner is the minter
        const strOwnerAdr = await mintMgr.ownerOf(2);
        expect(strOwnerAdr).to.equal(mintMgr);

        // starter balances
        const srtBuyerBal = BigInt((await ethers.provider.getBalance(player.runner)).toString());
        const srtSellerBal = BigInt((await ethers.provider.getBalance(tsxMgr)).toString());
        
        // player starts the transaction with the right amount of eth
        const buyersOfferPriceForNFT = ethers.parseEther("15.0"); // eth is not enough for purchase
        const tx = await player.buyCrypto(2, { value: buyersOfferPriceForNFT });
        const receipt = await tx.wait();  // Wait for the transaction to be mined

        // end owner is the player who initiated the transfer
        const endOwnerAdr = await mintMgr.ownerOf(2);
        expect(endOwnerAdr).to.equal(player);

        // calculate used gas during transaction
        const gasUsed = BigInt(receipt.gasUsed.toString());
        const gasPrice = BigInt(receipt.gasPrice.toString());
        const gasCost = gasUsed * gasPrice;

        // end balaces
        const endBuyerBal = BigInt((await ethers.provider.getBalance(player.runner)).toString());
        const endSellerBal = BigInt((await ethers.provider.getBalance(tsxMgr)).toString());

        expect(endBuyerBal).to.equal(srtBuyerBal - (buyersOfferPriceForNFT + gasCost), "Players's balance should decrease by the price of the NFT plus gas costs");
        expect(endSellerBal).to.equal(srtSellerBal + buyersOfferPriceForNFT, "Seller's balance should increase by the price of the NFT");
    });

    // test when player sends too few money
    // test when player wants to buy the same NFT twice
    // test when player sends too much money

    it("Player enters a battle", async function () {
        const { player, tsxMgr, gameMgr, playerOwner, player2 } = await deployPlayerCrtAndGet1NFTFxt();
        
        // player1 enters is waiting for opponent
        await player.battlePlayers(2);
        let length = await gameMgr.getBattleQueueLength();
        expect(length).to.equal(1);

        // init player2
        const Player = await ethers.getContractFactory("Player");
        const player2Ctr = await Player.connect(player2).deploy(tsxMgr.target, gameMgr.target);
        await player2Ctr.waitForDeployment();

        // players signers are indeed different
        expect(playerOwner.address).to.equal(player.runner.address);
        expect(player2.address).to.equal(player2Ctr.runner.address);

        // player2 buys NFT then joins for battle
        await playerBuysNFT(player2Ctr, tsxMgr, 3, 7);
        await player2Ctr.battlePlayers(3);

        // player1 and 2 are removed from battle queue and join an actual battle
        length = await gameMgr.getBattleQueueLength();
        expect(length).to.equal(0);
        length = await gameMgr.getActiveBattlesLength();
        expect(length).to.equal(1);
    });
});
