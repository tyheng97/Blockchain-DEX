const Token = artifacts.require("Token"); //deploy token contract
const EthSwap = artifacts.require("EthSwap"); // deploy swap contract

// Migration puts the smart contract on the blockchain using truffle
module.exports = async function(deployer) {
  // Deploy Token
  await deployer.deploy(Token);
  const token = await Token.deployed();

  // Deploy EthSwap
  await deployer.deploy(EthSwap, token.address);
  const ethSwap = await EthSwap.deployed();

  // Transfer all tokens to EthSwap (1 million)
  await token.transfer(ethSwap.address, "1000000000000000000000000");
};
