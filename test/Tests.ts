const { expect } = require("chai");
const {
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");

describe("Mint Cryptomon", function () {

  async function deployMintManagerCrtFxt() {

    const [owner, addr1, addr2] = await ethers.getSigners();

    const mintManager = await ethers.deployContract("MintManager");

    await mintManager.waitForDeployment();

    return { mintManager, owner, addr1, addr2 };
  }

  describe("Deployment", function () {

    it("Should mint all initial NFTs and assign them to the contract itself", async function () {
        const { mintManager } = await loadFixture(deployMintManagerCrtFxt);
        const ownerOfFirst = await mintManager.allMintedCryptomonAddresses[1];
        const ownerOfSecond = await mintManager.allMintedCryptomonAddresses[2];
        const ownerOfThird = await mintManager.allMintedCryptomonAddresses[3];

        // Verify the contract owner owns the NFTs initially
        expect(ownerOfFirst).to.equal(mintManager.address);
        expect(ownerOfSecond).to.equal(mintManager.address);
        expect(ownerOfThird).to.equal(mintManager.address);

        // Verify the correct amount of NFTs minted
        const totalSupply = await mintManager.mintedNFTCnt();
        expect(totalSupply).to.equal(5);
    });
      
  });

});