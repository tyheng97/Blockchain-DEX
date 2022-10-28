const CoolToken = artifacts.require("CoolToken"); //deploy token contract
const SecondToken = artifacts.require("SecondToken"); //deploy secondtoken contract
const EthSwap = artifacts.require("EthSwap"); // deploy swap contract

// Migration puts the smart contract on the blockchain using truffle
module.exports = async function(deployer) {
  // Deploy Token
  await deployer.deploy(CoolToken);
  const coolToken = await CoolToken.deployed();

  // Deploy Second Token
  await deployer.deploy(SecondToken);
  const secondToken = await SecondToken.deployed();

  // Deploy EthSwap
  await deployer.deploy(EthSwap, coolToken.address, secondToken.address);
  const ethSwap = await EthSwap.deployed();

  // Transfer all tokens to EthSwap
  await coolToken.transfer(ethSwap.address, "1000000000000000000000000");
  await secondToken.transfer(ethSwap.address, "10000000000000000000000000");
};
