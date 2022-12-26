import {ethers} from 'hardhat';
require('dotenv').config({path: '.env'});

import {SPIRITTRIBES_NFT_ADDRESS} from '../constants';

async function main() {
  // Address of the Crypto Devs NFT contract that you deployed in the previous module
  const spiritTribesNft = SPIRITTRIBES_NFT_ADDRESS;

  /*
    A ContractFactory in ethers.js is an abstraction used to deploy new smart contracts,
    so SpiritTokenContract here is a factory for instances of our SpiritToken contract.
    */
  const SpiritTokenContract = await ethers.getContractFactory('SpiritToken');

  // deploy the contract
  const deployedSpiritTokenContract = await SpiritTokenContract.deploy(
    spiritTribesNft,
  );

  await deployedSpiritTokenContract.deployed();
  // print the address of the deployed contract
  console.log(
    'SpiritToken Contract Address:',
    deployedSpiritTokenContract.address,
  );
}

// Call the main function and catch if there is any error
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
