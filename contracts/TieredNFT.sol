// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract TieredNFT is ERC721, Ownable {

    bool saleIsActive = false;

    // The tier struct will keep all the information about the tier
    struct Tier {
        uint256 price;
        uint16 totalSupply;
        uint16 maxSupply;
        uint16 startingIndex;
        uint8 mintsPerAddress;
    }

    // Mapping used to limit the mints per tier
    mapping(uint256 => mapping(address => uint256)) addressCountsPerTier;

    // Mapping where Tier structs are saved
    mapping (uint256=>Tier) tiers;

    // BaseURI
    mapping(uint256 => string) private _tokenURIs;

    modifier isApprovedOrOwner(uint256 tokenId) {
        require(
            ownerOf(tokenId) == msg.sender,
            "ERC 721: Transfer caller not owner or approved"
        );
        _;
    }

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {
        tiers[0] = Tier({price: 0.42 ether, totalSupply: 0, maxSupply: 300, startingIndex: 0, mintsPerAddress : 3});
        tiers[1] = Tier({price: 0.6 ether, totalSupply: 0, maxSupply: 100, startingIndex: 300, mintsPerAddress : 3});
        tiers[2] = Tier({price: 0.9 ether, totalSupply: 0, maxSupply: 20, startingIndex: 400, mintsPerAddress : 3});
    }

    // @param tokenId The tokenId of token whose URI we are changing
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) external onlyOwner{
        _tokenURIs[tokenId] = _tokenURI;
    }

    function flipSaleState() public onlyOwner {
        saleIsActive = !saleIsActive;
    }

    // @param tier The tier of the NFT to be minted
    function mint() public payable {
        require(saleIsActive, "Sale is not active");
        require(msg.value >= tiers[0].price, "Not enough ETH to mint cheapest tier");

        // Pick tier based on payed price
        uint tier = 0;
        if (msg.value == tiers[0].price){
            tier = 0;
        } else if (msg.value == tiers[1].price) {
            tier = 1;
        } else if (msg.value == tiers[2].price){
            tier = 2;
        } else {
            revert(string.concat(
                "Wrong amount of ETH provided. Please send of the following amounts: ",
                Strings.toString(tiers[0].price), ", ",
                Strings.toString(tiers[1].price), ", ",
                Strings.toString(tiers[2].price), " gwei")
             );
        }

        require(tiers[tier].totalSupply + 1 <= tiers[tier].maxSupply, "Exceeded max limit of allowed token mints");
        require(addressCountsPerTier[tier][msg.sender] + 1 <= tiers[tier].mintsPerAddress, "Max number of mints per address reached");

        addressCountsPerTier[tier][msg.sender] = addressCountsPerTier[tier][msg.sender] + 1;
        uint16 tierTotalSuppy = tiers[tier].totalSupply;
        tiers[tier].totalSupply = tierTotalSuppy + 1;
        
        _safeMint(msg.sender, tiers[tier].startingIndex + tierTotalSuppy);
        
    }

    function withdraw() public onlyOwner {
        uint balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    /* ========== VIEW METHODS ========== */


    // @param tier The tier of which the total supply should be returned
    // @return The total supply of the specified tier
    function tierTotalSupply(uint256 tier) external view returns (uint256) {
        return tiers[tier].totalSupply;
    }
    
    // @param tier The tier of which the price should be returned
    // @return The price of the specified tier
    function tierPrice(uint256 tier) external view returns (uint256) {
        return tiers[tier].price;
    }

    // @param tier The tier of which the max supply rice should be returned
    // @return The max supply of the specified tier
    function tierMaxSupply(uint256 tier) external view returns (uint256) {
        return tiers[tier].maxSupply;
    }

    // @param tier The tier of which the max supply rice should be returned
    // @return The max supply of the specified tier
    function tierStartingIndex(uint256 tier) external view returns (uint256) {
        return tiers[tier].startingIndex;
    }


    // @return The max supply of all tiers summed up
    function totalMaxSupply() external view returns (uint256) {
        return tiers[0].maxSupply + tiers[1].maxSupply + tiers[2].maxSupply;
    }

    function divider(uint numerator, uint denominator, uint precision) internal pure returns(uint) {
        return numerator*(uint(10)**uint(precision))/denominator;
    }

}