// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "./Test.sol";

contract NFTStaking is Ownable {

  // struct to store a stake's token, owner and timestamp
  struct Stake {
    uint256 tokenId;
    uint256 timeStamp;
    address owner;
  }

}
