## NFTulips: Fresh, Immortal Tulips on the Ethereum Blockchain

NFTulips are 10,000 unique collectible digital tulips that live on the Ethereum blockchain. The blockchain guarantees proof of ownership and trust-free buying/bidding/offering/selling. To learn more about a specific tulip, check out my website at _____________

This repo contains the Ethereum contract used to manage the tulips and a verifiable image of all 10,000 tulips. 

The Ethereum contract is a minor modification of the contract underlying CryptoPunks, which is under the MIT License. I updated the code from Solidity 0.4.8 to Solidity 0.7.4, which required a lot of syntax edits. I also added a "circuit breaker" to shut off the contract in case of an emergency, and I added hash data from my NFTulips project (more on that later; scroll down to "Verifying Your Tulips"). That said, I made sure to not touch the contract's functionality. This spares me the pain of unit testing my own unproven code (whereas the CryptoPunks code is very, very proven...it's facilitating a $190 million market, for crying out loud!) and facilitates my artistic vision of the NFTulips project. 

### FAQ

* **How much do the tulips cost?** As of deployment, all tulips are "free". Anyone with an Ethereum wallet can claim them by paying Ethereum's transaction fee. I don't earn a single Wei from that process, by the way. 
* **Why should I buy a tulip?** Great question! They're "free" (see above), always fresh (digital flowers don't wilt or give off bad smells), and essentially immortal (as long as Ethereum remains active). Above all, they might (or might not) become the next big NFT. 
* **I'm not really buying a tulip, am I?** Yep, that's right. And that's not a jab at NFTs or digital art, by the structure of this smart contract, you are not actually buying a token of an image of a tulip (more on that later; scroll down to "Verifying Your Tulips"). 
* **How were the tulips created?** I wrote some clunky, unsightly Python code to generate the tulips. Although I won't be posting the code yet, I will include a hash of the file in the Ethereum contract for posterity (more on that later; scroll down to "Verifying Your Tulips"). 

### How to Use the NFTulips contract

TBD...but enjoy this list of contract functions!

* 
