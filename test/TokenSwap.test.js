const { assert } = require("chai");

//import the contracts first
const AToken = artifacts.require("AToken");
const BToken = artifacts.require("BToken");
const EthSwap = artifacts.require("EthSwap");
const TokenSwap = artifacts.require("TokenSwap");

// library used for testing
require("chai")
  .use(require("chai-as-promised"))
  .should();

// make number of tokens more readable
function tokens(n) {
  return web3.utils.toWei(n, "ether");
}

contract("EthSwap", ([deployer, investor]) => {
  let a, b;

  // before testing starts
  before(async () => {
    a = await AToken.new();
    b = await BToken.new();
    ethSwap = await EthSwap.new(a.address, b.address);
    tokenSwap = await TokenSwap.new(a.address, b.address);
    // Transfer all tokens to EthSwap (1 million)
    await cooltoken.transfer(ethSwap.address, tokens("1000000"));
    await secondtoken.transfer(ethSwap.address, tokens("10000000"));
  });
});
