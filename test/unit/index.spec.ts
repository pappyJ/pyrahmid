import { expect } from 'chai';
import { ethers } from 'hardhat';
import '@nomiclabs/hardhat-ethers';
import { loadFixture } from '@nomicfoundation/hardhat-toolbox/network-helpers';

describe('Asset Tokenisation Transactions', function () {
  async function deployMarketContracts() {
    const accounts = await ethers.getSigners();

    // getting contract namespaces
    const TransferProxyContract = await ethers.getContractFactory('contracts/TransferProxy.sol:TransferProxy');

    const TradeContract = await ethers.getContractFactory('Trade');

    const PyrahmidFactory = await ethers.getContractFactory('PYRAHMID');

    const UsdtFactory = await ethers.getContractFactory('TetherUSD');

    const TransferProxy = await TransferProxyContract.deploy();

    await TransferProxy.deployed();

    // after deploying the transferProxy proceed to deploy trade with transferProxy address.

    const Trade = await TradeContract.deploy(`${10}`, `${0}`, TransferProxy.address);

    await Trade.deployed();

    const Pyrahmid = await PyrahmidFactory.deploy('PYRAHMID', 'PMD', TransferProxy.address);

    await Pyrahmid.deployed();

    const Usdt = await UsdtFactory.deploy();

    await Usdt.deployed();

    return {
      factory: { TransferProxy, Trade, Pyrahmid, Usdt },
      accounts,
    };
  }
  it('Check signature', async function () {
    const {
      factory: { Trade, Pyrahmid, Usdt },
      accounts,
    } = await loadFixture(deployMarketContracts);

    const signer = accounts[0];
    const erc20Address = Usdt.address;
    const nftAddress = Pyrahmid.address;
    const amount = 1000000 * 50;

    const orderHash = await Trade.getMessageHash(signer.address, amount, nftAddress, erc20Address);

    console.log(orderHash);

    const signature = await signer.signMessage(ethers.utils.arrayify(orderHash));

    const ethHash = await Trade.getEthSignedMessageHash(orderHash);

    await Trade.recoverSigner(ethHash, signature);

    // Correct signature and message returns true
    expect(await Trade.verify(signer.address, amount, nftAddress, erc20Address, signature)).to.equal(true);
  });

  it('should verify mint and buy a single token', async function () {
    // Mint and Buys Assets

    const {
      factory: { TransferProxy, Trade, Pyrahmid, Usdt },
      accounts,
    } = await loadFixture(deployMarketContracts);

    const signer = accounts[0];
    const seller = signer.address;
    const buyer = accounts[1].address;
    const erc20Address = Usdt.address;
    const nftAddress = Pyrahmid.address;
    const nftType = 2;
    const unitPrice = 1000000;
    const amount = 1000000 + 1000000 * 0.1;
    const tokenId = 1;
    const tokenURI = 'https://x-studio.mypinata.cloud/ipfs/QmREYyviswGGBGaC4amev51iXk9mYNj895AXka5LvGK2vp';
    const royaltyAddress = [];
    const royaltyfee = [];
    const qty = 1;

    const orderHash = await Trade.getMessageHash(signer.address, amount, nftAddress, erc20Address);

    console.log(orderHash);

    const signature = await signer.signMessage(ethers.utils.arrayify(orderHash));

    Usdt.approve(TransferProxy.address, amount);

    await Trade.mintAndBuyAsset(
      [seller, buyer, erc20Address, nftAddress, nftType, unitPrice, amount, tokenId, tokenURI, royaltyAddress, royaltyfee, qty],
      signature
    );

    const currentTokenIndex = await Pyrahmid.tokenCounter();

    expect(currentTokenIndex.toString()).to.be.eql('2');
  });

  it('should verify mint and buy 40 tokens', async function () {
    // Mint and Buys Assets

    const {
      factory: { TransferProxy, Trade, Pyrahmid, Usdt },
      accounts,
    } = await loadFixture(deployMarketContracts);

    const signer = accounts[0];
    const seller = signer.address;
    const buyer = accounts[1].address;
    const erc20Address = Usdt.address;
    const nftAddress = Pyrahmid.address;
    const nftType = 3;
    const unitPrice = 1000000;
    const amount = 1000000 * 50;
    const tokenId = 1;
    const tokenURI = 'https://x-studio.mypinata.cloud/ipfs/QmREYyviswGGBGaC4amev51iXk9mYNj895AXka5LvGK2vp';
    const royaltyAddress = [];
    const royaltyfee = [];
    const qty = 40;

    const orderHash = await Trade.getMessageHash(signer.address, amount, nftAddress, erc20Address);

    console.log(orderHash);

    const signature = await signer.signMessage(ethers.utils.arrayify(orderHash));

    Usdt.approve(TransferProxy.address, amount);

    await Trade.mintAndBuyAsset(
      [seller, buyer, erc20Address, nftAddress, nftType, unitPrice, amount, tokenId, tokenURI, royaltyAddress, royaltyfee, qty],
      signature
    );

    const currentTokenIndex = await Pyrahmid.tokenCounter();

    expect(currentTokenIndex.toString()).to.be.eql('41');
  });
});
