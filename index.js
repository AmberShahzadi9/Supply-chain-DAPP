import Web3 from "web3";
import App from 'App'; 


import configuration from '../buildDistributorRole.json';
import configuration from '../buildManufacturerRole.json';
import configuration from '../buildOwnable.json';
import configuration from '../buildPharmacistRole.json';
import configuration from '../buildRoles.json';
import configuration from '..buildSupplyChain.json'

const CONTRACT_ADDRESS =
configuration.networks['5777'].address;
const CONTRACT_ABI = configuration.abi;

const Web3 = require('web3')

const contact = new Web3.eth.Contract(CONTRACT_ABI, CONTRACT_ADDRESS);

let account;
const main = async () => {
    const accounts = await web3.eth.requestAccounts();
}

main();