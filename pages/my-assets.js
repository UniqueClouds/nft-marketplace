/* pages/my-assets.js */
import { ethers } from 'ethers'
import { useEffect, useState } from 'react'
import axios from 'axios'
import Web3Modal from "web3modal"

import {
	nftauctionaddress, nftaddress
} from '../config'

import NFT from '../artifacts/contracts/NFT.sol/NFT.json'
import Market from '../artifacts/contracts/NFTMarket.sol/NFTMarket.json'
import Auction from '../artifacts/contracts/NFTAuction.sol/NFTAuction.json'

export default function MyAssets() {
	const [nfts, setNfts] = useState([])
	const [loadingState, setLoadingState] = useState('not-loaded')
	const [nfts1, setNfts1] = useState([])
	const [loadingState1, setLoadingState1] = useState('not-loaded')
	const [formInput, updateFormInput] = useState({ startPrice: 0, timeEnded: 0})
	useEffect(() => {
		loadNFTs()
		loadMintedNFTs()
	}, [])
	async function createAuction(nft) {
		console.log('createAuctionItem')
		const web3Modal = new Web3Modal()
		const connection = await web3Modal.connect()
		const provider = new ethers.providers.Web3Provider(connection)
		const signer = provider.getSigner()

		const auction = new ethers.Contract(nftauctionaddress, Auction.abi, signer)
		
		let price = parseInt(formInput.startPrice)
		let duration = parseInt(formInput.timeEnded)
		const itemToken = nft.tokenId

		console.log(itemToken,price,duration)
		if(!price || !duration)
			{
				window.alert("请输入价格或拍卖时长！")
				return
			}
		let transaction = await auction.createAuctionItem(itemToken,price,duration)
		await transaction.wait()
		loadNFTs()
	}
	async function endAuction(nft){
		console.log('createAuctionItem')
		const web3Modal = new Web3Modal()
		const connection = await web3Modal.connect()
		const provider = new ethers.providers.Web3Provider(connection)
		const signer = provider.getSigner()

		const auction = new ethers.Contract(nftauctionaddress, Auction.abi, signer)
		
		let price = parseInt(formInput.startPrice)
		let duration = parseInt(formInput.timeEnded)
		const itemToken = nft.tokenId

		let transaction = await auction.endAuction(itemToken)
		await transaction.wait()
		loadNFTs()
	}
	async function loadNFTs() {
		const web3Modal = new Web3Modal()
		const connection = await web3Modal.connect()
		const provider = new ethers.providers.Web3Provider(connection)
		const signer = provider.getSigner()

		const marketContract = new ethers.Contract(nftauctionaddress, Auction.abi, signer)
		const tokenContract = new ethers.Contract(nftaddress, NFT.abi, provider)
		const data = await marketContract.fetchMyNFTs()

		const items = await Promise.all(data.map(async i => {
			const tokenUri = await tokenContract.tokenURI(i.tokenId)
			const meta = await axios.get(tokenUri)
			let price = ethers.utils.formatUnits(i.price.toString(), 'ether')

			console.log(i)
			let item = {
				price,
				tokenId: i.tokenId.toNumber(),
				owner: i.owner,
				image: meta.data.image,
				name:meta.data.name,
				state:i.state
			}
			return item
		}))
		setNfts(items)
		setLoadingState('loaded')
	}

	async function loadMintedNFTs() {
		const web3Modal = new Web3Modal()
		const connection = await web3Modal.connect()
		const provider = new ethers.providers.Web3Provider(connection)
		const signer = provider.getSigner()

		const marketContract = new ethers.Contract(nftauctionaddress, Market.abi, signer)
		const tokenContract = new ethers.Contract(nftaddress, NFT.abi, provider)
		const data = await marketContract.fetchItemsCreated()

		const items = await Promise.all(data.map(async i => {
			const tokenUri = await tokenContract.tokenURI(i.tokenId)
			const meta = await axios.get(tokenUri)
			let price = ethers.utils.formatUnits(i.price.toString(), 'ether')
			let item = {
				price,
				tokenId: i.tokenId.toNumber(),
				owner: i.owner,
				image: meta.data.image,
				name:meta.data.name,
				state:i.state,
			}
			console.log(item)
			return item
		}))
		setNfts1(items)
		setLoadingState1('loaded')
	}

	if (loadingState === 'loaded' && !nfts.length && !nfts1.length) return (
		<h1 className="py-10 px-20 text-3xl">暂无拥有的NFT资产</h1>
	)
	return (
		<div>
		<div className="flex justify-center">
			<div className="p-4">
				<h2 className="py-10 px-20 text-2xl text-red-400">我的资产</h2>
				<div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 pt-4">
					{
						nfts.map((nft, i) => (
							<div key={i} className="border shadow rounded-xl overflow-hidden">
								<img src={nft.image} className="rounded" />
								<div className="p-4 bg-black">
									<p className="text-1xl font-bold text-white">{nft.name}</p>
								</div>
								{
									(nft.state === 0)
										?(
											<div>
												<p align='center' className="mb-4 font-bold text-black ">拍卖NFT</p>
												<b className="mb-4 font-bold text-black"
												>起拍价格:</b><input  className=" text-black rounded border-b" name="startPrice" placeholder="100"
												onChange={e => updateFormInput({ ...formInput, startPrice: e.target.value})}
												/>ETH<br/>
												<b>竞拍时间:</b><input  className=" text-black  rounded border-b" name="time" placeholder="60"
												onChange={e => updateFormInput({ ...formInput, timeEnded: e.target.value})}
												/>分钟<br/>										
												<button className="w-full bg-pink-500 text-white font-bold py-2 px-12 rounded"  onClick={() => createAuction(nft)}>确认拍卖</button>
											</div>
											)
											:(nft.state === 1)?
											(
											<div>
											<b>拍卖中</b>
												<button className="w-full bg-pink-500 text-white font-bold py-2 px-12 rounded"  onClick={() => endAuction(nft)}>结束竞拍</button>
											</div>
											):
											<div>
											<b>等待认领</b>
											</div>
										}
									
								
								
							</div>
						))
					}
				</div>
			</div>
		</div> 
		<div className="flex justify-center">
			<div className="p-4">
				<h2 className="py-10 px-20 text-2xl text-blue-400">我的锻造</h2>
				<div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 pt-4">
					{
						nfts1.map((nft, i) => (
							<div key={i} className="border shadow rounded-xl overflow-hidden">
								<img src={nft.image} className="rounded" />
								<div className="p-4 bg-black">
									<p className="text-1xl font-bold text-white">{nft.name}</p>
								</div>
							</div>
						))
					}
				</div>
			</div>
		</div>
		</div>
	)
}