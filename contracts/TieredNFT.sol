// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// TODO
// 1. Implement opensea royalties [x] (ownable)
// 3. Create full test suite
// 2. Add uris
// 5. Check security (https://www.youtube.com/watch?v=TmZ8gH-toX0)
// 4. Optimize

/** 
    @title Tiered NFTs
    @author Filip Knyszewski
    @notice An ERC721 contract with 3 tiers with different prices 
    that can all be minted at any time
    @dev All function calls are currently implemented without side effects
*/
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
    string private _baseURIextended;
    mapping(uint256 => string) private _tokenURIs;

    modifier isApprovedOrOwner(uint256 tokenId) {
        require(
            ownerOf(tokenId) == msg.sender,
            "ERC 721: Transfer caller not owner or approved"
        );
        _;
    }

    // https://stackoverflow.com/questions/64200059/solidity-problem-creating-a-struct-containing-mappings-inside-a-mapping
    constructor(string memory name, string memory symbol) ERC721(name, symbol) {
        tiers[0] = Tier({price: 0.42 ether, totalSupply: 0, maxSupply: 300, startingIndex: 0, mintsPerAddress : 3});
        tiers[1] = Tier({price: 0.6 ether, totalSupply: 0, maxSupply: 100, startingIndex: 300, mintsPerAddress : 3});
        tiers[2] = Tier({price: 0.9 ether, totalSupply: 0, maxSupply: 20, startingIndex: 400, mintsPerAddress : 3});
    }

    // @param baseURI_ The baseURI to be used for all the NFTs
    function setBaseURI(string memory baseURI_) external onlyOwner {
        _baseURIextended = baseURI_;
    }

    // @param tokenId The tokenId of token whose URI we are changing
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) external onlyOwner{
        _tokenURIs[tokenId] = _tokenURI;
    }

    function flipSaleState() public onlyOwner {
        saleIsActive = !saleIsActive;
    }

    // @param tier The tier of the NFT to be minted
    function mint(uint tier) public payable {
        require(saleIsActive, "Sale is not active");
        require(tiers[tier].totalSupply + 1 <= tiers[tier].maxSupply, "Exceeded max limit of allowed token mints");
        require(tiers[tier].price <= msg.value, "Not enough ETH to mint the specified tier");
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

    // @return The tokenURI of a specific tokenId
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory){
        return string(abi.encodePacked(_baseURIextended, _tokenURIs[tokenId]));
    }

}