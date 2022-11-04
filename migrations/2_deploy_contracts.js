const AToken = artifacts.require("./src/contracts/AToken"); //deploy token contract
const BToken = artifacts.require("./src/contracts/BToken"); //deploy secondtoken contract
const EthSwap = artifacts.require("./src/contracts/EthSwap"); // deploy swap contract
const TokenSwap = artifacts.require("./src/contracts/TokenSwap"); // deploy swap contract

// Migration puts the smart contract on the blockchain using truffle
module.exports = async function(deployer) {
  // Deploy Token
  await deployer.deploy(AToken);
  const coolToken = await AToken.deployed();

  // Deploy Second Token
  await deployer.deploy(BToken);
  const secondToken = await BToken.deployed();

  // Deploy TokenSwap
  await deployer.deploy(TokenSwap, coolToken.address, secondToken.address);
  const tokenSwap = await TokenSwap.deployed();
  // Deploy
  await deployer.deploy(EthSwap, coolToken.address, secondToken.address);
  const ethSwap = await EthSwap.deployed();

  // Transfer all tokens to TokenSwap
  await coolToken.transfer(ethSwap.address, "1000000000000000000000000");
  await secondToken.transfer(ethSwap.address, "10000000000000000000000000");
};
