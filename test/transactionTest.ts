const { expect } = require("chai");
const { ethers } = require("hardhat");
const { loadFixture } = require("@nomicfoundation/hardhat-toolbox/network-helpers");

describe("Transactions", function () {

    const logSeparator = "\n---------------------\n---------------------\n"

    async function deploytsxMgrCrtFxt() {
        const [deployer, buyer] = await ethers.getSigners();
        const tsxMgr = await ethers.deployContract("TransactionManager");
        await tsxMgr.waitForDeployment();
        return { tsxMgr, deployer, buyer };
    }

    async function getmintMgrContract(address) {
        const mintMgr = await ethers.getContractFactory("MintManager");
        return mintMgr.attach(address);
    }
    
    it("Should lists all minted contracts", async function () {
        const { tsxMgr } = await deploytsxMgrCrtFxt();
        await tsxMgr.listCryptoNFTs();
    });

    it("Should allow buyer to buy a CryptomonNFT. Owner changes. Balances change", async function () {
        // get transactionManager and MintManager contracts
        const { tsxMgr, _, buyer } = await deploytsxMgrCrtFxt();
        const mintMgrAdr = await tsxMgr.mintManager();
        const mintMgr = await getmintMgrContract(mintMgrAdr)

        // initial owner is the minter
        const strOwnerAdr = await mintMgr.ownerOf(1);
        expect(strOwnerAdr).to.equal(mintMgr);

        // starter balances
        const srtBuyerBal = BigInt((await ethers.provider.getBalance(buyer.address)).toString());
        const srtSellerBal = BigInt((await ethers.provider.getBalance(tsxMgr)).toString());
        
        // making transaction
        const buyersOfferPriceForNFT = ethers.parseEther("9.0"); // eth is just enough for purchase
        const tx = await tsxMgr.connect(buyer).buyCrypto(1, { value: buyersOfferPriceForNFT });
        const receipt = await tx.wait();  // Wait for the transaction to be mined

        // end owner is the buyer
        const endOwnerAdr = await mintMgr.ownerOf(1);
        expect(endOwnerAdr).to.equal(buyer.address);

        // calculate used gas during transaction
        const gasUsed = BigInt(receipt.gasUsed.toString());
        const gasPrice = BigInt(receipt.gasPrice.toString());
        const gasCost = gasUsed * gasPrice;

        // end balaces
        const endBuyerBal = BigInt((await ethers.provider.getBalance(buyer.address)).toString());
        const endSellerBal = BigInt((await ethers.provider.getBalance(tsxMgr.target)).toString());

        expect(endBuyerBal).to.equal(srtBuyerBal - (buyersOfferPriceForNFT + gasCost), "Buyer's balance should decrease by the price of the NFT plus gas costs");
        expect(endSellerBal).to.equal(srtSellerBal + buyersOfferPriceForNFT, "Seller's balance should increase by the price of the NFT");
    });

    it("Buyer gets its money back, when sending too few ETH", async function () {
        const { tsxMgr, _, buyer } = await deploytsxMgrCrtFxt();
        const mintMgrAdr = await tsxMgr.mintManager();
        const mintMgr = await getmintMgrContract(mintMgrAdr)

        const strOwnerAdr = await mintMgr.ownerOf(1);
        expect(strOwnerAdr).to.equal(mintMgr);

        const srtBuyerBal = BigInt((await ethers.provider.getBalance(buyer.address)).toString());
        const srtSellerBal = BigInt((await ethers.provider.getBalance(tsxMgr)).toString());
        
        const buyersOfferPriceForNFT = ethers.parseEther("1.0"); // eth is not enough for purchase
        await expect(tsxMgr.connect(buyer).buyCrypto(1, { value: buyersOfferPriceForNFT }))
        .to.be.revertedWith("Sent too few weis");

        const endOwnerAdr = await mintMgr.ownerOf(1);
        expect(endOwnerAdr).to.equal(mintMgr); // owner did not change

        const endBuyerBal = BigInt((await ethers.provider.getBalance(buyer.address)).toString());
        const endSellerBal = BigInt((await ethers.provider.getBalance(tsxMgr.target)).toString());

        expect(endBuyerBal).to.be.closeTo(srtBuyerBal, ethers.parseEther("0.01"));
        expect(endSellerBal).to.equal(srtSellerBal);
    });

    // test when buyer wants to buy the same NFT twice
    // test when buyer sends too much money
});