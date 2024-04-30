// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./Item.sol";

contract Cryptomon {

    struct BaseStats {
        uint hp;
        uint dmg;
        uint def;
    }

    struct LvlIncStats {
        uint hp;
        uint dmg;
        uint def;
    }

    struct EvoIncStats {
        uint hp;
        uint dmg;
        uint def;
    }

    BaseStats public baseStats;
    LvlIncStats public lvlIncStats;
    EvoIncStats public evoIncStats;
    Item public item;

    constructor(
        uint baseHp, uint baseDmg, uint baseDef,
        uint lvlIncHp, uint lvlIncDmg, uint lvlIncDef,
        uint evoIncHp, uint evoIncDmg, uint evoIncDef
    ) {
        baseStats = BaseStats(baseHp, baseDmg, baseDef);
        lvlIncStats = LvlIncStats(lvlIncHp, lvlIncDmg, lvlIncDef);
        evoIncStats = EvoIncStats(evoIncHp, evoIncDmg, evoIncDef);
        item = new Item(0, 0, 0);
    }

    function addItem(Item _item) external {
        item = _item;
    }

    function isDead() external view returns (bool) {
        return baseStats.hp <= 0;
    }
}