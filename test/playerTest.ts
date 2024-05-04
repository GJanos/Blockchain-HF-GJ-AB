const { expect } = require("chai");
const { ethers } = require("hardhat");
const { loadFixture } = require("@nomicfoundation/hardhat-toolbox/network-helpers");

describe("Player interactions", function () {

    const logSeparator = "\n---------------------\n---------------------\n"
    const zeroAddress = '0x0000000000000000000000000000000000000000';

    async function getmintMgrContract(address) {
        const mintMgr = await ethers.getContractFactory("MintManager");
        return mintMgr.attach(address);
    }

    async function getBattleContract(address) {
        const battle = await ethers.getContractFactory("Battle");
        return battle.attach(address);
    }

    async function getCryptoContract(address) {
        const crypto = await ethers.getContractFactory("Cryptomon");
        return crypto.attach(address);
    }

    async function playerBuysNFT(player, tsxMgr, NFTID: number, price: number) {

        const buyersOfferPriceForNFT = ethers.parseEther(`${price}`);
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
    
    it("Players battle for real. Player1 defeats player2", async function () {
        const { player, tsxMgr, gameMgr, playerOwner, player2 } = await deployPlayerCrtAndGet1NFTFxt();
        
        // player1 enters is waiting for opponent
        await player.battlePlayers(2);

        // init player2
        const Player = await ethers.getContractFactory("Player");
        const player2Ctr = await Player.connect(player2).deploy(tsxMgr.target, gameMgr.target);
        await player2Ctr.connect(player2).waitForDeployment();

        // player2 buys NFT then joins for battle
        await playerBuysNFT(player2Ctr, tsxMgr, 3, 7);
        await player2Ctr.battlePlayers(3);

        // get battle contract
        const result = await gameMgr.findPlayersBattle(player);
        const battle = await getBattleContract(result.battle);

        // get cryptos contracts
        const player1CryptoAdr = await battle.getPlayer1Crypto();
        const player2CryptoAdr = await battle.getPlayer2Crypto();
        const player1Crypto = await getCryptoContract(player1CryptoAdr);
        const player2Crypto = await getCryptoContract(player2CryptoAdr);

        // battle starts player1 attacks
        await player.attack();

        // check cryptos combat hp
        await expect(await player1Crypto.getCombatHp()).to.be.equal(12);
        await expect(await player2Crypto.getCombatHp()).to.be.equal(3);

        // player1 attacks again, but it is not his turn
        await expect(player.attack()).to.be.revertedWith("Not player 1's turn");
        
        // player2 attacks
        await player2Ctr.attack();

        // check cryptos combat hp
        await expect(await player1Crypto.getCombatHp()).to.be.equal(11);
        await expect(await player2Crypto.getCombatHp()).to.be.equal(3);

        // player2 attacks again, but it is not his turn
        await expect(player2Ctr.attack()).to.be.revertedWith("Not player 2's turn");

        // player1 defends
        await player.defend();

        // check player1 combat def
        await expect(await player1Crypto.getCombatDef()).to.be.equal(4);

        // player2 attacks
        await player2Ctr.attack();

        // check cryptos combat hp
        // player1's defense was so high, that he took no damage
        await expect(await player1Crypto.getCombatHp()).to.be.equal(11);
        await expect(await player2Crypto.getCombatHp()).to.be.equal(3);

        // player1 attacks and kills player2's crypto
        await player.attack();

        /* check cryptos stats, because battle ended,
        both cryptos stats are reset, and they are rewarded with exp
        they are also removed from battle
        */
        await expect(await player1Crypto.getCombatHp()).to.be.equal(12);
        await expect(await player2Crypto.getCombatHp()).to.be.equal(8);
        await expect(await player1Crypto.xp()).to.be.equal(5);
        await expect(await player2Crypto.xp()).to.be.equal(2);
        await expect(await battle.finished()).to.be.equal(true);
        await expect(await battle.getPlayer1Address()).to.be.equal(zeroAddress);
        await expect(await battle.getPlayer2Address()).to.be.equal(zeroAddress);
        await expect(await battle.getPlayer1Crypto()).to.be.equal(zeroAddress);
        await expect(await battle.getPlayer2Crypto()).to.be.equal(zeroAddress);
    });

    it("Player1 levels up and evolves", async function () {
        const { player, tsxMgr, gameMgr, playerOwner, player2 } = await deployPlayerCrtAndGet1NFTFxt();
        
        // player1 enters is waiting for opponent
        await player.battlePlayers(2);

        // init player2
        const Player = await ethers.getContractFactory("Player");
        const player2Ctr = await Player.connect(player2).deploy(tsxMgr.target, gameMgr.target);
        await player2Ctr.connect(player2).waitForDeployment();

        // player2 buys 3 NFTs then joins for battle
        await playerBuysNFT(player2Ctr, tsxMgr, 0, 10);
        await playerBuysNFT(player2Ctr, tsxMgr, 1, 9);
        await playerBuysNFT(player2Ctr, tsxMgr, 3, 7);
        
        await player2Ctr.battlePlayers(0);

        // get battle contract
        let result = await gameMgr.findPlayersBattle(player);
        let battle = await getBattleContract(result.battle);

        // get cryptos contracts
        let player1CryptoAdr = await battle.getPlayer1Crypto();
        let player2CryptoAdr = await battle.getPlayer2Crypto();
        let player1Crypto = await getCryptoContract(player1CryptoAdr);
        let player2Crypto = await getCryptoContract(player2CryptoAdr);

        // special codition for testing
        await player1Crypto.setLvlUpXpNeeded(5);

        // simulate battle 1
        await player.attack();
        await player2Ctr.attack();
        await player.attack();
        await player2Ctr.attack();
        await player.attack();

        // check cryptos stats, because battle 1 ended
        await expect(await player1Crypto.getCombatHp()).to.be.equal(15);
        await expect(await player1Crypto.getCombatDmg()).to.be.equal(7);
        await expect(await player1Crypto.getCombatDef()).to.be.equal(3);
        await expect(await player1Crypto.xp()).to.be.equal(0);
        await expect(await player1Crypto.lvl()).to.be.equal(2);
        await expect(await battle.finished()).to.be.equal(true);

        // prepare for battle 2
        await player.battlePlayers(2);
        await player2Ctr.battlePlayers(1);

        // get battle contract
        result = await gameMgr.findPlayersBattle(player);
        battle = await getBattleContract(result.battle);

        // get cryptos contracts
        player1CryptoAdr = await battle.getPlayer1Crypto();
        player2CryptoAdr = await battle.getPlayer2Crypto();
        player1Crypto = await getCryptoContract(player1CryptoAdr);
        player2Crypto = await getCryptoContract(player2CryptoAdr);

        // simulate battle 2
        await player.attack();
        await player2Ctr.attack();
        await player.attack();

        // check cryptos stats, because battle 2 ended
        await expect(await player1Crypto.getCombatHp()).to.be.equal(28);
        await expect(await player1Crypto.getCombatDmg()).to.be.equal(13);
        await expect(await player1Crypto.getCombatDef()).to.be.equal(6);
        await expect(await player1Crypto.xp()).to.be.equal(0);
        await expect(await player1Crypto.lvl()).to.be.equal(3);
        await expect(await player1Crypto.evolved()).to.be.equal(true);
        await expect(await battle.finished()).to.be.equal(true);

        // prepare for battle 3 (player1 is evolved)
        await player.battlePlayers(2);
        await player2Ctr.battlePlayers(3);

        // get battle contract
        result = await gameMgr.findPlayersBattle(player);
        battle = await getBattleContract(result.battle);
        // get cryptos contracts
        player1CryptoAdr = await battle.getPlayer1Crypto();
        player2CryptoAdr = await battle.getPlayer2Crypto();
        player1Crypto = await getCryptoContract(player1CryptoAdr);
        player2Crypto = await getCryptoContract(player2CryptoAdr);

        // simulate battle 3  (OTK XD)
        await player.special();

        // check cryptos stats, because battle 3 ended
        await expect(await player1Crypto.getCombatHp()).to.be.equal(31);
        await expect(await player1Crypto.getCombatDmg()).to.be.equal(15);
        await expect(await player1Crypto.getCombatDef()).to.be.equal(7);
        await expect(await player1Crypto.xp()).to.be.equal(0);
        await expect(await player1Crypto.lvl()).to.be.equal(4);
        await expect(await player1Crypto.evolved()).to.be.equal(true);
        await expect(await battle.finished()).to.be.equal(true);
    });
});
