# TieredNFT
An ERC721 NFT project with multiple tiers that can be minted simultaneously

### Use case
In some situations it may make sense to allow for several 'tiers' within one single NFT project. We define tier as a part of a collection with its own specific price, number and max supply.

In this example project we have 3 tiered ERC721 Smartcontract. The total supply is 420, with tier 0 having 300, tier 1 having 100 and tier 2 having 20. This allows us to 'force' the value of certain tokens to be higher then others by just limiting their supply even further.

The SmartContract is written in a way that easily generalizes to a higher number of tiers, with arbitrary price, supply and number of mints per tier


