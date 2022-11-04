const AToken = artifacts.require("AToken"); //deploy token contract
const BToken = artifacts.require("BToken"); //deploy secondtoken contract
const TokenSwap = artifacts.require("TokenSwap"); // deploy swap contract

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

  // Transfer all tokens to TokenSwap
  await coolToken.transfer(tokenSwap.address, "1000000000000000000000000");
  await secondToken.transfer(tokenSwap.address, "10000000000000000000000000");
};
