import { ethers } from 'hardhat';
import {
  Actions,
  LRShare,
  MarketPlace,
  Order,
  RoleRegistry,
  ShareTokenRegistry,
  TestERC20,
  Zone,
  ZoneRegistry,
} from '../../artifacts/types';
import { deployContract } from '../../scripts/helpers';

export async function setupFixtures() {
  const [signer0, signer1] = await ethers.getSigners();
  const roleRegistry = await deployContract<RoleRegistry>('RoleRegistry', undefined, signer0.address);
  const shareTokenRegistry = await deployContract<ShareTokenRegistry>(
    'ShareTokenRegistry',
    undefined,
    signer0.address,
    await roleRegistry.getAddress(),
  );
  const zoneRegistry = await deployContract<ZoneRegistry>(
    'ZoneRegistry',
    undefined,
    signer0.address,
    await roleRegistry.getAddress(),
  );
  const zone = await deployContract<Zone>('Zone');
  const lrShare = await deployContract<LRShare>('LRShare');
  const order = await deployContract<Order>('Order');
  const marketplace = await deployContract<MarketPlace>(
    'MarketPlace',
    undefined,
    await order.getAddress(),
    await roleRegistry.getAddress(),
    await shareTokenRegistry.getAddress(),
  );
  const actions = await deployContract<Actions>(
    'Actions',
    undefined,
    await zone.getAddress(),
    await lrShare.getAddress(),
    await roleRegistry.getAddress(),
    await shareTokenRegistry.getAddress(),
    await zoneRegistry.getAddress(),
    await marketplace.getAddress(),
  );
  const usdt = await deployContract<TestERC20>('TestERC20');
  return { signer0, signer1, roleRegistry, shareTokenRegistry, zoneRegistry, actions, marketplace, usdt };
}

export function localConstants() {
  return { ZONE_COORDINATE_LAT: 66018, ZONE_COORDINATE_LNG: 33515 };
}
