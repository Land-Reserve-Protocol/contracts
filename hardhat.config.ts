import { HardhatUserConfig } from 'hardhat/config';
import '@nomicfoundation/hardhat-toolbox';

const config: HardhatUserConfig = {
  solidity: '0.8.28',
  typechain: {
    outDir: 'artifacts/types',
    target: 'ethers-v6',
  },
};

export default config;
