const hre = require("hardhat");

async function main() {
  // const NFTMarket = await hre.ethers.getContractFactory("NFTMarket");
  // const nftMarket= await NFTMarket.deploy();

  // await nftMarket.deployed();

  // console.log("nftMarket deployed to:", nftMarket.address);

  const NFTAuction = await hre.ethers.getContractFactory("NFTAuction");
  const nftAuction = await NFTAuction.deploy();

  await nftAuction.deployed();
  console.log("nftAuction deployed to:",nftAuction.address)

  const NFT = await hre.ethers.getContractFactory("NFT");
  const nft = await NFT.deploy(nftAuction.address);
  await nft.deployed();

  console.log("nft deployed to:", nft.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
