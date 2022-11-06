const AToken = artifacts.require("./src/contracts/AToken"); //deploy token contract
const BToken = artifacts.require("./src/contracts/BToken"); //deploy secondtoken contract
const EthSwap = artifacts.require("./src/contracts/EthSwap"); // deploy swap contract
const TokenSwap = artifacts.require("./src/contracts/TokenSwap"); // deploy swap contract
const TokenSwapInv = artifacts.require("./src/contracts/TokenSwapInv"); // deploy swap contract

// Migration puts the smart contract on the blockchain using truffle
module.exports = async function(deployer) {
  // Deploy Token
  await deployer.deploy(AToken);
  const aToken = await AToken.deployed();

  // Deploy Second Token
  await deployer.deploy(BToken);
  const bToken = await BToken.deployed();

  // Deploy TokenSwap
  await deployer.deploy(TokenSwap, aToken.address, bToken.address);
  const tokenSwap = await TokenSwap.deployed();

  await deployer.deploy(TokenSwapInv, aToken.address, bToken.address);
  const tokenSwapInv = await TokenSwapInv.deployed();
  // Deploy
  await deployer.deploy(EthSwap, aToken.address, bToken.address);
  const ethSwap = await EthSwap.deployed();

  // Transfer all tokens to TokenSwap
  await aToken.transfer(ethSwap.address, "1000000000000000000000000");
  await bToken.transfer(ethSwap.address, "10000000000000000000000000");
};
