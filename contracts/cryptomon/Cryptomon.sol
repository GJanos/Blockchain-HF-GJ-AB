// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "hardhat/console.sol";

import "./ICryptoAction.sol";

struct Stats {
    uint hp;
    uint dmg;
    uint def;
}

struct Meta {
    uint evoLvlCap;
    uint lvlUpXpNeeded;
}

contract Cryptomon {

    uint256 public NFTID;
    string public NFTURI;
    uint256 public price;
    uint public lvl = 1;

    ICryptoActions private actionStrategy;
    Meta private metaData = Meta(3, 10);

    Stats public baseStats;
    Stats public combatStats;
    Stats public lvlIncStats;
    Stats public evoIncStats;
    Stats public item = Stats(0, 0, 0);
    
    bool public evolved = false;

    constructor(
        uint256 _NFTID, string memory _NFTURI, uint256 _price,
        Stats memory _baseStats,
        Stats memory _lvlIncStats,
        Stats memory _evoIncStats,
        ICryptoActions  _actionStrategy
    ) {
        NFTID = _NFTID;
        NFTURI = _NFTURI;
        price = _price;
        baseStats = _baseStats;
        combatStats = _baseStats;
        lvlIncStats = _lvlIncStats;
        evoIncStats = _evoIncStats;

        actionStrategy = _actionStrategy;
    }

    function addItem(Stats memory _item) external {
        item = _item;
    }

    function isDead() external view returns (bool) {
        return combatStats.hp <= 0;
    }

    function lvlUp() public {
        lvl++;
        baseStats.hp += lvlIncStats.hp;
        baseStats.dmg += lvlIncStats.dmg;
        baseStats.def += lvlIncStats.def;
        combatStats.hp += lvlIncStats.hp;
        combatStats.dmg += lvlIncStats.dmg;
        combatStats.def += lvlIncStats.def;
    }

    function evolve() public {
        lvl++;
        actionStrategy = new EvolvedActions();
        evolved = true;
        baseStats.hp += evoIncStats.hp;
        baseStats.dmg += evoIncStats.dmg;
        baseStats.def += evoIncStats.def;
        combatStats.hp += evoIncStats.hp;
        combatStats.dmg += evoIncStats.dmg;
        combatStats.def += evoIncStats.def;
    }

    function attack(Cryptomon crypto, Cryptomon otherCrypto) public {
        actionStrategy.attack(crypto, otherCrypto);
    }

    function defend(Cryptomon crypto) public {
        actionStrategy.defend(crypto);
    }

    function special(Cryptomon crypto, Cryptomon otherCrypto) public {
        actionStrategy.special(crypto, otherCrypto);
    }

    function resetAfterBattle() public {
        combatStats = baseStats;
    }

    function setCombatHp(uint256 newHp) public {
        combatStats.hp = newHp;
    }

    function setCombatDmg(uint256 newDmg) public {
        combatStats.dmg = newDmg;
    }

    function setCombatDef(uint256 newDef) public {
        combatStats.def = newDef;
    }

    function getCombatHp() public view returns (uint256) {
        return combatStats.hp;
    }

    function getCombatDmg() public view returns (uint256) {
        return combatStats.dmg;
    }

    function getCombatDef() public view returns (uint256) {
        return combatStats.def;
    }

    function print() public view {
        console.log("Cryptomon NFTID: %s", NFTID);
        console.log("NFTURI: %s", NFTURI);
        console.log("Price: %s wei", price);
        console.log("Level: %s", lvl);
        console.log("Evolved: %s", evolved ? "Yes" : "No");
        console.log("Base Stats - HP: %s, DMG: %s, DEF: %s", baseStats.hp, baseStats.dmg, baseStats.def);
        console.log("Level Increment Stats - HP: %s, DMG: %s, DEF: %s", lvlIncStats.hp, lvlIncStats.dmg, lvlIncStats.def);
        console.log("Evolution Stats - HP: %s, DMG: %s, DEF: %s", evoIncStats.hp, evoIncStats.dmg, evoIncStats.def);
        console.log("Combat Stats - HP: %s, DMG: %s, DEF: %s", combatStats.hp, combatStats.dmg, combatStats.def);
        console.log("Item Stats - HP: %s, DMG: %s, DEF: %s", item.hp, item.dmg, item.def);
    }
}