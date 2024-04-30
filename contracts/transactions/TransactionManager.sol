// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./MintManager.sol";

contract TransactionManager {
    MintManager public mintManager;

    constructor() {
        mintManager = new MintManager();
    }

    function buyCrypto(uint256 cryptoID) public {

    }

    function listCryptos() public view returns (uint256) {
        return 0;
    }

    /*
    function tradeCryptoForMoney(address otherADR, uint256 cryptoID) public {
        // Transfer NFT ownership in exchange for money (simplified)
        require(mintManager.ownerOf(cryptoID) == msg.sender, "Not the owner of the crypto");
        mintManager.safeTransferFrom(msg.sender, otherADR, cryptoID);
        // Logic to handle money transfer should be implemented here
    }
    */
}
