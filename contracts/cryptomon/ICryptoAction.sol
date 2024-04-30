// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface ICryptoActions {
    function attack() external;
    function defend() external;
    function special() external;
}

// Contract representing normal actions a Cryptomon can take
contract NormalActions is ICryptoActions {
    function attack() external override {
        // Normal attack logic
    }

    function defend() external override {
        // Normal defend logic
    }

    function special() external override {
        // Normal special action logic
    }
}

// Contract representing evolved actions a Cryptomon can take
contract EvolvedActions is ICryptoActions {
    function attack() external override {
        // Evolved attack logic
    }

    function defend() external override {
        // Evolved defend logic
    }

    function special() external override {
        // Evolved special action logic
    }
}
