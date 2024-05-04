// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "hardhat/console.sol";

import "./Cryptomon.sol";

interface ICryptoActions {
    function attack(Cryptomon cryto, Cryptomon otherCrypto) external;
    function defend(Cryptomon cryto) external;
    function special(Cryptomon cryto, Cryptomon otherCrypto) external;
}

// Contract representing normal actions a Cryptomon can take
contract NormalActions is ICryptoActions {
    function attack(Cryptomon crypto, Cryptomon otherCrypto) external override {
        uint256 defenderHp = otherCrypto.getCombatHp();
        uint256 attackerDmg = crypto.getCombatDmg();
        uint256 defenderDef = otherCrypto.getCombatDef();
        
        if(attackerDmg > defenderDef){
            // needed because of uints
            otherCrypto.setCombatHp(defenderHp < (attackerDmg - defenderDef)
            ? 0 : (defenderHp - (attackerDmg - defenderDef)));
        }
    }

    function defend(Cryptomon crypto) external override {
        uint256 currentDef = crypto.getCombatDef();
        crypto.setCombatDef(currentDef * 2);
    }

    function special(Cryptomon crypto, Cryptomon otherCrypto) external override {
        // If normal Crytomon does special attack, it just wasted a turn
    }


}

// Contract representing evolved actions a Cryptomon can take
contract EvolvedActions is ICryptoActions {
    function attack(Cryptomon crypto, Cryptomon otherCrypto) external override {
        uint256 defenderHp = otherCrypto.getCombatHp();
        uint256 attackerDmg = crypto.getCombatDmg();
        uint256 defenderDef = otherCrypto.getCombatDef();

        uint256 additionalEvoDmg = 1;

        if(attackerDmg + additionalEvoDmg > defenderDef){
            // needed because of uints
            otherCrypto.setCombatHp(defenderHp < 
            (attackerDmg + additionalEvoDmg - defenderDef) ?
            0 :
            (defenderHp - (attackerDmg + additionalEvoDmg - defenderDef)));
        }
        
    }

    function defend(Cryptomon crypto) external override {
        uint256 currentDef = crypto.getCombatDef();
        crypto.setCombatDef(currentDef * 3);
    }

    function special(Cryptomon crypto, Cryptomon otherCrypto) external override {
        // Self buff
        crypto.setCombatHp(crypto.getCombatHp() + 1);
        crypto.setCombatDmg(crypto.getCombatDmg() + 1);
        crypto.setCombatDef(crypto.getCombatDef() + 1);

        // Attack
        uint256 defenderHp = otherCrypto.getCombatHp();
        uint256 attackerDmg = crypto.getCombatDmg();
        uint256 defenderDef = otherCrypto.getCombatDef();

        if(attackerDmg > defenderDef){
            // needed because of uints
            otherCrypto.setCombatHp(defenderHp < (attackerDmg - defenderDef)
            ? 0 : (defenderHp - (attackerDmg - defenderDef)));
        }
    }
}
