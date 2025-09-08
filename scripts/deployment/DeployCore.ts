import { createWriteStream, existsSync } from 'fs';
import { writeFile } from 'fs/promises';
import { join } from 'path';
import { network } from 'hardhat';
import { COUNCIL_MEMBER_ROLE, REGISTRY_UPDATER_ROLE, VARIABLES } from '../constants';
import { deployContract, getContractAtAddress } from '../helpers';
import {
  Actions,
  LRShare,
  Marketplace,
  Order,
  RoleRegistry,
  ShareTokenRegistry,
  Zone,
  ZoneRegistry,
} from '../../artifacts/types';

async function deployRegistries() {
  const chainId = network.config.chainId as number;
  const variables = VARIABLES[chainId];
  const roleRegistryContract = await deployContract<RoleRegistry>('RoleRegistry', undefined, variables.team);
  const roleRegistry = await roleRegistryContract.getAddress();
  const shareTokenRegistryContract = await deployContract<ShareTokenRegistry>(
    'ShareTokenRegistry',
    undefined,
    variables.team,
    roleRegistry,
  );
  const shareTokenRegistry = await shareTokenRegistryContract.getAddress();
  const zoneRegistryContract = await deployContract<ZoneRegistry>(
    'ZoneRegistry',
    undefined,
    variables.team,
    roleRegistry,
  );
  const zoneRegistry = await zoneRegistryContract.getAddress();

  return { roleRegistry, shareTokenRegistry, zoneRegistry };
}

async function deployImplementations() {
  const zoneContract = await deployContract<Zone>('Zone');
  const lrShareContract = await deployContract<LRShare>('LRShare');
  const orderContract = await deployContract<Order>('Order');

  const zone = await zoneContract.getAddress();
  const shareToken = await lrShareContract.getAddress();
  const order = await orderContract.getAddress();

  return { zone, shareToken, order };
}

async function deployCore() {
  const networkId = network.config.chainId as number;
  const variables = VARIABLES[networkId];
  const { roleRegistry, shareTokenRegistry, zoneRegistry } = await deployRegistries();
  const { zone, shareToken, order } = await deployImplementations();
  const marketplaceContract = await deployContract<Marketplace>(
    'Marketplace',
    undefined,
    order,
    roleRegistry,
    shareTokenRegistry,
  );
  const marketplace = await marketplaceContract.getAddress();
  const actionsContract = await deployContract<Actions>(
    'Actions',
    undefined,
    zone,
    shareToken,
    roleRegistry,
    shareTokenRegistry,
    zoneRegistry,
    marketplace,
  );
  const actions = await actionsContract.getAddress();
  const roleRegistryContract = await getContractAtAddress<RoleRegistry>('RoleRegistry', roleRegistry);
  // Award roles
  await roleRegistryContract.grantRole(COUNCIL_MEMBER_ROLE, variables.team);
  await roleRegistryContract.grantRole(REGISTRY_UPDATER_ROLE, variables.team);
  await roleRegistryContract.grantRole(REGISTRY_UPDATER_ROLE, actions);

  return { roleRegistry, shareTokenRegistry, zoneRegistry, marketplace, actions };
}

async function main() {
  const networkId = network.config.chainId as number;
  const outputDirectory = 'scripts/deployment/output';
  const outputFile = join(process.cwd(), outputDirectory, `CoreOutput-${String(networkId)}.json`);
  const deploymentResult = await deployCore();

  try {
    if (!existsSync(outputFile)) {
      const ws = createWriteStream(outputFile);
      ws.write(JSON.stringify(deploymentResult, null, 2));
      ws.end();
    } else {
      await writeFile(outputFile, JSON.stringify(deploymentResult, null, 2));
    }
  } catch (err) {
    console.error(`Error writing output file: ${err}`);
  }
}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
