import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const CryptomonModule = buildModule("CryptomonModule", (m) => {

    const baseAcc = m.getAccount(0);
    const player1Acc = m.getAccount(1);
    const player2Acc = m.getAccount(2);

    const tsxMgr = m.contract("TransactionManager", [], { from: baseAcc });
    const gameMgr = m.contract("GameManager", [], { from: baseAcc });

    const player1 = m.contract("Player", [tsxMgr, gameMgr],
        { from: player1Acc, id: "Player1" });
    const player2 = m.contract("Player", [tsxMgr, gameMgr],
        { from: player1Acc, id: "Player2" });

    return { tsxMgr, gameMgr, player1, player2 };
});

export default CryptomonModule;