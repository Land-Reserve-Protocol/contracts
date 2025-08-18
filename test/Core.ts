import { type HardhatEthersSigner } from '@nomicfoundation/hardhat-ethers/signers';
import { loadFixture } from '@nomicfoundation/hardhat-network-helpers';
import type {
  Actions,
  LRShare,
  MarketPlace,
  Order,
  RoleRegistry,
  ShareTokenRegistry,
  TestERC20,
  Zone,
  ZoneRegistry,
} from '../artifacts/types';
import { localConstants, setupFixtures } from './helpers';
import { COUNCIL_MEMBER_ROLE, REGISTRY_UPDATER_ROLE } from '../scripts/constants';
import { expect } from 'chai';
import { getContractAtAddress } from '../scripts/helpers';
import { parseEther, parseUnits } from 'ethers';

let marketplace: MarketPlace;
let actions: Actions;
let shareTokenRegistry: ShareTokenRegistry;
let roleRegistry: RoleRegistry;
let zoneRegistry: ZoneRegistry;
let signer0: HardhatEthersSigner;
let signer1: HardhatEthersSigner;
let usdt: TestERC20;

const { ZONE_COORDINATE_LAT, ZONE_COORDINATE_LNG } = localConstants();

describe('Core', () => {
  before(async () => {
    ({ marketplace, actions, shareTokenRegistry, roleRegistry, signer0, signer1, usdt, zoneRegistry } =
      await loadFixture(setupFixtures));
  });
  describe('Roles', () => {
    it('should successfully grant roles', async () => {
      const actionsAddress = await actions.getAddress();
      await roleRegistry.grantRole(COUNCIL_MEMBER_ROLE, signer0.address);
      await roleRegistry.grantRole(REGISTRY_UPDATER_ROLE, actionsAddress);
      expect(await roleRegistry.hasRole(COUNCIL_MEMBER_ROLE, signer0.address)).to.be.true;
      expect(await roleRegistry.hasRole(REGISTRY_UPDATER_ROLE, actionsAddress)).to.be.true;
    });
  });
  describe('Actions', () => {
    it('should allow the deployment of a new zone', async () => {
      await expect(actions.deployZone('Ikeja', 'IKJ', ZONE_COORDINATE_LAT, ZONE_COORDINATE_LNG)).to.emit(
        actions,
        'NewZone',
      );
    });
    it('should not allow zone deployment when paused', async () => {
      await actions.switchPauseState();
      await expect(actions.deployZone('Ikeja', 'IKJ', ZONE_COORDINATE_LAT, ZONE_COORDINATE_LNG)).to.be.reverted;
    });
    it('should allow minting within a zone', async () => {
      await actions.switchPauseState(); // Unpause
      const zones = await zoneRegistry.allZones();
      await actions.mintWithinZone(
        zones[0],
        signer1.address,
        parseEther('1000000000'),
        'https://example.com/metadata',
        await usdt.getAddress(),
        [2500, 2500, 2500, 2500],
        1,
      );
      const zone = await getContractAtAddress<Zone>('Zone', zones[0]);
      expect(await zone.tokenId()).to.equal(1);
    });
    it('should disallow minting within unknown zones', async () => {
      await expect(
        actions.mintWithinZone(
          signer0.address,
          signer1.address,
          parseEther('1000'),
          'https://example.com/metadata',
          await usdt.getAddress(),
          [2500, 2500, 2500, 2500],
          1,
        ),
      ).to.be.revertedWithCustomError(actions, 'UnknownZone');
    });
  });
  describe('Marketplace', () => {
    it('should allow order creation [buy]', async () => {
      const assets = await shareTokenRegistry.allShareTokens();
      const marketplaceAddress = await marketplace.getAddress();
      // Approve to spend 500000 USDT
      await usdt.approve(marketplaceAddress, parseUnits('500000', 6));
      await expect(marketplace.createOrder(assets[0], 0, 5000000000, parseUnits('1', 6))).to.emit(
        marketplace,
        'OrderCreated',
      );
    });
    it('should allow order fulfillment [buy]', async () => {
      const orders = await marketplace.allOrders();
      const assets = await shareTokenRegistry.allShareTokens();
      const order = await getContractAtAddress<Order>('Order', orders[0]);
      const asset = await getContractAtAddress<LRShare>('LRShare', assets[0]);
      // Approve order contract to spend 500000 shares
      await asset.connect(signer1).approve(orders[0], parseEther('500000'));
      await order.connect(signer1).fulfill();
      // Get status of the order
      const status = await marketplace.status(orders[0]);
      expect(status).to.equal(1n); // 1 means Fulfilled
    });
    it('should allow order creation [sell]', async () => {
      const assets = await shareTokenRegistry.allShareTokens();
      const marketplaceAddress = await marketplace.getAddress();
      const asset = await getContractAtAddress<LRShare>('LRShare', assets[0]);
      // Approve to spend 100000 shares
      await asset.approve(marketplaceAddress, parseEther('100000'));
      await expect(marketplace.createOrder(assets[0], 1, 1000000000, parseUnits('1', 6))).to.emit(
        marketplace,
        'OrderCreated',
      );
    });
    it('should allow order fulfillment [sell]', async () => {
      const orders = await marketplace.allOrders();
      const order = await getContractAtAddress<Order>('Order', orders[1]);
      // Approve order contract to spend 100000 USDT
      await usdt.connect(signer1).approve(orders[1], parseUnits('100000', 6));
      await order.connect(signer1).fulfill();
      // Get status of the order
      const status = await marketplace.status(orders[1]);
      expect(status).to.equal(1n); // 1 means Fulfilled
    });
    it('should not allow order creation for unknown assets', async () => {
      await expect(marketplace.createOrder(signer0.address, 0, 500, parseUnits('1', 6))).to.be.revertedWithCustomError(
        marketplace,
        'UnknownShareToken',
      );
    });
  });
});
