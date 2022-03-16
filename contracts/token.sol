// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.20;
import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol';

contract MyContract is ERC721 {
  struct Item {
    bytes32 product_code;
    uint256 product_cat;
    address SupplierID;
    uint256 productPrice;
    State itemState;
    address manufacturerID;
    address retailerID;
    address ownerID;
  }
  Item[] public items;
  mapping(string => Item) itemIdentity;

  function mintItem(address _to) {}
  function validate (address sender , address receiver , )
}
