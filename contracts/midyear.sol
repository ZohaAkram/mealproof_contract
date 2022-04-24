// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.20;
import '@openzeppelin/contracts/token/ERC721/ERC721.sol';

// import '@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol';

contract token is ERC721 {
  address contractOwner;
  bytes32[] array_proof;
  bytes32 hash;
  bytes32[] rawItems;

  constructor() public ERC721('supplychain', 'SCP') {
    contractOwner = msg.sender;
  }

  bytes32 tokenID;
  enum State {
    producedBySupplier,
    forSaleBySupplier,
    purchasedByManufacturer,
    shippedBySupplier,
    receivedByManufacturer,
    packagedByManufacturer,
    forSaleByManufacturer,
    purchasedByRetailer,
    shippedByManufacturer,
    receivedByRetailer
  }
  struct Item {
    uint256 product_code;
    address ownerID;
    State itemState;
    uint256 price;
  }
  struct Nugget {
    uint256 product_code;
    address ownerID;
    State NuggetState;
    bytes32[] items;
  }

  //hashtable----------------------------------
  mapping(bytes32 => Item) itemInfo;

  // mapping(uint => Item) itemforSale;
  mapping(bytes32 => Nugget) nuggetInfo;
  mapping(uint256 => uint256) nuggetMap;

  //events--------------------------------
  event lognewItem(bytes32 tokenID, uint256 createdAt); //create new item by supplier
  event lognewNugget(bytes32 tokenID, uint256 createdAt);
  event _purchasedByManufacturer(bytes32 tokenID, uint256 createdAt);
  event newnugget(bytes32[] tokenId);
  //modiifer --------------------
  modifier arrayproof(address receiver, uint256 createdAt) {
    hash = sha256(abi.encodePacked(msg.sender, receiver, createdAt));
    array_proof.push(hash);
    _;
  }

  function itemBySupplier(
    uint256 weight,
    uint256 flavor,
    uint256 qty,
    uint256 productType
  ) public arrayproof(msg.sender, block.timestamp) returns (uint256) {
    // uint i;

    tokenID = sha256(abi.encodePacked(weight, flavor, qty, productType));
    Item memory newItem = Item(
      uint256(tokenID),
      msg.sender,
      State.producedBySupplier,
      uint256(0)
    );
    _mint(msg.sender, uint256(tokenID));
    emit lognewItem(tokenID, block.timestamp);
    return (uint256(itemInfo[tokenID].itemState));
  }

  function itemForSale(bytes32 _tokenId, uint256 _price) public {
    require(
      ownerOf(uint256(_tokenId)) == msg.sender,
      "You can't sale the item you don't owned"
    );

    itemInfo[(_tokenId)].price = _price; //assigning price to that item
  }

  function purchasedByManufacturer(
    address from,
    address to,
    bytes32 _tokenId
  ) public arrayproof(msg.sender, block.timestamp) {
    (itemInfo[_tokenId].price > 0, 'The item should be up for sale');
    safeTransferFrom(from, to, uint256(_tokenId));
    emit _purchasedByManufacturer(_tokenId, block.timestamp);
  }

  function shippedBySupplier(bytes32 _tokenId) public {
    //to be seen again based on states
    itemInfo[(_tokenId)].itemState = State.shippedBySupplier;
  }

  function packagedByManufacturer(
    uint256 weight,
    uint256 flavor,
    uint256 qty,
    uint256 productType,
    bytes32 _rawTokenID
  ) public returns (uint256) {
    tokenID = sha256(abi.encodePacked(weight, flavor, qty, productType));
    //  rawItems =items.push(itemInfo[_rawTokenID]);
    Nugget memory newNugget = Nugget(
      uint256(tokenID),
      msg.sender,
      State.packagedByManufacturer,
      rawItems
    );
    nuggetInfo[tokenID].items.push(_rawTokenID);
    _mint(msg.sender, uint256(tokenID));
    emit lognewNugget(tokenID, block.timestamp);
    emit newnugget(nuggetInfo[tokenID].items);
    return (uint256(nuggetInfo[tokenID].NuggetState));
  }

  function validate(
    address sender,
    address receiver,
    uint256 date,
    uint256 txn
  ) public view returns (bool valid) {
    bytes32 hash_new = (sha256(abi.encodePacked(sender, receiver, date)));
    if (array_proof[txn] == hash_new) {
      return (true);
    }

    // forsale by supplier will be used for sale by manufacturer
  }
}
