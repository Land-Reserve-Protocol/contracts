import { network } from 'hardhat';
import { VARIABLES } from '../constants';
import { deployContract } from '../helpers';
import { RoleRegistry } from '../../artifacts/types';

async function deployRegistries() {
  const chainId = network.config.chainId as number;
  const variables = VARIABLES[chainId];
  const roleRegistry = await deployContract<RoleRegistry>('RoleRegistry', undefined, variables.team);
}
