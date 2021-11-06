/* pages/index.js */

import { ethers } from 'ethers'
import { useEffect, useState } from 'react'
import axios from 'axios'
import Web3Modal from 'web3modal'
import { useRouter } from 'next/router'
import {
	nftaddress, nftauctionaddress
} from '../config'

import NFT from '../artifacts/contracts/NFT.sol/NFT.json'
import Market from '../artifacts/contracts/NFTMarket.sol/NFTMarket.json'
import Auction from '../artifacts/contracts/NFTAuction.sol/NFTAuction.json'

export default function Home() {
	const [nfts, setNfts] = useState([])
	const [loadingState, setLoadingState] = useState('not-loaded')
	const [formInput, updateFormInput] = useState ({ newPrice: ''})
	useEffect(() => {
		loadNFTs()
	}, [])
	async function loadNFTs() {
		console.log('loadNFTs')
		const web3Modal = new Web3Modal()
		const connection = await web3Modal.connect()
		/* create a generic provider and query for unsold market items */
		const provider = new ethers.providers.Web3Provider(connection)
		const tokenContract = new ethers.Contract(nftaddress, NFT.abi, provider)
		const auctionContract = new ethers.Contract(nftauctionaddress, Auction.abi, provider)
		console.log(auctionContract)
		const data = await auctionContract.fetchAuctionItems()
		console.log(data)
		/**
		 *  map over items returned from smart contract and format
		 *  as well as fetch their token metadata
		 */
		const items = await Promise.all(data.map(async i => {
			const tokenUri = await tokenContract.tokenURI(i.tokenId)
			const meta = await axios.get(tokenUri)
			let startBid = i.startBid
			startBid = startBid.toNumber()
			let highestBid = i.highestBid
			highestBid = highestBid.toNumber()
			let item = {
				startBid,
				highestBid,
				tokenId: i.tokenId,
				image: meta.data.image,
				name: meta.data.name,
				description: meta.data.description,
				auctionEnded:i.auctionEnded
			}
				console.log(item)
				return item
			}))
			setNfts(items)
			setLoadingState('loaded') 
	}

	async function bidforNFT(nft) {
		/** use Web3Provider to sign the transaction  */
		console.log('竞拍')
		const web3Modal = new Web3Modal()
		const connection = await web3Modal.connect()
		const provider = new ethers.providers.Web3Provider(connection)
		const signer = provider.getSigner()
		const contract = new ethers.Contract(nftauctionaddress, Auction.abi, signer)
		const price = formInput.newPrice
		const transaction = await contract.bid(nft.tokenId, price)
		await transaction.wait()
		loadNFTs() // show 1 less nfts
	}

	async function claimNFT(nft){
		console.log('手动认领')
		const web3Modal = new Web3Modal()
    	const connection = await web3Modal.connect()
    	const provider = new ethers.providers.Web3Provider(connection)
    	const signer = provider.getSigner()
    	const contract = new ethers.Contract(nftauctionaddress, Auction.abi, signer)
		const transaction = await contract.claim(nftaddress,nft.tokenId,nft.highestBid)
		await transaction.wait()
		loadNFTs()
	}
	

	if (loadingState === 'loaded' && !nfts.length) return (
		<h1 className="px-20 py-10 text-3xl">暂无NFT上架</h1>
	)
	return (
		<div className='flex justify-center'>
			<div className='px-4' style={{ maxWidth: '1600px' }}>
				<div className='grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 pt-4'>
					{
						nfts.map((nft, i) => (
							<div key={i} className="border shadow rounded-xl overflow-hidden">
								<img src={nft.image} />
								<div className='p-4'>
									<p style={{ height: '50px' }} className='text-2xl font-semibold'>{nft.name}</p>
									<div style={{ height: '60x', overflow: 'hidden' }}>
										<p className='text-gray-400'>{nft.description}</p>
									</div>
								</div>
								
								{	
									(nft.auctionEnded === true )
									?(
											<div>
											<button className="w-full bg-red-400 text-white font-bold py-2 px-12 rounded" onClick={() => claimNFT(nft)}>此物品已竞拍结束，等待认领</button>
											</div>

										)
										:(<div className="p-4 bg-blue-400">
										<p className="text-2xl mb-4 font-bold text-white">当前竞价:{nft.highestBid} ETH</p>
										<input 
										placeholder="出价" 
										className=" border rounded w-full p-2 " 
										onChange={e => updateFormInput({...formInput, newPrice: e.target.value})}/>
										<button className="w-full bg-red-400 text-white font-bold py-2 px-12 rounded" onClick={() => bidforNFT(nft)}>竞拍</button>
									</div>)
								}
							</div>
						))
					}
				</div>
			</div>
		</div>
	)
}