import hardhat from 'hardhat';

import { exit } from 'process';

import 'dotenv';

async function main() {
  // verify contract
  await verify('0x1c142D5449B581a49616ac879631913b43e579e2', []);
  // await verify('0x7D0a4cEC82BF980d622edAcaF8d42222eD46f729', [`${13}`, `${12}`, '0x1c142D5449B581a49616ac879631913b43e579e2']);
  // await verify('0x4Be19E09F14fB396750C1d1006d22105792e6885', ['PYRAHMID', 'PMD', '0x1c142D5449B581a49616ac879631913b43e579e2']);
}

export const verify = async (contractAddress: string, args: Array<String | boolean | number>) => {
  console.log('Verifying contract...');
  try {
    await hardhat.run('verify:verify', {
      contract: 'contracts/TransferProxy.sol:TransferProxy',
      address: contractAddress,
      constructorArguments: args,
    });
  } catch (e: any) {
    if (e.message.toLowerCase().includes('already verified')) {
      console.log('Already Verified!');
    } else {
      console.log(e);
    }
  }
};

main()
  .then(() => exit(0))
  .catch((error) => {
    console.error(error);

    exit(1);
  });
