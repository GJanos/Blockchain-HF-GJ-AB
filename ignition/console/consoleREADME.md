# This document describes how you can try out the Cryptomons turn-based NFT battling game!

1. ## Open a terminal in the project's root and type:
    ```bash
    npx hardhat console
    ```

2. ## Set up 2 players, that can fight each other:
    ```javascript
    async function setupGame() {
        const [player1Adr, player2Adr] = await ethers.getSigners();
        let tsxMgr = await ethers.deployContract("TransactionManager");
        await tsxMgr.waitForDeployment();
        let gameMgr = await ethers.deployContract("GameManager");
        await gameMgr.waitForDeployment();
        let Player = await ethers.getContractFactory("Player");
        const player1 = await Player.deploy(tsxMgr.target, gameMgr.target);
        await player1.waitForDeployment();
        const player2 = await Player.connect(player2Adr).deploy(tsxMgr.target, gameMgr.target);
        await player2.waitForDeployment();
        return { tsxMgr, gameMgr, player1, player2 };
    }
    ```
    ### after pasting this to the terminal run:
    ```bash
    const { tsxMgr, gameMgr, player1, player2 } = await setupGame()
    ```

3. ## Set up function that enables a player to buy a Cryptomon NFT for a given price:
    ```javascript
    async function playerBuysNFT(player, tsxMgr, NFTID, price) {
        let buyersOfferPriceForNFT = ethers.parseEther(`${price}`);
        await player.buyCrypto(NFTID, { value: buyersOfferPriceForNFT });
    }
    ```
    ### to make player 1 buy NFT 2 for 15 eth do this:
    ```bash
    await playerBuysNFT(player1, tsxMgr, 2, 15)
    ```
    ### to make player 2 buy NFT 0 for 10 eth do this:
    ```bash
    await playerBuysNFT(player2, tsxMgr, 0, 10)
    ```

4. ## Set up a battle between the 2 players and their Cryptomons:
    ### here you can only define NFTID that you own
    ### paste these commands one after the other into the CLI
    ### during battle players can attack or defend, when their Cryptomon evolves they can do a special action as well
    ```bash
    await player1.battlePlayers(2);
    ```
    ```bash
    await player2.battlePlayers(0);
    ```
    ```bash
    await player1.attack();
    ```
    ```bash
    await player2.attack();
    ```
