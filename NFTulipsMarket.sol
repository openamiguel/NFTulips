// Based on the smart contract for CryptoPunks: 
// https://github.com/larvalabs/cryptopunks/blob/master/contracts/CryptoPunksMarket.sol
// Given that the CryptoPunks smart contract has performed well so far, 
// I attempted to make as few changes as possible. 

// Security upgrades include:
// Locked pragma to Solidity 0.7.4 (and added all necessary syntax upgrades)
// Added circuit breaker (owner only privilege)
// Changed all if-then-throw statements to require statements

// Efficiency upgrades include: 
// Variable packing (within reason)
// Reduced some variables to smaller size (e.g., uint --> uint16, string --> bytes8)

// Other changes include:
// Changed variable names to represent tulips

// @author Miguel Opeña

pragma solidity 0.7.4;

contract NFTulipsMarket {

    // Use this hash to verify the image file containing all the tulips
    string public imageHash = "b929f0a772b476441f055c878ba2080ecb10dfd2f103fef876372946660c58fb";

    // Use this hash to verify the generative algorithm to create previous image
    string public codeHash  = "39dce9989126cb2d126e125a7c17de01200fcb7ea8e37705985d84cb4257487c"; 

    address admin;
    
    bool private stopped = false; 
    bytes8 public standard = "NFTulips";
    bytes8 public name; 
    uint16 public totalSupply;
    bool public allTulipsAssigned = false;
    uint16 public tulipsRemainingToAssign = 0;

    //mapping (address => uint) public addressToTulipIndex;
    mapping (uint16 => address) public tulipIndexToAddress;

    /* This creates an array with all balances */
    mapping (address => uint) public balanceOf;

    struct Offer {
        bool isForSale;
        uint16 tulipIndex;
        address seller;
        uint minValue;          // in ether
        address onlySellTo;     // specify to sell only to a specific person
    }

    struct Bid {
        bool hasBid;
        uint16 tulipIndex;
        address bidder;
        uint value;
    }

    // A record of tulips that are offered for sale at a specific minimum value, and perhaps to a specific person
    mapping (uint16 => Offer) public tulipsOfferedForSale;

    // A record of the highest tulip bid
    mapping (uint16 => Bid) public tulipBids;

    mapping (address => uint) public pendingWithdrawals;

    event Assign(address indexed to, uint16 tulipIndex);
    event Transfer(address indexed from, address indexed to, uint value);
    event TulipTransfer(address indexed from, address indexed to, uint16 tulipIndex);
    event TulipOffered(uint16 indexed tulipIndex, uint minValue, address indexed toAddress);
    event TulipBidEntered(uint16 indexed tulipIndex, uint value, address indexed fromAddress);
    event TulipBidWithdrawn(uint16 indexed tulipIndex, uint value, address indexed fromAddress);
    event TulipBought(uint16 indexed tulipIndex, uint value, address indexed fromAddress, address indexed toAddress);
    event TulipNoLongerForSale(uint16 indexed tulipIndex);

    // Admin-only privileges
    modifier isAdmin() {
        require(msg.sender == admin, "Admin only!"); 
        _; 
    }

    // Circuit breaker modifier
    modifier stopInEmergency { 
        require(!stopped, "Emergency circuit breaker activated; contact admin!");
        _; 
    }

    // Initialize contract; assign all tulips to admin; offer for sale at 0.05 ETH apiece
    constructor() {
        admin = msg.sender;
        totalSupply = 10000; 
        tulipsRemainingToAssign = totalSupply;
        name = "NFTULIPS"; 
    }

    // Circuit breaker activation
    function toggleContractActive() isAdmin public {
        stopped = !stopped; 
    }

    // Set initial owner (to) of given tulip (tulipIndex)
    function setInitialOwner(address to, uint16 tulipIndex) isAdmin public {
        require(!allTulipsAssigned, "All tulips already assigned");
        require(tulipIndex < totalSupply, "Invalid tulip index"); 
        if (tulipIndexToAddress[tulipIndex] != to) {
            if (tulipIndexToAddress[tulipIndex] != address(0)) {
                balanceOf[tulipIndexToAddress[tulipIndex]]--;
            } else {
                tulipsRemainingToAssign--;
            }
            tulipIndexToAddress[tulipIndex] = to;
            balanceOf[to]++;
            emit Assign(to, tulipIndex);
        }
    }

    // Set initial owner (addresses[i]) of each tulip (indices[i])
    function setInitialOwners(address[] calldata addresses, uint16[] calldata indices) isAdmin public {
        uint n = addresses.length;
        for (uint16 i = 0; i < n; i++) {
            setInitialOwner(addresses[i], indices[i]);
        }
    }

    // Manually toggle when all initial owners assigned
    function allInitialOwnersAssigned() isAdmin public {
        allTulipsAssigned = true;
    }

    // Buyer (msg.sender) claims tulip (tulipIndex) for themselves, at zero cost
    function getTulip(uint16 tulipIndex) stopInEmergency public {
        require(allTulipsAssigned, "All tulips must be assigned");
        require(tulipsRemainingToAssign > 0, "No remaining tulips to assign"); 
        require(tulipIndexToAddress[tulipIndex] == address(0), "Tulip must be unclaimed");
        require(tulipIndex < totalSupply, "Invalid tulip index");
        tulipIndexToAddress[tulipIndex] = msg.sender;
        balanceOf[msg.sender]++;
        tulipsRemainingToAssign--;
        emit Assign(msg.sender, tulipIndex);
    }

    // Tulip owner (msg.sender) transfers tulip (tulipIndex) to an address (to) for free
    function transferTulip(address to, uint16 tulipIndex) stopInEmergency public {
        require(allTulipsAssigned, "All tulips must be assigned");
        require(tulipIndexToAddress[tulipIndex] == msg.sender, "Tulip owner only"); 
        require(tulipIndex < totalSupply, "Invalid tulip index"); 
        if (tulipsOfferedForSale[tulipIndex].isForSale) {
            tulipNoLongerForSale(tulipIndex);
        }
        tulipIndexToAddress[tulipIndex] = to;
        balanceOf[msg.sender]--;
        balanceOf[to]++;
        emit Transfer(msg.sender, to, 1);
        emit TulipTransfer(msg.sender, to, tulipIndex);
        // Check for the case where there is a bid from the new owner and refund it.
        // Any other bid can stay in place.
        Bid memory bid = tulipBids[tulipIndex];
        if (bid.bidder == to) {
            // Kill bid and refund value
            pendingWithdrawals[to] += bid.value;
            tulipBids[tulipIndex] = Bid(false, tulipIndex, address(0), 0);
        }
    }

    // Tulip owner (msg.sender) marks tulip (tulipIndex) as not-for-sale
    function tulipNoLongerForSale(uint16 tulipIndex) stopInEmergency public {
        require(allTulipsAssigned, "All tulips must be assigned");
        require(tulipIndexToAddress[tulipIndex] == msg.sender, "Tulip owner only"); 
        require(tulipIndex < totalSupply, "Invalid tulip index"); 
        tulipsOfferedForSale[tulipIndex] = Offer(false, tulipIndex, msg.sender, 0, address(0));
        emit TulipNoLongerForSale(tulipIndex);
    }

    // Tulip owner (msg.sender) marks tulip (tulipIndex) as for sale, at a minimum price (minSalePriceInWei)
    function offerTulipForSale(uint16 tulipIndex, uint minSalePriceInWei) stopInEmergency public {
        require(allTulipsAssigned, "All tulips must be assigned");
        require(tulipIndexToAddress[tulipIndex] == msg.sender, "Tulip owner only"); 
        require(tulipIndex < totalSupply, "Invalid tulip index"); 
        tulipsOfferedForSale[tulipIndex] = Offer(true, tulipIndex, msg.sender, minSalePriceInWei, address(0));
        emit TulipOffered(tulipIndex, minSalePriceInWei, address(0));
    }

    // Tulip owner (msg.sender) marks tulip (tulipIndex) as for sale, at a minimum price (minSalePriceInWei), to a specific address (toAddress)
    function offerTulipForSaleToAddress(uint16 tulipIndex, uint minSalePriceInWei, address toAddress) stopInEmergency public {
        require(allTulipsAssigned, "All tulips must be assigned");
        require(tulipIndexToAddress[tulipIndex] == msg.sender, "Tulip owner only"); 
        require(tulipIndex < totalSupply, "Invalid tulip index"); 
        tulipsOfferedForSale[tulipIndex] = Offer(true, tulipIndex, msg.sender, minSalePriceInWei, toAddress);
        emit TulipOffered(tulipIndex, minSalePriceInWei, toAddress);
    }

    // Buyer (msg.sender) buys tulip (tulipIndex) for themselves
    function buyTulip(uint16 tulipIndex) stopInEmergency payable public {
        require(allTulipsAssigned, "All tulips must be assigned");
        require(tulipIndex < totalSupply, "Invalid tulip index"); 
        Offer memory offer = tulipsOfferedForSale[tulipIndex];
        require(offer.isForSale, "Tulip must be for sale"); 
        require(offer.onlySellTo == address(0) || offer.onlySellTo == msg.sender, "Invalid offer.onlySellTo address"); 
        require(msg.value >= offer.minValue, "Insufficient ETH attached"); 
        require(offer.seller == tulipIndexToAddress[tulipIndex], "Seller no longer owner"); 

        address seller = offer.seller;

        tulipIndexToAddress[tulipIndex] = msg.sender;
        balanceOf[seller]--;
        balanceOf[msg.sender]++;
        emit Transfer(seller, msg.sender, 1);

        tulipNoLongerForSale(tulipIndex);
        pendingWithdrawals[seller] += msg.value;
        emit TulipBought(tulipIndex, msg.value, seller, msg.sender);

        // Check for the case where there is a bid from the new owner and refund it.
        // Any other bid can stay in place.
        Bid memory bid = tulipBids[tulipIndex];
        if (bid.bidder == msg.sender) {
            // Kill bid and refund value
            pendingWithdrawals[msg.sender] += bid.value;
            tulipBids[tulipIndex] = Bid(false, tulipIndex, address(0), 0);
        }
    }

    // Seller withdraws the funds under their address
    function withdraw() stopInEmergency public {
        require(allTulipsAssigned, "All tulips must be assigned");
        uint amount = pendingWithdrawals[msg.sender];

        // Remember to zero the pending refund before sending to prevent re-entrancy attacks
        pendingWithdrawals[msg.sender] = 0;

        // Refund the purchase money
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
    }

    // Bidder (msg.sender) enters bid for tulip (tulipIndex)
    function enterBidForTulip(uint16 tulipIndex) stopInEmergency payable public {
        require(allTulipsAssigned, "All tulips must be assigned");
        require(tulipIndex < totalSupply, "Invalid tulip index"); 
        require(tulipIndexToAddress[tulipIndex] != address(0), "Zero address cannot bid");                
        require(tulipIndexToAddress[tulipIndex] != msg.sender, "Owner cannot bid on own tulip"); 
        require(msg.value != 0, "msg.value cannot be zero"); 
        Bid memory existing = tulipBids[tulipIndex];
        require(msg.value > existing.value, "msg.value is too low"); 
        if (existing.value > 0) {
            // Refund the failing bid
            pendingWithdrawals[existing.bidder] += existing.value;
        }
        tulipBids[tulipIndex] = Bid(true, tulipIndex, msg.sender, msg.value);
        emit TulipBidEntered(tulipIndex, msg.value, msg.sender);
    }

    // Tulip owner (msg.sender) accepts bid (minPrice) for tulip (tulipIndex)
    function acceptBidForTulip(uint16 tulipIndex, uint minPrice) stopInEmergency public {
        require(allTulipsAssigned, "All tulips must be assigned");
        require(tulipIndex < totalSupply, "Invalid tulip index");      
        require(tulipIndexToAddress[tulipIndex] == msg.sender, "Tulip owner only"); 
        address seller = msg.sender;
        Bid memory bid = tulipBids[tulipIndex];
        require(bid.value > 0, "Bid value cannot be zero"); 
        require(bid.value >= minPrice, "Bid value is too low"); 

        tulipIndexToAddress[tulipIndex] = bid.bidder;
        balanceOf[seller]--;
        balanceOf[bid.bidder]++;
        emit Transfer(seller, bid.bidder, 1);

        tulipsOfferedForSale[tulipIndex] = Offer(false, tulipIndex, bid.bidder, 0, address(0));
        uint amount = bid.value;
        tulipBids[tulipIndex] = Bid(false, tulipIndex, address(0), 0);
        pendingWithdrawals[seller] += amount;
        emit TulipBought(tulipIndex, bid.value, seller, bid.bidder);
    }

    // Withdraw funds associated with tulip bid
    function withdrawBidForTulip(uint16 tulipIndex) stopInEmergency public {
        require(allTulipsAssigned, "All tulips must be assigned");
        require(tulipIndex < totalSupply, "Invalid tulip index");  
        require(tulipIndexToAddress[tulipIndex] != address(0), "Zero address cannot bid");                
        require(tulipIndexToAddress[tulipIndex] != msg.sender, "Owner cannot bid on own tulip"); 
        Bid memory bid = tulipBids[tulipIndex];
        require(bid.bidder == msg.sender, "Only bidder can withdraw their bid"); 
        emit TulipBidWithdrawn(tulipIndex, bid.value, msg.sender);

        uint amount = bid.value;
        tulipBids[tulipIndex] = Bid(false, tulipIndex, address(0), 0);
        
        // Refund the bid money
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
    }

}