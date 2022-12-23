/* eslint-disable node/no-missing-import */
import 'dotenv/config';
import '@nomiclabs/hardhat-etherscan';
import '@nomiclabs/hardhat-waffle';
import '@typechain/hardhat';
import 'hardhat-gas-reporter';
import 'solidity-coverage';
import './tasks/accounts';
import { HardhatUserConfig } from 'hardhat/config';
import { removeConsoleLog } from 'hardhat-preprocessor';

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

const privateKey = process.env.PRIVATE_KEY!;

interface HardhatUserConfigPro extends HardhatUserConfig {
  etherscan: { [key: string]: any };
}

const config: HardhatUserConfigPro = {
  defaultNetwork: 'hardhat',

  networks: {
    hardhat: {
      chainId: 1337,
    },
    mainnet: {
      chainId: 1,
      url: 'https://mainnet.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161',
      accounts: [privateKey],
    },
    polygon: {
      chainId: 137,
      url: 'https://polygon-rpc.com/',
      accounts: [privateKey],
    },
    binance: {
      chainId: 56,
      url: 'https://bsc-dataseed1.ninicoin.io',
      accounts: [privateKey],
    },
    goerli: {
      chainId: 5,
      url: 'https://rpc.ankr.com/eth_goerli',
      accounts: [privateKey],
    },
    mumbai: {
      chainId: 80001,
      url: 'https://rpc-mumbai.maticvigil.com',
      accounts: [privateKey],
    },

    tbinance: {
      chainId: 97,
      url: 'https://data-seed-prebsc-1-s1.binance.org:8545/',
      accounts: [privateKey],
    },
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: 'USD',
  },

  etherscan: {
    apiKey: {
      mainnet: process.env.ETHERSCAN_API_KEY,
      polygon: process.env.POLYGONSCAN_API_KEY,
      bsc:  process.env.BSCSCAN_API_KEY,
      bscTestnet: process.env.BSCSCAN_API_KEY,
      polygonMumbai: process.env.POLYGONSCAN_API_KEY,
      goerli: process.env.ETHERSCAN_API_KEY,
    },
  },
  solidity: {
    compilers: [
      {
        version: '0.8.7',
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },
  preprocess: {
    eachLine: removeConsoleLog((hre) => hre.network.name !== 'hardhat'),
  },
  paths: {
    root: './',
    sources: './contracts',
    tests: './test',
    cache: './cache',
    artifacts: './artifacts',
  },
  mocha: {
    timeout: 20000,
  },
};

export default config;
