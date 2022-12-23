import hardhat from 'hardhat';

import { exit } from 'process';

import 'dotenv';

async function main() {
  // verify contract
  await verify("0x70B015d2084C0CFbf6c06B63f8A2A9FE9D4fA2bF", [
    "0xf251d1b5215dd88DDa288689b2ceDC5f0843d7f4",
    'BETA',
    'BTA',
    1000,
    "https://x-studio.mypinata.cloud/ipfs/QmVzRFoEaY1EaFTcBtDceExNMH43EMCRiJEGfFW3cAHjTx",
  ]);
}

const verify = async (contractAddress: string, args: Array<String | boolean | number>) => {
  console.log('Verifying contract...');
  try {
    await hardhat.run('verify:verify', {
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
