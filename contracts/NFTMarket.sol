//contracts/NFTMarket.sol
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "hardhat/console.sol";

contract NFTMarket is ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;
    Counters.Counter private _itemsSold;
    address payable owner;
    uint256 listingPrice = 0.025 ether;

    constructor(){
        owner = payable(msg.sender);
    }
    
    struct MarketItem {
        uint itemId;
        address nftContract;
        uint256 tokenId;
        address payable seller;
        address payable owner;
        bool sold;
    }
    mapping(uint256 => MarketItem) private idToMarketItem;

    event MarketItemCreated(
        uint indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );
    // get listing price of the contract
    function getListPrice() public view returns (uint256){
        return listingPrice;
    }
    // place an item for sale on the market
    function createMarketItem(
        address nftContract,
        uint256 tokenId,
        uint256 price
    ) public payable nonReentrant {
        require(price > 0, "price at least 1 wei");
        require(msg.value == listingPrice, "Price must be equal to listing price");
        _itemIds.increment();
        uint256 itemId = _itemIds.current();

        idToMarketItem[itemId] = MarketItem(
            itemId,
            nftContract,
            tokenId,
            payable(msg.sender),
            payable(address(0)),//owner address
            price,
            false
        );

        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);//transfer ownership 
        
        emit MarketItemCreated(
            itemId,
            nftContract,
            tokenId,
            msg.sender,
            address(0),//owner address
            price,
            false
        );
    } 

    // Create sale of a marketplace item
    // transfer ownership and funds 
    function createMarketSale(
        address nftContract,
        uint256 itemId
    )public payable nonReentrant{
        //using mapping
        uint price = idToMarketItem[itemId].price;
        uint tokenId = idToMarketItem[itemId].tokenId;
        require(msg.value == price, "Please submit the asking price in order to complete the purchase");
        //send money to the seller
        idToMarketItem[itemId].seller.transfer(msg.value);
        //transfer the ownership to buyer
        IERC721(nftContract).transferFrom(address(this),msg.sender, tokenId);
        idToMarketItem[itemId].owner = payable(msg.sender);
        idToMarketItem[itemId].sold = true;
        _itemsSold.increment();
        payable(owner).transfer(listingPrice);
    }

    //view unsold items
    function fetchMarketItems() public view returns (MarketItem[] memory) {
        uint itemCount = _itemIds.current();
        uint unsoldItemCount = _itemIds.current() - _itemsSold.current();
        uint currentIndex = 0;

        MarketItem[] memory items = new MarketItem[] (unsoldItemCount);
        //insert the unsold nft items
        for(uint i = 0; i < itemCount; i++ ){
            if(idToMarketItem[i +  1].owner == address(0)){
                uint currentId = idToMarketItem[i + 1].itemId;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;

            }
        }

        return items;
    }
    // view items user owned themselves
    function fetchMyNFTs() public view returns (MarketItem[] memory) {
        uint totalItemCount = _itemIds.current();
        uint itemCount = 0;
        uint currentIndex = 0;

        for(uint i = 0; i< totalItemCount; i++ ){
            if(idToMarketItem[i +  1].owner == msg.sender){
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[] (itemCount);

        for(uint i = 0; i< itemCount; i++ ){
            if(idToMarketItem[i +  1].owner == msg.sender){
                uint currentId = idToMarketItem[i + 1].itemId;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    //view items user created themselves
    function fetchItemsCreated() public view returns (MarketItem[] memory) {
        uint totalItemCount = _itemIds.current();
        uint itemCount = 0;
        uint currentIndex = 0;

        for(uint i = 0; i< totalItemCount; i++ ){
            if(idToMarketItem[i +  1].seller == msg.sender){
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[] (itemCount);

        for(uint i = 0; i< itemCount; i++ ){
            if(idToMarketItem[i +  1].seller == msg.sender){
                uint currentId = idToMarketItem[i + 1].itemId;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }
}