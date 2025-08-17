import { ethers } from 'hardhat';
import { Libraries } from 'hardhat/types';

export async function deployContract<T>(contractName: string, libraries?: Libraries, ...args: any[]) {
  const contractFactory = await ethers.getContractFactory(contractName, { libraries });
  const deployment = await contractFactory.deploy(...args);
  const deployed = await deployment.waitForDeployment();
  return deployed as T;
}

export async function getContractAtAddress<T>(contractName: string, address: string) {
  const contract = await ethers.getContractAt(contractName, address);
  return contract as T;
}
