    /**
     * @title Cryptomon
     * @dev A contract representing a Cryptomon NFT (Non-Fungible Token).
     */
    // SPDX-License-Identifier: UNLICENSED
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
        uint battleWinXp;
        uint battleLoseXp;
    }

    contract Cryptomon {
        // Contract variables and state

        /**
         * @dev The unique identifier of the Cryptomon NFT.
         */
        uint256 public NFTID;

        /**
         * @dev The URI of the Cryptomon NFT.
         */
        string public NFTURI;

        /**
         * @dev The price of the Cryptomon NFT.
         */
        uint256 public price;

        /**
         * @dev The level of the Cryptomon.
         */
        uint public lvl = 1;

        /**
         * @dev The experience points (XP) of the Cryptomon.
         */
        uint public xp = 0;

        /**
         * @dev The strategy contract for performing crypto actions.
         */
        ICryptoActions private actionStrategy;

        /**
         * @dev The metadata for the Cryptomon.
         */
        Meta private metaData = Meta(3, 10, 5, 2);

        /**
         * @dev The base stats of the Cryptomon.
         */
        Stats public baseStats;

        /**
         * @dev The combat stats of the Cryptomon.
         */
        Stats public combatStats;

        /**
         * @dev The level increment stats of the Cryptomon.
         */
        Stats public lvlIncStats;

        /**
         * @dev The evolution increment stats of the Cryptomon.
         */
        Stats public evoIncStats;

        /**
         * @dev The item stats of the Cryptomon.
         */
        Stats public item = Stats(0, 0, 0);

        /**
         * @dev Flag indicating whether the Cryptomon has evolved.
         */
        bool public evolved = false;

        // Contract events

        // Contract constructor and functions

        /**
         * @dev Constructs a new Cryptomon NFT.
         * @param _NFTID The unique identifier of the Cryptomon NFT.
         * @param _NFTURI The URI of the Cryptomon NFT.
         * @param _price The price of the Cryptomon NFT.
         * @param _baseStats The base stats of the Cryptomon.
         * @param _lvlIncStats The level increment stats of the Cryptomon.
         * @param _evoIncStats The evolution increment stats of the Cryptomon.
         * @param _actionStrategy The strategy contract for performing crypto actions.
         */
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

        /**
         * @dev Adds an item to the Cryptomon.
         * @param _item The item stats to be added.
         */
        function addItem(Stats memory _item) external {
            item = _item;
        }

        /**
         * @dev Checks if the Cryptomon is dead.
         * @return A boolean indicating whether the Cryptomon is dead.
         */
        function isDead() external view returns (bool) {
            return combatStats.hp == 0;
        }

        /**
         * @dev Increases the XP of the Cryptomon based on the battle result.
         * @param winner A boolean indicating whether the Cryptomon won the battle.
         */
        function gainXp(bool winner) public {
            uint _xp = winner ? metaData.battleWinXp : metaData.battleLoseXp;
            xp += _xp;
            if (xp >= metaData.lvlUpXpNeeded) {
                lvlUp();
                xp = xp - metaData.lvlUpXpNeeded;
                if (lvl == metaData.evoLvlCap) {
                    evolve();
                }
            }
        }

        /**
         * @dev Levels up the Cryptomon.
         */
        function lvlUp() public {
            lvl++;
            baseStats.hp += lvlIncStats.hp;
            baseStats.dmg += lvlIncStats.dmg;
            baseStats.def += lvlIncStats.def;
            combatStats.hp += lvlIncStats.hp;
            combatStats.dmg += lvlIncStats.dmg;
            combatStats.def += lvlIncStats.def;
        }

        /**
         * @dev Evolves the Cryptomon.
         */
        function evolve() public {
            actionStrategy = new EvolvedActions();
            evolved = true;
            baseStats.hp += evoIncStats.hp;
            baseStats.dmg += evoIncStats.dmg;
            baseStats.def += evoIncStats.def;
            combatStats.hp += evoIncStats.hp;
            combatStats.dmg += evoIncStats.dmg;
            combatStats.def += evoIncStats.def;
        }

        /**
         * @dev Performs an attack action between two Cryptomons.
         * @param crypto The Cryptomon initiating the attack.
         * @param otherCrypto The Cryptomon being attacked.
         */
        function attack(Cryptomon crypto, Cryptomon otherCrypto) public {
            actionStrategy.attack(crypto, otherCrypto);
        }

        /**
         * @dev Performs a defend action for the Cryptomon.
         * @param crypto The Cryptomon defending.
         */
        function defend(Cryptomon crypto) public {
            actionStrategy.defend(crypto);
        }

        /**
         * @dev Performs a special action between two Cryptomons.
         * @param crypto The Cryptomon initiating the special action.
         * @param otherCrypto The Cryptomon being targeted by the special action.
         */
        function special(Cryptomon crypto, Cryptomon otherCrypto) public {
            actionStrategy.special(crypto, otherCrypto);
        }

        /**
         * @dev Resets the combat stats of the Cryptomon after a battle.
         */
        function resetAfterBattle() public {
            combatStats = baseStats;
        }

        /**
         * @dev Sets the combat HP of the Cryptomon.
         * @param newHp The new combat HP value.
         */
        function setCombatHp(uint newHp) public {
            combatStats.hp = newHp;
        }

        /**
         * @dev Sets the combat damage of the Cryptomon.
         * @param newDmg The new combat damage value.
         */
        function setCombatDmg(uint256 newDmg) public {
            combatStats.dmg = newDmg;
        }

        /**
         * @dev Sets the combat defense of the Cryptomon.
         * @param newDef The new combat defense value.
         */
        function setCombatDef(uint256 newDef) public {
            combatStats.def = newDef;
        }

        /**
         * @dev Gets the combat HP of the Cryptomon.
         * @return The combat HP value.
         */
        function getCombatHp() public view returns (uint256) {
            return combatStats.hp;
        }

        /**
         * @dev Gets the combat damage of the Cryptomon.
         * @return The combat damage value.
         */
        function getCombatDmg() public view returns (uint256) {
            return combatStats.dmg;
        }

        /**
         * @dev Gets the combat defense of the Cryptomon.
         * @return The combat defense value.
         */
        function getCombatDef() public view returns (uint256) {
            return combatStats.def;
        }

        /**
         * @dev Sets the XP needed for leveling up the Cryptomon.
         * @param _xp The new XP needed for leveling up.
         */
        function setLvlUpXpNeeded(uint _xp) public {
            metaData.lvlUpXpNeeded = _xp;
        }

        /**
         * @dev Prints the details of the Cryptomon.
         */
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

        /**
         * @dev Prints the battle stats of the Cryptomon.
         */
        function printBattleStats() public view {
            console.log("Cryptomon NFTID: %s", NFTID);
            console.log("Combat Stats - HP: %s, DMG: %s, DEF: %s", combatStats.hp, combatStats.dmg, combatStats.def);
            console.log("Item Stats - HP: %s, DMG: %s, DEF: %s", item.hp, item.dmg, item.def);
        }
    }