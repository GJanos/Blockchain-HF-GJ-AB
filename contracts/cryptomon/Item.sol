// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// Contract representing items with a buff
contract Item {
    uint public hp;
    uint public dmg;
    uint public def;

    constructor(uint _hp, uint _dmg, uint _def) {
        hp = _hp;
        dmg = _dmg;
        def = _def;
    }
}