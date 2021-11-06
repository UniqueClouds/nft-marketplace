//contracts/NFTAuction.sol
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./NFTMarket.sol";

contract NFTAuction is NFTMarket {
    using Counters for Counters.Counter;
    Counters.Counter public _itemIds2;
    struct AuctionItem {
        uint itemId;
        uint tokenId;
        uint startBid;  //起拍价
        uint highestBid;    //最高竞拍价
        address payable winner; //竞拍得主
        uint256 endTime;
        bool auctionEnded;  //判断竞拍是否结束
        bool winnerClaimed;
    }
    event AuctionItemCreated(
        uint indexed itemId,
        uint indexed tokenId,
        uint startBid,
        uint highestBid,
        address winner,
        uint256 endTime,
        bool auctionEnded,
        bool winnerClaimed
    );
    // let startBid = ethers.utils.formatUnits(i.startBid.toNumber(),"ether")
    // let highestBid = ethers.utils.formatUnits(i.highestBid.toNumber(),"ether")
    mapping(uint256 => AuctionItem) private idToAuctionItem;
    function createAuctionItem(
        uint tokenId,
        uint startPrice,
        uint duration
    )public payable nonReentrant {
        // require(msg.sender == idToMarketItem[tokenId].owner,"Only Owner can start an auction");
        require(idToMarketItem[tokenId].state == status.offBid,"Already on auction!");
        require(startPrice > 0,"startBid should >0!");
        require(duration >0,"duration should >0!");
        idToMarketItem[tokenId].state = status.onBid;
        idToMarketItem[tokenId].price = startPrice;

        uint256 endTime = block.timestamp + duration;
        _itemIds2.increment();
        uint itemId = _itemIds2.current();
        idToAuctionItem[itemId] =AuctionItem(
            itemId,
            tokenId,
            startPrice,
            startPrice,
            payable(msg.sender),
            endTime,
            false,
            false
        );
    }

    //竞拍
    function bid(
        uint itemId, 
        uint256 newBid
    )public payable nonReentrant{
        require(!idToAuctionItem[itemId].auctionEnded,"Auction alread ended!");
        require(idToAuctionItem[itemId].highestBid < newBid,"No allowance for lower bid!");

        idToAuctionItem[itemId].winner = payable(msg.sender);
        idToAuctionItem[itemId].highestBid = newBid;

    }

    function endAuction(
        uint itemId
    ) public payable nonReentrant{
        require(idToMarketItem[itemId].owner == msg.sender,"Only owner can end an auction");

        require(!idToAuctionItem[itemId].auctionEnded,"Already ended.");

        idToMarketItem[itemId].state = status.waitToClaim;
        idToMarketItem[itemId].price = idToAuctionItem[itemId].highestBid;
        idToAuctionItem[itemId].auctionEnded = true;
        idToAuctionItem[itemId].winnerClaimed = false;
    }
    //transfer ownershiop and value
    function claim(
        address nftContract,
        uint itemId
    )public payable nonReentrant{
        require(idToAuctionItem[itemId].auctionEnded,"Auction not ended yet!");
        require(!idToAuctionItem[itemId].winnerClaimed, "Auction already claimed!");
        require(idToAuctionItem[itemId].winner == msg.sender, "Only winner can claim!");
        uint tokenId = idToMarketItem[itemId].tokenId;
        //send money to the seller
        address owner = idToMarketItem[itemId].owner;
        payable(owner).transfer(msg.value);
        //transfer the ownership to buyer
        IERC721(nftContract).transferFrom(address(this),msg.sender, tokenId);
        idToMarketItem[itemId].owner = payable(msg.sender);
        idToMarketItem[itemId].state = status.offBid;
        idToAuctionItem[itemId].winnerClaimed = true;
        idToAuctionItem[itemId].auctionEnded = true;
        idToMarketItem[itemId].transferTime ++;
    }


    function fetchAuctionItems() public view returns (AuctionItem[] memory) {
        uint256 totalItemCount = getItemCurrent();
        uint currentIndex = 0;
        uint itemCount = 0;
        for(uint i = 0; i< totalItemCount; i++ ){
            if(idToMarketItem[i +  1].state == status.onBid || idToMarketItem[i + 1].state == status.waitToClaim){
                itemCount += 1;
            }
        }

        AuctionItem[] memory items = new AuctionItem[] (itemCount);
        //insert the unsold nft items
        for(uint i = 0; i < itemCount; i++ ){
            if(!idToAuctionItem[i+1].winnerClaimed){
                uint currentId = idToAuctionItem[i+1].itemId;
                AuctionItem storage currentItem = idToAuctionItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }
    
}