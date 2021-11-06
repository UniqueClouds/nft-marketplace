//contracts/NFTAuction.sol
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./NFTMarket.sol";

contract NFTAuction is NFTMarket {
    uint _Items = 0;
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
        _Items +=1;
        uint itemId = _Items;
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
        uint tokenId, 
        uint256 newBid
    )public payable nonReentrant{
        require(!idToAuctionItem[tokenId].auctionEnded,"Auction alread ended!");
        require(idToAuctionItem[tokenId].highestBid < newBid,"No allowance for lower bid!");

        idToAuctionItem[tokenId].winner = payable(msg.sender);
        idToAuctionItem[tokenId].highestBid = newBid;

    }

    function endAuction(
        uint tokenId
    ) public payable nonReentrant{
        require(idToMarketItem[tokenId].owner == msg.sender,"Only owner can end an auction");

        require(!idToAuctionItem[tokenId].auctionEnded,"Already ended.");

        idToMarketItem[tokenId].state = status.waitToClaim;
        idToMarketItem[tokenId].price = idToAuctionItem[tokenId].highestBid;
        idToAuctionItem[tokenId].auctionEnded = true;
    }
    //transfer ownershiop and value
    function claim(
        address nftContract,
        uint tokenId,
        uint price
    )public payable nonReentrant{
        // require(idToAuctionItem[tokenId].auctionEnded,"Auction not ended yet!");
        // require(!idToAuctionItem[tokenId].winnerClaimed, "Auction already claimed!");
        // require(idToAuctionItem[tokenId].winner == msg.sender, "Only winner can claim!");
        
        //send money to the seller
        address owner = idToMarketItem[tokenId].owner;
        payable(owner).transfer(msg.value);
        //transfer the ownership to buyer
        IERC721(nftContract).transferFrom(address(this),msg.sender, tokenId);
        idToMarketItem[tokenId].owner = payable(msg.sender);
        idToMarketItem[tokenId].state = status.offBid;
        payable(owner).transfer(price);
    }


    function fetchAuctionItems() public view returns (AuctionItem[] memory) {
        uint256 totalItemCount = _itemIds;
        uint itemCount = 0;
        uint currentIndex = 0;
        AuctionItem[] memory items = new AuctionItem[] (totalItemCount);
        //insert the unsold nft items
        for(uint i = 0; i < totalItemCount; i++ ){
            if(!idToAuctionItem[i + 1].winnerClaimed){
                uint currentId = idToAuctionItem[i + 1].itemId;
                AuctionItem storage currentItem = idToAuctionItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }
    
}