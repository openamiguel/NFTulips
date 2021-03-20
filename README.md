## NFTulips: Fresh, Immortal Tulips on the Ethereum Blockchain

NFTulips are 10,000 unique collectible digital tulips that live on the Ethereum blockchain. The blockchain guarantees proof of ownership and trust-free buying/bidding/offering/selling. To learn more about the artistic vision of NFTulips, check out my new blog, [Skeptical Futurist](https://skeptical-futurist.wixsite.com/blog/post/announcing-nftulips). 

This repo contains the Ethereum contract used to manage the tulips and a verifiable image of all 10,000 tulips. The Ethereum contract is a minor modification of the [contract underlying CryptoPunks](https://github.com/larvalabs/cryptopunks/blob/master/contracts/CryptoPunksMarket.sol), published under the MIT License. I updated the code from Solidity 0.4.8 to Solidity 0.7.4, which required a lot of syntax edits. I also added a "circuit breaker" to shut off the contract in case of an emergency, and I added hash data from my NFTulips project (more on that later; scroll down to "Verifying Your Tulips"). Finally, I implemented some modest gas optimizations (variable packing, reducing variable sizes, minimizing data in memory) and changed variable names. 

That said, I made sure to not touch the contract's functionality. This spares me the pain of unit testing my own unproven code (whereas the CryptoPunks code is very, very proven...it's facilitating a $190 million market, for crying out loud!) and facilitates my artistic vision of the NFTulips project. 

### How to Use the NFTulips contract

~~You can interact with the smart contract on EtherScan (link TBA).~~ Just kidding, you can't. However, don't blame me, blame the system. Specifically, blame the fact that the transaction fees for deployment, roughly 0.84 ETH. If I strip away all of the contract's bidding functionality and most of the admin-only functions, the fees reduce to roughly 0.33 ETH. I'm a college student; I can't afford to spend that much money on _one project_!!!

There are multiple workarounds. One option is to go through OpenSea or another NFT marketplace, but I doubt that listing 10,000 NFTs will spare me any monetary pains. Another option is to give myself royalties for each transaction, but that strays from the original design of CryptoPunks and therefore ruins my punchline. Yet another option, which I did take, is to upload the SHA-256 hash of the `NFTulipsMarket.sol` file onto the Ethereum blockchain as a commitment for its future uploading. The hash itself is `50393f99ed6ecd2db8320e761fbc8e63567065404c3ebdfed4e8335fdbf68f7d`; the transaction can be found [here on Etherscan](https://etherscan.io/tx/0x075373ae51409c08e389ac4eb0577f058fd3e14b34fb63e98a210ca05b952597). 

(Note: I built a simple circuit breaker into this smart contract. If I, the admin, unilaterally decide to do so, all functions except `withdraw` and `withdrawBidForTulip` will be shut off.)

* `getTulip(uint16 tulipIndex)` to claim a specified tulip for free (yep, for free...plus transaction fees)
* `transferTulip(address to, uint16 tulipIndex)` to transfer ownership of a specified tulip
* `tulipNoLongerForSale(uint16 tulipIndex)` to mark your specified tulip as "not for sale"
* `offerTulipForSale(uint16 tulipIndex, uint minSalePriceInWei)` to offer your specified tulip for sale to anyone with a minimum amount of ether
* `offerTulipForSaleToAddress(uint16 tulipIndex, uint minSalePriceInWei, address toAddress)` to offer your specified tulip for sale to a single address with a minimum amount of ether
* `buyTulip(uint16 tulipIndex)` to buy a specified tulip (can pay as much as you want!)
* `withdraw` to withdraw the ether under your balance (includes ether that buyers send you in exchange for a tulip; includes ether that you made a losing bid with)
* `enterBidForTulip(uint16 tulipIndex)` to enter a bid for a specified tulip; ether value held in escrow
* `acceptBidForTulip(uint16 tulipIndex, uint minPrice)` to accept a bid for a specified tulip
* `withdrawBidForTulip(uint16 tulipIndex)` to withdraw a bid you previously placed; only works if your bid is currently the highest

### FAQ

* **How much do the tulips cost?** As of deployment, all tulips are "free". Anyone with an Ethereum wallet can claim them by paying Ethereum's transaction fees (which seem to keep rising...\*sigh\*). Over time, if tulip owners start offering tulips for sale, they cost whatever the owner charges. 
* **Why should I buy a tulip?** Great question! They're "free" (see above), always fresh (digital flowers don't wilt or give off bad smells), and essentially immortal (as long as Ethereum remains active). Above all, they might (or might not) become the next big NFT. But that's true of all NFTs, right? 
* **I'm not really buying a tulip, am I?** Yep, that's right. And that's not a jab at NFTs or digital art, by the structure of this smart contract, you are not actually buying a token of an image of a tulip. You're actually buying a token of a hash of the composite image of all tulips (more on that later; scroll down to "Verifying Your Tulips"). 
* **How were the tulips created?** I wrote some clunky, unsightly Python code to generate the tulips. Although I won't be posting the code yet, I will include a hash of the file in the Ethereum contract for posterity (more on that later; scroll down to "Verifying Your Tulips"). 
* **Why didn't you publish the code yet?** The Ethereum transaction fees for publishing `NFTulipsMarket.sol` are too high. I resorted to executing a transaction with the SHA-256 hash of `NFTulipsMarket.sol` in the data field. 
* **Will you ever publish the code?** That is the plan. I might have to wait for ETH2, which should diminish transaction costs considerably. I might also wait for ETH to drop in USD valuation, or for approximately 0.85 ETH to magically appear in my wallet. If I do publish the code, it will be from the same wallet address that sent a transaction with the SHA-256 hash of `NFTulipsMarket.sol` in the data field (i.e., my wallet address). 
* **Is this a scam?** The only way for me to run a scam is if people give me Ether to fund the transaction fee for publishing `NFTulipsMarket.sol`, but I choose to keep the funds instead. Why would I do that? I already wrote the code (check out the repo) and spent hours going through syntax updates and minor security upgrades; if I didn't fully intend to publish my code on the mainnet, I wouldn't have bothered! 

### Verifying Your Tulips

![alt text](https://github.com/openamiguel/NFTulips/blob/45de962ff87524ef136c11de8aba9d2957897280/tulips_all.png)

This is the official and genuine image of all 10,000 NFTulips. I embedded a SHA256 hash of the image file into the contract, in order to commit the contract to this image. Use `openssl`, Python's `hashlib`, or a similar tool to check the hash: `b929f0a772b476441f055c878ba2080ecb10dfd2f103fef876372946660c58fb`. 

Likewise, I embedded a SHA256 hash of the Python code used to generate the NFTulips. It's not uploaded into this repo, but you should know this: the code uses an unseeded, secure pseudorandom number generator, so that running the code will produce a totally different set of tulips, each and every time. Here's the hash of the code, just in case I release it at a future date: `39dce9989126cb2d126e125a7c17de01200fcb7ea8e37705985d84cb4257487c`. 
