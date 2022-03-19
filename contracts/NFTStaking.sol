// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

import "./Test.sol";

contract NFTStaking is Ownable, IERC721Receiver, Pausable {
    // struct to store a sta ke's token, owner, and lastCalimed
    struct Stake {
        uint16 tokenId;
        uint80 lastCalimed;
        address owner;
    }

    event TokenStaked(address owner, uint256 tokenId, uint256 lastCalimed);
    event TokenClaimed(uint256 tokenId, bool unstaked);
    // reference to the AirNFTs NFT contract
    IERC721 airnfts;
    // reference to the erc20 contract;
    Test erc20;

    // maps tokenId to stake
    mapping(uint256 => Stake) public registery; 

    uint256 public constant DAILY_PROFIT_RATE = 60;
    // Nft must have 2 days worth of erc20 to unstake or else it's too cold
    uint256 public constant MINIMUM_TO_EXIT = 2 days;

    // amount of erc20 earned so far
    uint256 public totalEarned;
    // number of Nft staked in the Registery
    uint256 public totalStaked;

    uint256 public lastClaimTimestamp;

    // emergency rescue to allow unstaking without any checks but without erc20
    bool public rescueEnabled = false;

    constructor(address _nftAddr, address _erc20Addr) { 
        airnfts = IERC721(_nftAddr);
        erc20 = Test(_erc20Addr);
    }

    function addManyToRegistery(address account, uint16[] calldata tokenIds) external {
        require(account == _msgSender() || _msgSender() == address(airnfts), "STK: CAN NOT STAKE");
        for (uint i = 0; i < tokenIds.length; i++) {
            if (_msgSender() != address(airnfts)) { // dont do this step if its a mint + stake
                require(airnfts.ownerOf(tokenIds[i]) == _msgSender(), "STK: IS NOT OWNER");
                airnfts.transferFrom(_msgSender(), address(this), tokenIds[i]);
            } else if (tokenIds[i] == 0) {
                continue; // there may be gaps in the array for stolen tokens
            }
            _addNftToRegistery(account, tokenIds[i]);
        }
    }

    function _addNftToRegistery(address account, uint256 tokenId) internal whenNotPaused {
        registery[tokenId] = Stake({
            owner: account,
            tokenId: uint16(tokenId),
            lastCalimed: uint80(block.timestamp)
        });
        totalStaked += 1;
        emit TokenStaked(account, tokenId, block.timestamp);
    }

     /** CLAIMING / UNSTAKING */

    /**
    * @param tokenIds the IDs of the tokens to claim earnings from
    * @param unstake whether or not to unstake ALL of the tokens listed in tokenIds
    */
    function claimManyFromRegistery(uint16[] calldata tokenIds, bool unstake) external whenNotPaused {
        for (uint i = 0; i < tokenIds.length; i++) {
            _claimNftFromRegistery(tokenIds[i], unstake);
        }
    }

    /**
    * @param tokenId the ID of the NFT to claim earnings from
    * @param unstake whether or not to unstake the NFT
    */
    function _claimNftFromRegistery(uint256 tokenId, bool unstake) internal {
        Stake memory stake = registery[tokenId];
        require(stake.owner == _msgSender(), "STK: SHOULD BE OWNER");
        // require(!(unstake && block.timestamp - stake.lastCalimed < MINIMUM_TO_EXIT), "STK: CAN NOT CLAIM YET");

        erc20.updateStakeTokenForNFT(_msgSender());
        if (unstake) {
            airnfts.safeTransferFrom(address(this), _msgSender(), tokenId, ""); // send back NFT
            delete registery[tokenId];
            totalStaked -= 1;
        } else {
            registery[tokenId] = Stake({
                owner: _msgSender(),
                tokenId: uint16(tokenId),
                lastCalimed: uint80(block.timestamp)
            }); // reset stake
        }
        emit TokenClaimed(tokenId, unstake);
    }

    /**
    * emergency unstake tokens
    * @param tokenIds the IDs of the tokens to claim earnings from
    */
    function rescue(uint256[] calldata tokenIds) external {
        require(rescueEnabled, "STK: RESCUE DISABLED");
        uint256 tokenId;
        Stake memory stake;
        for (uint i = 0; i < tokenIds.length; i++) {
            tokenId = tokenIds[i];
            stake = registery[tokenId];
            require(stake.owner == _msgSender(), "STK: SHOULD BE OWNER");
            airnfts.safeTransferFrom(address(this), _msgSender(), tokenId, ""); // send back Lacedameon
            delete registery[tokenId];
            totalStaked -= 1;
            emit TokenClaimed(tokenId, true);
        }
    }

    /**
    * allows owner to enable "rescue mode"
    * simplifies accounting, prioritizes tokens out in emergency
    */
    function setRescueEnabled(bool _enabled) external onlyOwner {
        rescueEnabled = _enabled;
    }
    /**
    * enables owner to pause / unpause claiming
    */
    function setPaused(bool _paused) external onlyOwner {
        if (_paused) _pause();
        else _unpause();
    }

    function onERC721Received(
        address,
        address from,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        require(from == address(0x0), "STK: CAN NOT STAKE DIRECTLY");
        return IERC721Receiver.onERC721Received.selector;
    }
}