// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.20;

contract SupplyChain{

    uint upc;
    uint sku;
    address contractOwner;
    mapping(string=>address[]) merhmap;
    mapping(uint => Item) items; // maps UPC to an item 
    mapping (uint => string[]) itemsHistory; // maps UPC to an array of Tx hash
    constructor () public{
        contractOwner=msg.sender;
        sku = 1;
    upc = 1;
    }
    enum State{
         ProducedBySupplier, 
         ForSaleBySupplier,
         PurchasedByManufacturer,
         ShippedBySupplier,
         ReceivedByManufacturer,
         ProcessedByManufacturer,
         PackagedByManufacturer,
         ForSaleByManufacturer,
         PurchasedByRetailer,
         ShippedByManufacturer,
         ReceivedByRetailer
     }
State constant defaultState = State.ProducedBySupplier;
struct Item {
    uint    sku;  // Stock Keeping Unit (SKU)
    uint    upc; // Universal Product Code (UPC)
    address ownerID;  
    address SupplierID; // Metamask-Ethereum address of supplier
    string  SupplierName; // supplier Name
    uint    productID;  // Product ID potentially a combination of upc + sku
    uint    productPrice; // Product Price
    State   itemState;  // Product State as represented in the enum above
    address manufacturerID;
    string manuId;  // Metamask address of manufacturer
    address retailerID; // Metamask-Ethereum address of the Retailer
    // uint    creationTime;
    // uint    mfg_date;
    // uint    exp_date;
    // uint flavour;
  }
   modifier onlyOwner(){
       require(msg.sender==contractOwner,'only owner can do this ');
       _;
   }
   modifier verifyCaller(address _userAddress){
       require(msg.sender == _userAddress);
       _;
   }
   event ProducedBySupplier(uint upc);    
    event PurchasedByManufacturer(uint upc);
     event lognewPurchase   (uint _upc,uint time ,uint _quantity, string _manufacturerId,address SupplierID); //insert FTD
    function itemBySupplier(uint _upc, address _SupplierID, string memory _SupplierName)public {
           items[_upc] = Item({
        sku: sku+1,
        // Universal Product Code (UPC):
        upc: upc,
        // Metamask-Ethereum address of the current owner:
        ownerID: contractOwner,
        // Metamask-Ethereum address of Farmer:
        SupplierID: _SupplierID,
        SupplierName:_SupplierName,
        // Farmer Name:
      // Product ID potentially a combination of upc + sku:
        productID: _upc + sku,
        productPrice: uint(0),
        // Product State as represented in the enum above:
        itemState: defaultState,
        // Metamask-Ethereum address of  Distributor:
        manufacturerID: address(0),
        retailerID: address(0),
        manuId:'0'
        // Metamask-Ethereum address of the Retailer:
        // retailerID: address(0)
        
        });sku = sku + 1;
    // Emit the appropriate event
    emit ProducedBySupplier(_upc);
       }



       function purchaseItemByManufacturer(uint _upc, uint  quantity, string memory _manufacturerId) public  
         //producedBySupplier(_upc) // check items state has been produced
        //verifyCaller(items[_upc].ownerID) // check msg.sender is owner// check msg.sender belongs to distributorRole
        //forSaleBySupplier(_upc) // check items state is for ForSaleByFarmer
        {
        // transfer funds from distributor to farmer
        items[_upc].ownerID = msg.sender; // update owner
        items[_upc].manufacturerID = msg.sender; // update distributor
       
        items[_upc].itemState = State.PurchasedByManufacturer; // update state
        items[_upc].manuId=_manufacturerId;
        //items[_upc].itemState = State.ReceivedByManufacturer; // update state
       //mechsupquantity[_merchandizerId][items[_upc].originsupplierID]=quantity;
       merhmap[_manufacturerId].push(items[_upc].SupplierID);
        // itemsHistory[_upc].FTD = block.number; // add block number
      //emit ForSaleBySupplier(_upc);
        emit lognewPurchase   (_upc,block.timestamp, quantity,_manufacturerId,items[_upc].SupplierID);
        // itemsHistory[_upc].FTD);
       
        emit PurchasedByManufacturer(_upc);
       
       
        
        }

     }

