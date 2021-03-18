## NFTulips: Fresh, Immortal Tulips on the Ethereum Blockchain

NFTulips are 10,000 unique collectible digital tulips that live on the Ethereum blockchain. The blockchain guarantees proof of ownership and trust-free buying/bidding/offering/selling. To learn more about a specific tulip, check out my website at (TBA). 

This repo contains the Ethereum contract used to manage the tulips and a verifiable image of all 10,000 tulips. 

The Ethereum contract is a minor modification of the [contract underlying CryptoPunks](https://github.com/larvalabs/cryptopunks/blob/master/contracts/CryptoPunksMarket.sol), which is under the MIT License. I updated the code from Solidity 0.4.8 to Solidity 0.7.4, which required a lot of syntax edits. I also added a "circuit breaker" to shut off the contract in case of an emergency, and I added hash data from my NFTulips project (more on that later; scroll down to "Verifying Your Tulips"). Finally, I implemented some modest gas optimizations (variable packing, minimizing data in memory) and changed variable names. 

That said, I made sure to not touch the contract's functionality. This spares me the pain of unit testing my own unproven code (whereas the CryptoPunks code is very, very proven...it's facilitating a $190 million market, for crying out loud!) and facilitates my artistic vision of the NFTulips project. 

### FAQ

* **How much do the tulips cost?** As of deployment, all tulips are "free". Anyone with an Ethereum wallet can claim them by paying Ethereum's transaction fee. I don't earn a single Wei from that process, by the way. 
* **Why should I buy a tulip?** Great question! They're "free" (see above), always fresh (digital flowers don't wilt or give off bad smells), and essentially immortal (as long as Ethereum remains active). Above all, they might (or might not) become the next big NFT. 
* **I'm not really buying a tulip, am I?** Yep, that's right. And that's not a jab at NFTs or digital art, by the structure of this smart contract, you are not actually buying a token of an image of a tulip (more on that later; scroll down to "Verifying Your Tulips"). 
* **How were the tulips created?** I wrote some clunky, unsightly Python code to generate the tulips. Although I won't be posting the code yet, I will include a hash of the file in the Ethereum contract for posterity (more on that later; scroll down to "Verifying Your Tulips"). 

### How to Use the NFTulips contract

You can interact with the smart contract on EtherScan (link TBA). 

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

### Verifying Your Tulips

![alt text](https://github.com/openamiguel/NFTulips/blob/45de962ff87524ef136c11de8aba9d2957897280/tulips_all.png)

This is the official and genuine image of all 10,000 NFTulips. I embedded a SHA256 hash of the image file into the contract, in order to commit the contract to this image. Use `openssl`, Python's `hashlib`, or a similar tool to check the hash: `b929f0a772b476441f055c878ba2080ecb10dfd2f103fef876372946660c58fb`. 

Likewise, I embedded a SHA256 hash of the Python code used to generate the NFTulips. It's not uploaded into this repo, but you should know this: the code uses an unseeded, secure pseudorandom number generator, so that running the code will produce a totally different set of tulips, each and every time. Here's the hash of the code, just in case I release it at a future date: `39dce9989126cb2d126e125a7c17de01200fcb7ea8e37705985d84cb4257487c`. 
