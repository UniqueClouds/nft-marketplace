import '../styles/globals.css'
import Link from 'next/link'
// import layout from '../components/Layout'

function MyApp({ Component, pageProps }) {
	return (
		<div>
			<nav className="border-b p-6 ">
				<p className="text-3xl font-bold text-grey-300 ">NFT Marketplace</p>
				<div className="flex mt-6 ">
					<Link href="/">
						<a className="mr-6 text-red-500 ">
							主页
						</a>
					</Link>
					<Link href="/create-item">
						<a className="mr-6 text-red-500">
							铸造NFT
						</a>
					</Link>
					<Link href="/my-assets">
						<a className="mr-6 text-red-500">
							我拥有的NFT
						</a>
					</Link>
					<Link href="/creator-dashboard">
						<a className="mr-6 text-red-500">
							Creator Dashboard
						</a>
					</Link>
				</div>
			</nav>
			<Component {...pageProps} />
		</div>
	)
}

export default MyApp