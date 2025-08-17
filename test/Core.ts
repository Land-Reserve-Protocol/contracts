import { type HardhatEthersSigner } from '@nomicfoundation/hardhat-ethers/signers';
import { loadFixture } from '@nomicfoundation/hardhat-network-helpers';
import type {
  Actions,
  MarketPlace,
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
import { parseEther } from 'ethers';

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
        parseEther('1000'),
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
});
