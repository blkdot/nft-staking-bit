const { expect } = require("chai");
const { ethers } = require("hardhat");
const { getBigNumber } = require("./utils");

describe("NFT Staking", function () {
  let nftStakingContract;
  before(async function () {
    [deployer] = await ethers.getSigners();

    const Test = await ethers.getContractFactory("Test");
    const testContract = await Test.deploy();
    await testContract.deployed();

    const NFTStaking = await ethers.getContractFactory("NFTStaking");
    nftStakingContract = await NFTStaking.deploy('0x0bc771180E6303580A3B29920Eb44D17d6C63cAb', testContract.address);
    await nftStakingContract.deployed();

  });

  it("Staking should work", async function() {
    const airNFTs = await ethers.getContractAt("INFT", "0x0bc771180E6303580A3B29920Eb44D17d6C63cAb");
    
    const mintTx1 = await airNFTs.mint("https://air-nfts-prime.web.app/api/nfts/triangon_h_1618133017409", deployer.address, getBigNumber(3 * 17));
    await mintTx1.wait();

    const mintTx2 = await airNFTs.mint("https://air-nfts-prime.web.app/api/nfts/3d_carrot_1618133173320", deployer.address, getBigNumber(3 * 17));
    await mintTx2.wait();

    const mintTx3 = await airNFTs.mint("https://air-nfts-prime.web.app/api/nfts/3d_carrot_1618133173321", deployer.address, getBigNumber(3 * 17));
    await mintTx3.wait();

    const mintTx4 = await airNFTs.mint("https://air-nfts-prime.web.app/api/nfts/3d_carrot_1618133173322", deployer.address, getBigNumber(3 * 17));
    await mintTx4.wait();
    
    // expect(await airNFTs.balanceOf(deployer.address)).to.equal(2);
    const txApprove = await airNFTs.setApprovalForAll(nftStakingContract.address, true);
    await txApprove.wait();

    const txPackStaking = await nftStakingContract.addManyToRegistery(deployer.address, [1, 2, 3, 4]);
    await txPackStaking.wait();
    
    const tokens = await nftStakingContract.getStakeInfoOfAccount(deployer.address);
    
    await nftStakingContract.claimAllOfAccount();
    const tokens1 = await nftStakingContract.getStakeInfoOfAccount(deployer.address);
    
    const txPackStaking1 = await nftStakingContract.addManyToRegistery(deployer.address, [1, 2, 3, 4]);
    await txPackStaking1.wait();

    expect(await airNFTs.ownerOf(1)).to.equal(nftStakingContract.address);
    expect(await airNFTs.ownerOf(2)).to.equal(nftStakingContract.address);

  });

  it("Claiming and rescue should work", async function() {
    const txClaim = await nftStakingContract.claimManyFromRegistery([1, 2], true);
    await txClaim.wait();

    const txEnableRescue = await nftStakingContract.setRescueEnabled(true);
    await txEnableRescue;

    const txRescue = await nftStakingContract.rescue([3, 4]);
    await txRescue.wait();
  });
});
