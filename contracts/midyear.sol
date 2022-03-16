// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.20;
import '@openzeppelin/contracts/token/ERC721/ERC721.sol';

// import '@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol';

contract token is ERC721 {
  address contractOwner;
  bytes32[] array_proof;

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
    // uint batchNo;
  }
  struct Nugget {
    uint256 product_code;
    address ownerID;
    State NuggetState;
    // uint batchNo;
  }
  mapping(bytes32 => Item) itemInfo;
  //   mapping(uint => Item) itemMap; //batchNo that maps to array of items in a batch
  mapping(uint256 => uint256) itemforSale; // assigning price to items in a batch
  mapping(bytes32 => Nugget) nuggetInfo;
  mapping(uint256 => Nugget) nuggetIdentity;
  mapping(uint256 => uint256) nuggetMap;
  event lognewItem(uint256 tokenID, uint256 createdAt);
  event lognewNugget(uint256 tokenID, uint256 createdAt);

  function itemBySupplier(
    uint256 weight,
    uint256 flavor,
    uint256 qty,
    uint256 productType
  ) public returns (uint256) {
    // uint i;

    tokenID = sha256(abi.encodePacked(weight, flavor, qty, productType));
    Item memory newItem = Item(
      uint256(tokenID),
      msg.sender,
      State.producedBySupplier
    );
    itemInfo[tokenID] = newItem;
    _mint(msg.sender, uint256(tokenID));
    emit lognewItem(uint256(tokenID), block.timestamp);
    return (uint256(itemInfo[tokenID].itemState));

    // itemInfo[tokenID].push(itemInfo[tokenID]);
  }

  function itemForSale(uint256 _tokenId, uint256 _price) public {
    require(
      ownerOf(uint256(_tokenId)) == msg.sender,
      "You can't sale the Star you don't owned"
    );
    // itemMap[batchNo].push(itemInfo[_tokenId]);
    itemforSale[uint256(_tokenId)] = _price;
  }

  function purchasedByManufacturer(
    address from,
    address to,
    uint256 _tokenId
  ) public {
    (itemforSale[_tokenId] > 0, 'The Star should be up for sale');
    safeTransferFrom(from, to, uint256(_tokenId));
  }

  function shippedBySupplier(bytes32 _tokenId) public {
    itemInfo[(_tokenId)].itemState = State.shippedBySupplier;
  }

  function packagedByManufacturer(
    uint256 weight,
    uint256 flavor,
    uint256 qty,
    uint256 productType
  ) public returns (uint256) {
    tokenID = sha256(abi.encodePacked(weight, flavor, qty, productType));
    Nugget memory newNugget = Nugget(
      uint256(tokenID),
      msg.sender,
      State.packagedByManufacturer
    );
    nuggetInfo[tokenID] = newNugget;
    _mint(msg.sender, uint256(tokenID));
    emit lognewNugget(uint256(tokenID), block.timestamp);
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
