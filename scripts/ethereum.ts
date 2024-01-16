import { ethers, network } from 'hardhat';

import { appendFileSync } from 'fs';

import { join } from 'path';

import { exit } from 'process';

import { verify } from './verify';

require('dotenv');

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log('DEPLOYING CONTRACT WITH THE ACCOUNT :', deployer.address);

  console.log('DEPLOYER ACCOUNT BALANCE:', (await deployer.getBalance()).toString());

  // getting contract namespaces
  const TransferProxyContract = await ethers.getContractFactory('contracts/TransferProxy.sol:TransferProxy');

  const TradeContract = await ethers.getContractFactory('Trade');

  const PyrahmidFactory = await ethers.getContractFactory('PYRAHMID');

  const TransferProxy = await TransferProxyContract.deploy();

  await TransferProxy.deployed();

  // after deploying the transferProxy proceed to deploy trade with transferProxy address.

  const Trade = await TradeContract.deploy(`${13}`, `${12}`, TransferProxy.address);

  await Trade.deployed();

  const PYRAHMID = await PyrahmidFactory.deploy('PYRAHMID', 'PMD', TransferProxy.address);

  await PYRAHMID.deployed();

  console.log('TransferProxy Contract DEPLOYED TO:', TransferProxy.address);

  console.log('Trade Contract DEPLOYED TO:', Trade.address);

  console.log('PYRAHMID Token Contract DEPLOYED TO:', PYRAHMID.address);

  const config = `
  NETWORK => ${network.name}

  =====================================================================

  TransferProxy ${TransferProxy.address}

  Trade ${Trade.address}

  PYRAHMID Token ${PYRAHMID.address}

  =====================================================================


  `;

  const data = JSON.stringify(config);

  appendFileSync(join(__dirname, '../contracts/addressBook.md'), JSON.parse(data));

  await verify(TransferProxy.address, []);
  await verify(Trade.address, [`${13}`, `${12}`, TransferProxy.address]);
  await verify(PYRAHMID.address, ['PYRAHMID', 'PMD', TransferProxy.address]);
}

main()
  .then(() => exit(0))
  .catch((error) => {
    console.error(error);

    exit(1);
  });
