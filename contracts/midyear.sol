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
    bytes32 product_code;
    address ownerID;
    State itemState;
    uint256 price;
  }
  struct Nugget {
    bytes32 product_code;
    address ownerID;
    State NuggetState;
    bytes32[] items;
  }

  //hashtable----------------------------------
  mapping(uint256 => Item) itemInfo;

  // mapping(uint => Item) itemforSale;
  mapping(bytes32 => Nugget) nuggetInfo;
  mapping(uint256 => uint256) nuggetMap;

  //events--------------------------------
  event lognewItem(bytes32 tokenID, string _mystring, uint256 createdAt); //create new item by supplier
  event lognewNugget(bytes32 tokenID, string _mystring, uint256 createdAt);
  event _purchasedByManufacturer(
    bytes32 tokenID,
    string _mystring,
    uint256 createdAt
  );
  event _purchasedByRetailer(
    bytes32 tokenID,
    string _mystring,
    uint256 createdAt,
    bytes32[] recipe
  );
  event newnugget(bytes32[] recipe);
  //modiifer --------------------
  modifier arrayproof(
    address sender,
    address receiver,
    uint256 createdAt
  ) {
    hash = sha256(abi.encodePacked(sender, receiver, createdAt));
    array_proof.push(hash);
    _;
  }

  function itemBySupplier(bytes32 productHash)
    public
    arrayproof(address(0), msg.sender, block.timestamp)
    returns (uint256)
  {
    // uint i;

    // tokenID = sha256(abi.encodePacked(weight, flavor, qty, productType)); // in hash
    uint256 productHash_int = uint256(productHash); // convert hash to integer
    Item memory newItem = Item(
      productHash, //typecast hash into uint256
      msg.sender,
      State.producedBySupplier,
      uint256(0)
    );
    _mint(msg.sender, productHash_int);
    emit lognewItem(productHash, 'Item created by supplier', block.timestamp);
    return (uint256(itemInfo[productHash_int].itemState));
  }

  // sha256 is not bytes32 need to convert
  function itemForSale(uint256 _tokenId, uint256 _price) public {
    require(
      ownerOf(_tokenId) == msg.sender,
      "You can't sale the item you don't owned"
    );

    itemInfo[uint256(_tokenId)].price = _price; //assigning price to that item
  }

  function purchasedByManufacturer(
    address from,
    address to,
    bytes32 productHash
  ) public arrayproof(msg.sender, to, block.timestamp) {
    safeTransferFrom(from, to, uint256(productHash));
    itemInfo[uint256(productHash)].itemState = State.purchasedByManufacturer;
    emit _purchasedByManufacturer(
      productHash,
      'Item purchased by Manufacturer',
      block.timestamp
    );
  }

  function shippedBySupplier(uint256 int_tokenID) public {
    //to be seen again based on states
    itemInfo[(int_tokenID)].itemState = State.shippedBySupplier;
  }

  function packagedByManufacturer(bytes32 recipeHash, bytes32 fproductHash)
    public
    returns (uint256)
  {
    // require(ownerOf(int_tokenID) == msg.sender);
    // bytes32  recipeHash = sha256(abi.encodePacked(weight, flavor, qty, productType));
    uint256 recipeHash_int = uint256(recipeHash);
    uint256 fproductHash_int = uint256(fproductHash);
    //  rawItems =items.push(itemInfo[_rawTokenID]);
    Nugget memory newNugget = Nugget(
      fproductHash,
      msg.sender,
      State.packagedByManufacturer,
      rawItems
    );
    nuggetInfo[fproductHash].items.push(recipeHash); // use hash of raw items in nugget
    _mint(msg.sender, fproductHash_int);
    emit lognewNugget(
      fproductHash,
      'Item packaged by Manufacturer',
      block.timestamp
    );
    emit newnugget(nuggetInfo[fproductHash].items);

    return (
      uint256(
        nuggetInfo[fproductHash].NuggetState = State.packagedByManufacturer
      )
    );
  }

  function purchasedByRetailer(
    address from,
    address to,
    bytes32 fproductHash
  ) public arrayproof(msg.sender, to, block.timestamp) {
    // (
    //   (uint256(itemInfo[int_tokenID].price)) > 0,
    //   'The item should be up for sale'
    // );
    safeTransferFrom(from, to, uint256(fproductHash));
    itemInfo[uint256(fproductHash)].itemState = State.purchasedByRetailer;
    emit _purchasedByRetailer(
      fproductHash,
      'Item purchased by Retailer',
      block.timestamp,
      nuggetInfo[fproductHash].items
    );
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
