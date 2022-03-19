// SPDX-License-Identifier: MIT LICENSE

pragma solidity 0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface INFT is IERC721 {
    function mint(string memory _tokenURI, address _toAddress, uint _price) external returns (uint);
    // function ownerOf(uint256 tokenId) public view external override returns (address);
}