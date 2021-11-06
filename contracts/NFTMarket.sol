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
    Counters.Counter private _itemSold;
    // using Counters for Counters.Counter;
    // Counters.Counter  _itemIds;
    // Counters.Counter private _itemsSold;
    enum status {
        offBid, onBid, waitToClaim
    }
    address payable owner;
    uint256 listingPrice = 0.025 ether;

    constructor(){
        owner = payable(msg.sender);
    }
       
    struct MarketItem {
        uint itemId;    //编号
        address nftContract;    //
        uint256 tokenId;    
        uint256 transferTime;   //交易次数
        address payable owner;
        address creator;
        status state;   //当前状态
        uint price;
    }
    mapping(uint256 => MarketItem) idToMarketItem;

    event MarketItemCreated(
        uint indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        uint256 transferTime,
        address owner,
        address creator,
        status state,
        uint price
    );
    // get listing price of the contract
    // function getListPrice() public view returns (uint256){
    //     return listingPrice;
    // }
    // place an item for sale on the marke
    function getItemCurrent() public view returns (uint256){
        return _itemIds.current();
    }
    function createMarketItem(
        address nftContract,
        uint256 tokenId
    ) public payable nonReentrant {

        _itemIds.increment();
        uint256 itemId = _itemIds.current();

        idToMarketItem[itemId] = MarketItem(
            itemId,
            nftContract,
            tokenId,
            0,
            payable(msg.sender),
            msg.sender,
            status.offBid,
            0
        );

        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);//transfer ownership 
        
        emit MarketItemCreated(
            itemId,
            nftContract,
            tokenId,
            0,
            msg.sender,
            msg.sender,
            status.offBid,
            0
        );
    } 

    // Create sale of a marketplace item
    // transfer ownership and funds 
    // function createMarketSale(
    //     address nftContract,
    //     uint256 itemId
    // )public payable nonReentrant{
    //     //using mapping
    //     uint price = idToMarketItem[itemId].price;
    //     uint tokenId = idToMarketItem[itemId].tokenId;
    //     require(msg.value == price, "Please submit the asking price in order to complete the purchase");
    //     //send money to the seller
    //     idToMarketItem[itemId].seller.transfer(msg.value);
    //     //transfer the ownership to buyer
    //     IERC721(nftContract).transferFrom(address(this),msg.sender, tokenId);
    //     idToMarketItem[itemId].owner = payable(msg.sender);
    //     idToMarketItem[itemId].sold = true;
    //     _itemsSold.increment();
    //     payable(owner).transfer(listingPrice);
    // }

    //view onbid items
    // function fetchMarketItems() public view returns (MarketItem[] memory) {
    //     uint totalItemCount = _itemIds.current();
    //     uint itemCount = 0;
    //     uint currentIndex = 0;

    //     for(uint i = 0; i< totalItemCount; i++ ){
    //         if(idToMarketItem[i +  1].state == status.onBid){
    //             itemCount += 1;
    //         }
    //     }
    //     MarketItem[] memory items = new MarketItem[] (unsoldItemCount);
    //     //insert the unsold nft items
    //     for(uint i = 0; i < itemCount; i++ ){
    //         if(idToMarketItem[i +  1].state == status.onBid){
    //             uint currentId = idToMarketItem[i + 1].itemId;
    //             MarketItem storage currentItem = idToMarketItem[currentId];
    //             items[currentIndex] = currentItem;
    //             currentIndex += 1;
    //         }
    //     }

    //     return items;
    // }
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
            if(idToMarketItem[i +  1].creator == msg.sender){
                itemCount += 1;
            }
        }
        MarketItem[] memory items = new MarketItem[] (itemCount);

        for(uint i = 0; i< itemCount; i++ ){
            if(idToMarketItem[i +  1].creator == msg.sender){
                uint currentId = idToMarketItem[i + 1].itemId;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }
}