    // SPDX-License-Identifier: MIT
    pragma solidity ^0.8.4;

    import "./ICryptoAction.sol";
    import "./CryptoStatAndItem.sol";

    contract Cryptomon {

        uint256 NFTID;
        string NFTURI;
        uint256 price;

        ICryptoActions private actionStrategy;

        BaseStats public baseStats;
        LvlIncStats public lvlIncStats;
        EvoIncStats public evoIncStats;
        Item public item;

        constructor(
            uint256 _NFTID, string memory _NFTURI, uint256 _price,
            BaseStats memory _baseStats,
            LvlIncStats memory _lvlIncStats,
            EvoIncStats memory _evoIncStats,
            ICryptoActions  _actionStrategy
        ) {
            NFTID = _NFTID;
            NFTURI = _NFTURI;
            price = _price;
            baseStats = _baseStats;
            lvlIncStats = _lvlIncStats;
            evoIncStats = _evoIncStats;
            item = Item(0, 0, 0);
            actionStrategy = _actionStrategy;
        }

        function addItem(Item memory _item) external {
            item = _item;
        }

        function isDead() external view returns (bool) {
            return baseStats.hp <= 0;
        }
    }