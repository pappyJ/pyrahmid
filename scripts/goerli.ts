import { ethers, network, upgrades } from 'hardhat';

import { appendFileSync } from 'fs';

import { join } from 'path';

import { exit } from 'process';

require('dotenv');

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log('DEPLOYING CONTRACT WITH THE ACCOUNT :', deployer.address);

  console.log('DEPLOYER ACCOUNT BALANCE:', (await deployer.getBalance()).toString());

  // getting contract namespaces
  const PYRAHMIDUPG = await ethers.getContractFactory('PYRAHMIDUPG');

  const pYRAHMIDUPG = await upgrades.deployProxy(PYRAHMIDUPG, ['RealInit', 'RLI', 'https://...', '100'], {
    initializer: 'initialize',
  });

  await pYRAHMIDUPG.deployed();

  console.log('Pyrahmid Contract Factory DEPLOYED TO:', pYRAHMIDUPG.address);

  const config = `
  NETWORK => ${network.name}

  =====================================================================

  MLE Token ${pYRAHMIDUPG.address}

  =====================================================================

  `;

  const data = JSON.stringify(config);

  appendFileSync(join(__dirname, '../contracts/addressBook.md'), JSON.parse(data));
}

main()
  .then(() => exit(0))
  .catch((error) => {
    console.error(error);

    exit(1);
  });
