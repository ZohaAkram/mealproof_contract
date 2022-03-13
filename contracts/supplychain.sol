// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.20;

contract SupplyChain {
  mapping(address => address[]) item_map;
  mapping(bytes32 => Item) itemIdentity;

  address contractOwner;
  bytes32 upc;

  enum State {
    producedBySupplier,
    forSaleBySupplier,
    purchasedByManufacturer,
    shippedBySupplier,
    receivedByManufacturer,
    processedByManufacturer,
    packagedByManufacturer,
    forSaleByManufacturer,
    purchasedByRetailer,
    shippedByManufacturer,
    receivedByRetailer
  }
  State constant defaultState = State.producedBySupplier;

  struct Item {
    bytes32 upc;
    uint256 productType;
    address SupplierID;
    string SupplierName;
    uint256 productPrice;
    State itemState;
    address manufacturerID;
    address retailerID;
    address ownerID;
  }

  //modifier
  modifier onlyOwner() {
    require(msg.sender == contractOwner, 'only ownercan do this');
    _;
  }
  modifier verifyCaller(address _userAddress) {
    require(msg.sender == _userAddress);
    _;
  }
  //events
  event producedBySupplier(bytes32 upc);
  event forSaleBySupplier(bytes32 upc, uint256 price);
  event lognewPurchase(
    bytes32 upc,
    uint256 time,
    uint256 qty,
    address supplierID
  );
  event purchasedByManufacturer(bytes32 upc);
  event shippedBySupplier(bytes32 _upc);

  function itemBySupplier(
    // not confirm about flavor and qty to form upc hash
    uint256 weight,
    uint256 flavor,
    uint256 _productType,
    uint256 qty,
    string memory _SupplierName
  ) public {
    itemIdentity[upc] = Item({
      upc: sha256(abi.encodePacked(weight, flavor, _productType, qty)),
      ownerID: contractOwner,
      SupplierID: msg.sender,
      SupplierName: _SupplierName,
      productPrice: uint256(0),
      itemState: defaultState,
      manufacturerID: address(0),
      retailerID: address(0),
      productType: _productType
    });

    emit producedBySupplier(upc);
  }

  function forSalebySupplier(bytes32 _upc, uint256 _price) public {
    itemIdentity[_upc].SupplierID = msg.sender;
    itemIdentity[_upc].itemState = State.forSaleBySupplier;
    itemIdentity[_upc].productPrice = _price;

    emit forSaleBySupplier(_upc, _price);
  }

  function orderByManufacturer(string memory desc)
    public
    view
    returns (address orderBy, string memory description)
  {
    return (msg.sender, desc);
  }

  function purchaseItemByManufacturer(bytes32 _upc, uint256 qty) public {
    itemIdentity[_upc].ownerID = msg.sender;
    itemIdentity[_upc].manufacturerID = msg.sender;
    itemIdentity[_upc].itemState = State.purchasedByManufacturer;
    item_map[msg.sender].push(itemIdentity[_upc].SupplierID);

    emit lognewPurchase(
      _upc,
      block.timestamp,
      qty,
      itemIdentity[_upc].SupplierID
    );

    emit purchasedByManufacturer(_upc);
  }

  function shippedItemBySupplier(bytes32 _upc)
    public
    verifyCaller(itemIdentity[_upc].SupplierID) // check msg.sender is supplierID
  {
    itemIdentity[_upc].itemState = State.shippedBySupplier; // update state
    emit shippedBySupplier(_upc);
  }
}
