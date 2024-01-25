import hardhat from 'hardhat';

import { exit } from 'process';

import 'dotenv';

async function main() {
  // verify contract
  // await verify('0x1c142D5449B581a49616ac879631913b43e579e2', []);
  // await verify('0x7D0a4cEC82BF980d622edAcaF8d42222eD46f729', [`${13}`, `${12}`, '0x1c142D5449B581a49616ac879631913b43e579e2']);
  // await verify('0x8856a7C5eC1a6464C920Da2bc4F50144d581B0A4', ['PYRAHMID', 'PMD', 1, '0x5c3DAffa3FB1994781d2727AF42Fec893AAe27Bd']);
  await verify('0xfe51d160B89F7Ba35b6206D3cDb46dFe61F372C5', []);
}

export const verify = async (contractAddress: string, args: Array<String | boolean | number>) => {
  console.log('Verifying contract...');
  try {
    await hardhat.run('verify:verify', {
      // contract: 'contracts/TransferProxy.sol:TransferProxy',
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
