pragma solidity ^0.4.17;

/// @title A 'penny social' auction implemented in solidity 
/// @author C. Mariscal
/// @notice Maximum of 4 bidders, 3 items to auction.
/// @dev Pending implementing no limits for bidders and items to auction.
/// @custom:experimental This is an experimental contract.

contract Auction {

    /// @notice Item to bid
    struct Item {
        uint itemId; // id of the item
        uint[] itemTokens;  // tokens bid in favor of the item
       
    }
    
   /// @notice Any bidder is a Person with defined struct parameters
    struct Person {
        uint remainingTokens; // tokens remaining with bidder
        uint personId; // it serves as tokenId as well
        address addr; // address of the bidder
    }
 
    mapping(address => Person) tokenDetails; // address to person 
    Person [4] bidders; // Array containing 4 person objects
    Item [3] public items; // Array containing 3 item objects
    address[3] public winners;// Array for address of winners
    address public beneficiary; // owner of the smart contract
    
    uint bidderCount=0; // counter


    modifier onlyOwner {
        require(msg.sender==beneficiary);
        _;
    }

    function Auction() public payable{

        beneficiary = msg.sender;

        uint[] memory emptyArray;

        items[0] = Item({itemId:0,itemTokens:emptyArray});
        items[1] = Item(1,emptyArray);
        items[2] = Item(2,emptyArray);
    }
    
    function register() public payable{
        /// @notice registers bidders
        
        bidders[bidderCount].addr = msg.sender;
        bidders[bidderCount].personId = bidderCount;
        
        // assign 5 tokens per bidder
        bidders[bidderCount].remainingTokens = 5; 
        tokenDetails[msg.sender]=bidders[bidderCount];

        // increment bidderCount for next register call
        bidderCount++;
    }
    
    function bid(uint _itemId, uint _count) public payable{
        /// @notice Bids tokens to a particular item
        /// @param _itemId id of the item
        /// @param _count count of tokens to bid for the item
        
        if (tokenDetails[msg.sender].remainingTokens < _count) revert();
        if (_itemId > items.length) revert();
 
        uint balance = tokenDetails[msg.sender].remainingTokens - _count;

        // update balance
        tokenDetails[msg.sender].remainingTokens=balance;
        bidders[tokenDetails[msg.sender].personId].remainingTokens=balance;
        
        // add tokens to item selected
        Item storage bidItem = items[_itemId];
        for(uint i=0; i<_count;i++) {
            bidItem.itemTokens.push(tokenDetails[msg.sender].personId);    
        }
    }
    
    function revealWinners() public onlyOwner{
        /// @notice  Iterate over all the items present in the auction.
        /// @notice  If at least a person has placed a bid, randomly select the winner

        for (uint id = 0; id < 3; id++) {
            Item storage currentItem=items[id];
            if(currentItem.itemTokens.length != 0){
                // generate random from block number 
                uint randomIndex = (block.number / currentItem.itemTokens.length) % currentItem.itemTokens.length; 
                // Obtain the winning tokenId
                uint winnerId = currentItem.itemTokens[randomIndex];
                winners[id] = bidders[winnerId].addr;
            }
        }
    } 

    function getPersonDetails(uint id) public constant returns(uint,uint,address){
        return (bidders[id].remainingTokens,bidders[id].personId,bidders[id].addr);
    }

    function getItemTokens(uint itemId) public view returns(uint[]){
        return (items[itemId].itemTokens);
    }

}
