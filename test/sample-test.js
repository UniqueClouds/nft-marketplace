import { ethers } from "ethers"

/* test/sample-test.js */
describe("NFTMarket", function() {
  it("Should create and execute market sales", async function() {
    /* deploy the marketplace */
    const Market = await ethers.getContractFactory("NFTMarket")
    const market = await Market.deploy()
    await market.deployed()
    const marketAddress = market.address

    /*deploy the auction */
    const Auction = await ethers.getContractFactory("NFTAuction")
    const auction = await Auction.deploy()
    await auction.deployed()
    const auctionAddress = auction.address
    /* deploy the NFT contract */
    const NFT = await ethers.getContractFactory("NFT")
    const nft = await NFT.deploy(marketAddress)
    await nft.deployed()
    const nftContractAddress = nft.address

    let listingPrice = await market.getListPrice()
    listingPrice = listingPrice.toString()

    const auctionPrice = ethers.utils.parseUnits('1', 'ether')

    /* create two tokens */
    await nft.createToken("https://www.mytokenlocation.com")
    await nft.createToken("https://www.mytokenlocation2.com")

    /* put both tokens for sale */
    await market.createMarketItem(nftContractAddress, 1)
    await market.createMarketItem(nftContractAddress, 2)
    
    const [_, buyerAddress] = await ethers.getSigners()

    /* execute sale of token to another user */
    await market.connect(buyerAddress).createMarketSale(nftContractAddress, 1, { value: auctionPrice})


    /* put both tokes for auction */
    await auction.createAuctionItem(1,1,100)
    await auction.createAuctionItem(2,1,100)


    /* query for and return the unsold items */
    items = await market.fetchMarketItems()
    items = await Promise.all(items.map(async i => {
      const tokenUri = await nft.tokenURI(i.tokenId)
      let item = {
        price: i.price.toString(),
        tokenId: i.tokenId.toString(),
        seller: i.seller,
        owner: i.owner,
        tokenUri
      }
      return item
    }))
    console.log('items: ', items)
  })
})