const { assert } = require("chai");

//import the contracts first
const AToken = artifacts.require("AToken");
const BToken = artifacts.require("BToken");
const EthSwap = artifacts.require("EthSwap");
const TokenSwap = artifacts.require("TokenSwap");
const TokenSwapInv = artifacts.require("TokenSwapInv");

// library used for testing
require("chai")
  .use(require("chai-as-promised"))
  .should();

// make number of tokens more readable
function tokens(n) {
  return web3.utils.toWei(n, "ether");
}

contract("Cancelling Orders", ([investorA, investorB]) => {
  let a, b, ethSwap, tokenSwap, tokenSwapInv;

  // before testing starts
  before(async () => {
    a = await AToken.new();
    b = await BToken.new();
    ethSwap = await EthSwap.new(a.address, b.address);
    tokenSwap = await TokenSwap.new(a.address, b.address);
    tokenSwapInv = await TokenSwapInv.new(a.address, b.address);
    // Transfer all tokens to EthSwap (1 million)
    await a.transfer(ethSwap.address, tokens("1000000"));
    await b.transfer(ethSwap.address, tokens("10000000"));
  });

  // Deploy Token
  describe("Token deployment", async () => {
    it("contract has a and b name", async () => {
      const aName = await a.name();
      assert.equal(aName, "A Token");
      const bName = await b.name();
      assert.equal(bName, "B Token");
    });
  });

  // Deploy EthSwap

  describe("EthSwap deployment", async () => {
    it("contract has a Eth Swap name", async () => {
      const name = await ethSwap.name();
      assert.equal(name, "EthSwap Exchange");
    });

    it("contract has tokens a and b", async () => {
      let aBalance = await a.balanceOf(ethSwap.address);
      assert.equal(aBalance.toString(), tokens("1000000"));
      let bBalance = await b.balanceOf(ethSwap.address);
      assert.equal(bBalance.toString(), tokens("10000000"));
    });
  });

  // Deploy TokenSwap
  describe("TokenSwap deployment", async () => {
    it("contract has a Token Swap name", async () => {
      const name = await tokenSwap.name();
      assert.equal(name, "TokenSwap Exchange");
    });

    it("contract has tokens a and b", async () => {
      let aBalance = await a.balanceOf(tokenSwap.address);
      assert.equal(aBalance.toString(), tokens("0"));
      let bBalance = await b.balanceOf(tokenSwap.address);
      assert.equal(bBalance.toString(), tokens("0"));
    });
  });

  // Deploy TokenSwapInv
  describe("TokenSwapInv deployment", async () => {
    it("contract has a Token Swap name", async () => {
      const name = await tokenSwapInv.name();
      assert.equal(name, "TokenSwapInv Exchange");
    });

    it("contract has tokens a and b", async () => {
      let aBalance = await a.balanceOf(tokenSwapInv.address);
      assert.equal(aBalance.toString(), tokens("0"));
      let bBalance = await b.balanceOf(tokenSwapInv.address);
      assert.equal(bBalance.toString(), tokens("0"));
    });
  });

  describe("Cancel Order for atob", async () => {
    before(async () => {
      // Purchase tokens before each example
      await ethSwap.buyATokens({
        from: investorA,
        value: web3.utils.toWei("1", "ether"),
      });

      await a.approve(tokenSwap.address, tokens("1"), {
        from: investorA,
      });

      await tokenSwap.atob(tokens("1"), tokens("1"), {
        from: investorA,
      });

      await tokenSwap.deleteBuyOrders();
    });
    it("atob order is cancelled", async () => {
      // let aBalanceOfInvestorA = await a.balanceOf(investorA);
      let bBalanceOfInvestorA = await b.balanceOf(investorA);

      assert.equal(tokens("0"), bBalanceOfInvestorA.toString());
      // assert.equal(tokens("1000"), aBalanceOfInvestorA.toString());
    });
  });

  describe("Cancel Order for btoa", async () => {
    before(async () => {
      // Purchase tokens before each example
      await ethSwap.buyBTokens({
        from: investorB,
        value: web3.utils.toWei("1", "ether"),
      });

      await b.approve(tokenSwap.address, tokens("1"), {
        from: investorB,
      });

      await tokenSwap.btoa(tokens("1"), tokens("1"), {
        from: investorB,
      });

      await tokenSwap.deleteSellOrders();
    });
    it("btoa order is cancelled", async () => {
      let aBalanceOfInvestorB = await a.balanceOf(investorB);
      // let bBalanceOfInvestorB = await b.balanceOf(investorB);

      // assert.equal(tokens("1000"), bBalanceOfInvestorB.toString());
      assert.equal(tokens("0"), aBalanceOfInvestorB.toString());
    });
  });
});
