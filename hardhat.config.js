require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
 module.exports = {
  defaultNetwork: "mainnet",
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545",
      // accounts: ["6138e2d6a61f5dfe758ec96c46811e0f0a2311bb9381dbdfd17d639d87b15e39"]
    },
    hardhat: {
      // forking: {
      //   url: "https://data-seed-prebsc-1-s1.binance.org:8545/",
      //   chainId: 97,
      //   gasPrice: 20000000000,
      //   accounts: ["9e33e7fc1edaad3099f6788013921c5a01f418be85eff34f94a6a8923b6fc671"]
      // }
    },
    testnet: {
      url: "https://rinkeby.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161",
      chainId: 4,
      gasPrice: 20000000000,
      accounts: ["fd9567d7e270a6f01ffcff3ec5dce5eae6d0cb4d22d356758e3e876aff846198"]
    },
    mainnet: {
      url: "https://mainnet.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161",
      chainId: 4,
      gasPrice: 20000000000,
      accounts: ["9e33e7fc1edaad3099f6788013921c5a01f418be85eff34f94a6a8923b6fc671"]
    }
  },
  etherscan: {
    apiKey: 
    {
      mainnet: "B77M9DYRXMQC74ZI9N8TH5EETPMSX66MAE",
      ropsten: "B77M9DYRXMQC74ZI9N8TH5EETPMSX66MAE",
      rinkeby: "B77M9DYRXMQC74ZI9N8TH5EETPMSX66MAE",
      goerli: "B77M9DYRXMQC74ZI9N8TH5EETPMSX66MAE",
      kovan: "B77M9DYRXMQC74ZI9N8TH5EETPMSX66MAE",
      // binance smart chain
      bsc: "P5W8JCU8Q3F8CNVX69DXU8PCFVE6VGG8QT",
      bscTestnet: "P5W8JCU8Q3F8CNVX69DXU8PCFVE6VGG8QT"
    }
  },
  solidity: {
    compilers: [
      {
        version: "0.8.0",
      },
      {
        version: "0.7.6",
      }
    ],
    settings: {
      optimizer: {
        enabled: true
      }
    }
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
  mocha: {
    timeout: 200000
  }
};