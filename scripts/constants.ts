import { id } from 'ethers';

type VariablesType = {
  team: string;
  councilMembers: string[];
};

export const MINTER_ROLE = id('MINTER');
export const COUNCIL_MEMBER_ROLE = id('COUNCIL_MEMBER');
export const RELAYER_ROLE = id('RELAYER');
export const ROLES_GOVERNOR_ROLE = id('ROLES_GOVERNOR');
export const REGISTRY_UPDATER_ROLE = id('REGISTRY_UPDATER');

export const VARIABLES: { [key: number]: VariablesType } = {
  20119: {
    team: '0xb69DB7b7B3aD64d53126DCD1f4D5fBDaea4fF578',
    councilMembers: [
      '0xb69DB7b7B3aD64d53126DCD1f4D5fBDaea4fF578',
      '0x29D57AC07e235d395b07965B3c788292Df731383',
      '0x2749fb5F7737F3ED173aa5bA5e56BAB551AE77d7',
    ],
  },
};
