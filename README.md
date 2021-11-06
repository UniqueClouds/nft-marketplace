https://github.com/UniqueClouds/nft-marketplace

## 如何运行

打开命令行，将地址切换到项目所在目录

运行以下指令:

1.`npx hardhat node`

会出现20个本地账号，可以复制 private key 内容到 metamask 里面生成账户

2.`npx hardhat run scripts/deploy.js --network localhost`

此时需要修改 config.js 目录下两个变量的内容，修改为为命令行中所给地址

```
export const nftaddress = ""
export const nftauctionaddress = ""
```

3.输入`npm run dev`

输入网址 http://localhost:3000/ 即可在本地打开项目


