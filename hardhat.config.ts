import { HardhatUserConfig } from 'hardhat/config';
import '@nomicfoundation/hardhat-toolbox';
import '@nomicfoundation/hardhat-verify';
import '@xyrusworx/hardhat-solidity-json';
import * as dotenv from 'dotenv';

dotenv.config();

const config: HardhatUserConfig = {
  solidity: '0.8.28',
  typechain: {
    outDir: 'artifacts/types',
    target: 'ethers-v6',
  },
  networks: {
    fluentTestnet: {
      url: 'https://rpc.testnet.fluent.xyz/',
      chainId: 20994,
      accounts: [process.env.PRIVATE_KEY as string],
      gasPrice: 'auto',
      gas: 'auto',
      gasMultiplier: 1,
    },
    megaETHTestnet: {
      url: 'https://carrot.megaeth.com/rpc',
      chainId: 6342,
      accounts: [process.env.PRIVATE_KEY as string],
      gasPrice: 'auto',
      gas: 'auto',
      gasMultiplier: 1,
    },
  },
  etherscan: {
    apiKey: {
      fluentTestnet: 'empty',
    },
    customChains: [
      {
        network: 'fluentTestnet',
        chainId: 20994,
        urls: {
          apiURL: 'https://testnet.fluentscan.xyz/api',
          browserURL: 'https://testnet.fluentscan.xyz',
        },
      },
    ],
  },
};

export default config;
