const { expect } = require("chai");
const {
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");

describe("Transactions", function () {

    async function deployTransactionManagerCrtFxt() {
        const [deployer, buyer] = await ethers.getSigners();
        const transactionManager = await ethers.deployContract("TransactionManager");
        await transactionManager.waitForDeployment();
        return { transactionManager, deployer, buyer };
    }
    
    it("Should lists all minted contracts", async function () {
        const { transactionManager } = await deployTransactionManagerCrtFxt();
        //await transactionManager.listCryptoNFTs();
    });

    it("Should allow buyer to buy a CryptomonNFT", async function () {
        const { transactionManager, deployer, buyer} = await deployTransactionManagerCrtFxt();
        const mintManager = transactionManager.mintManager;

        // Fetch initial NFT details
        //const initialOwner = await mintManager.ownerOf(1);
        //expect(initialOwner).to.equal(mintManager);

         // Buyer buys the Cryptomon
        const price = ethers.parseEther("9.0");

        // Get initial Ether balances
        const initialBuyerBalance = await ethers.provider.getBalance(buyer);
        const initialManagerBalance = await ethers.provider.getBalance(transactionManager);

        const tx = await transactionManager.connect(buyer).buyCrypto(1, { value: price });
        const receipt = await tx.wait();  // Wait for the transaction to be mined

            // Calculate gas cost
            const gasUsed = receipt.gasUsed;
            const gasPrice = receipt.effectiveGasPrice;  // Directly obtain the effectiveGasPrice from the receipt
            const gasCost = gasUsed.mul(gasPrice);

            // Get final Ether balances
            const finalBuyerBalance = await ethers.provider.getBalance(buyer.address);
            const finalManagerBalance = await ethers.provider.getBalance(transactionManager.address);

            // Assertions
            expect(finalBuyerBalance).to.equal(initialBuyerBalance.sub(price).sub(gasCost), "Buyer's balance should decrease by the price of the NFT plus gas costs");
            expect(finalManagerBalance).to.equal(initialManagerBalance.add(price), "TransactionManager's balance should increase by the price of the NFT");

        //await expect(transactionManager.connect(buyer).buyCrypto(1, { value: price }))
        //.to.emit(transactionManager, "Transfer")
        //.withArgs(transactionManager.address, buyer.address, 1);



        // Verify new owner
        //const newOwner = await mintManager.ownerOf(1);
        //expect(newOwner).to.equal(buyer.address);

        // Verify Ether transfer and balance
        //const balanceAfter = await ethers.provider.getBalance(transactionManager.address);
        //expect(balanceAfter).to.equal(price);

    });
});