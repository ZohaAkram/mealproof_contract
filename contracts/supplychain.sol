// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.20;

contract SupplyChain{
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


struct Item {
    uint    sku;  // Stock Keeping Unit (SKU)
    uint    upc; // Universal Product Code (UPC)
    address ownerID;  
    address originsupplierID; // Metamask-Ethereum address of supplier
    string  originsupplierName; // supplier Name
    uint    productID;  // Product ID potentially a combination of upc + sku
    uint    productPrice; // Product Price
    State   itemState;  // Product State as represented in the enum above
    address manufacturerID;  // Metamask address of manufacturer
    address retailerID; // Metamask-Ethereum address of the Retailer
    
  }

     }

