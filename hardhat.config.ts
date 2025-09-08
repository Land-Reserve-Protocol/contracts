import { HardhatUserConfig } from 'hardhat/config';
import '@nomicfoundation/hardhat-toolbox';
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
  },
};

export default config;
