// Write tests before contract deployed on blockchain
// Tests written in js

const { assert } = require("chai");

//import the contracts first
const Token = artifacts.require("CoolToken");
const EthSwap = artifacts.require("EthSwap");
const SecondToken = artifacts.require("SecondToken");

// library used for testing
require("chai")
  .use(require("chai-as-promised"))
  .should();

// make number of tokens more readable
function tokens(n) {
  return web3.utils.toWei(n, "ether");
}

// test
contract("EthSwap", ([deployer, investor]) => {
  let cooltoken,
    ethSwap,
    secondtoken,
    coolTokenBought,
    coolTokenBalance,
    secondTokenBought,
    secondTokenBalance;

  // before testing starts
  before(async () => {
    cooltoken = await Token.new();
    secondtoken = await SecondToken.new();
    ethSwap = await EthSwap.new(cooltoken.address, secondtoken.address);
    // Transfer all tokens to EthSwap (1 million)
    await cooltoken.transfer(ethSwap.address, tokens("1000000"));
    await secondtoken.transfer(ethSwap.address, tokens("10000000"));
  });

  /////////////////////// Deploy Token /////////////////////////////////////////

  describe("Token deployment", async () => {
    it("contract has a name", async () => {
      const name = await cooltoken.name();
      assert.equal(name, "Cool Token");
      const secondName = await secondtoken.name();
      assert.equal(secondName, "Second Token");
    });
  });

  /////////////////////// Deploy EthSwap /////////////////////////////////////////

  describe("EthSwap deployment", async () => {
    it("contract has a name", async () => {
      const name = await ethSwap.name();
      assert.equal(name, "EthSwap Instant Exchange");
    });

    it("contract has tokens", async () => {
      let balance = await cooltoken.balanceOf(ethSwap.address);
      assert.equal(balance.toString(), tokens("1000000"));
      let secondBalance = await secondtoken.balanceOf(ethSwap.address);
      assert.equal(secondBalance.toString(), tokens("10000000"));
    });
  });

  /////////////////////// Buy Tokens /////////////////////////////////////////

  describe("buyCoolTokens()", async () => {
    let result;

    before(async () => {
      // Purchase tokens before each example
      result = await ethSwap.buyCoolTokens({
        from: investor,
        value: web3.utils.toWei("1", "ether"),
      });
    });

    it("Allows user to instantly purchase tokens from ethSwap for a fixed price", async () => {
      // Check investor token balance after purchase
      let investorBalance = await cooltoken.balanceOf(investor);
      assert.equal(investorBalance.toString(), tokens("100"));

      // Check ethSwap balance after purchase
      let ethSwapBalance;
      ethSwapBalance = await cooltoken.balanceOf(ethSwap.address);
      assert.equal(ethSwapBalance.toString(), tokens("999900"));
      ethSwapBalance = await web3.eth.getBalance(ethSwap.address);
      assert.equal(ethSwapBalance.toString(), web3.utils.toWei("1", "Ether"));

      // Check logs to ensure event was emitted with correct data
      const event = result.logs[0].args;
      assert.equal(event.account, investor);
      assert.equal(event.token, cooltoken.address);
      assert.equal(event.amount.toString(), tokens("100").toString());
      assert.equal(event.rate.toString(), "100");
    });
  });

  /////////////////////// Sell Tokens /////////////////////////////////////////

  describe("sellCoolTokens()", async () => {
    let result;

    before(async () => {
      // Investor must approve tokens before the purchase
      await cooltoken.approve(ethSwap.address, tokens("100"), {
        from: investor,
      });
      // Investor sells tokens
      result = await ethSwap.sellCoolTokens(tokens("100"), { from: investor });
    });

    it("Allows user to instantly sell tokens to ethSwap for a fixed price", async () => {
      // Check investor token balance after purchase
      let investorBalance = await cooltoken.balanceOf(investor);
      assert.equal(investorBalance.toString(), tokens("0"));

      // Check ethSwap balance after purchase
      let ethSwapBalance;
      ethSwapBalance = await cooltoken.balanceOf(ethSwap.address);
      assert.equal(ethSwapBalance.toString(), tokens("1000000"));
      ethSwapBalance = await web3.eth.getBalance(ethSwap.address);
      assert.equal(ethSwapBalance.toString(), web3.utils.toWei("0", "Ether"));

      // Check logs to ensure event was emitted with correct data
      const event = result.logs[0].args;
      assert.equal(event.account, investor);
      assert.equal(event.token, cooltoken.address);
      assert.equal(event.amount.toString(), tokens("100").toString());
      assert.equal(event.rate.toString(), "100");

      // FAILURE: investor can't sell more tokens than they have
      await ethSwap.sellCoolTokens(tokens("500"), { from: investor }).should.be
        .rejected;
    });
  });

  ////// Buy Limit Cool Tokens /////
  describe("limitBuyCoolTokens()", async () => {
    let result;

    before(async () => {
      // Purchase tokens before each example
      result = await ethSwap.limitBuyCoolTokens(80, {
        from: investor,
        value: web3.utils.toWei("1", "ether"),
        rate: 10,
      });
    });

    it("Allows user to instantly purchase tokens from ethSwap for a fixed price", async () => {
      // Check investor token balance after purchase
      coolTokenBought = await cooltoken.balanceOf(investor);

      // Check logs to ensure event was emitted with correct data
      const event = result.logs[0].args;
      assert.equal(event.account, investor);
      assert.equal(event.token, cooltoken.address);
      assert.equal(
        event.amount.toString(),
        tokens((event.rate * 1).toString())
      );

      assert.equal(
        coolTokenBought.toString(),
        tokens((event.rate * 1).toString())
      );

      // Check ethSwap balance after purchase
      let ethSwapBalance;
      ethSwapBalance = await cooltoken.balanceOf(ethSwap.address);
      coolTokenBalance = 1000000 - event.rate * 1;
      assert.equal(
        ethSwapBalance.toString(),
        tokens(coolTokenBalance.toString())
      );
      ethSwapBalance = await web3.eth.getBalance(ethSwap.address);
      assert.equal(ethSwapBalance.toString(), web3.utils.toWei("1", "Ether"));

      //should be rejected
      await ethSwap
        .limitBuyCoolTokens(101, {
          from: investor,
          value: web3.utils.toWei("1", "ether"),
        })
        .should.be.rejectedWith("fail");
    });
  });

  /////////////////////// Limit Sell Cool Tokens ///////////////////////////////////
  describe("limitSellCoolTokens()", async () => {
    let result;

    before(async () => {
      // Investor must approve tokens before the purchase
      await cooltoken.approve(ethSwap.address, coolTokenBought, {
        from: investor,
      });
      // Investor sells tokens
      result = await ethSwap.limitSellCoolTokens(coolTokenBought, 101, {
        from: investor,
      });
    });

    it("Allows user to instantly sell tokens to ethSwap for a fixed price", async () => {
      // Check investor token balance after purchase
      let investorBalance = await cooltoken.balanceOf(investor);
      const event = result.logs[0].args;
      assert.equal(event.account, investor);
      assert.equal(event.token, cooltoken.address);
      assert.equal(event.amount.toString(), coolTokenBought);
      assert.equal(investorBalance.toString(), tokens("0"));
      // Check ethSwap balance after purchase
      let ethSwapBalance;
      ethSwapBalance = await cooltoken.balanceOf(ethSwap.address);
      assert.equal(ethSwapBalance.toString(), tokens("1000000"));
      ethSwapBalance = await web3.eth.getBalance(ethSwap.address);
      assert.equal(ethSwapBalance.toString(), web3.utils.toWei("0", "Ether"));
      // FAILURE: investor can't sell more tokens than they have
      await ethSwap.limitSellCoolTokens(tokens("500"), 101, { from: investor })
        .should.be.rejected;
      // FAILURE: Limit Order did not go through
      await ethSwap
        .limitSellCoolTokens(tokens("500"), 80, { from: investor })
        .should.be.rejectedWith("fail");
    });
  });

  /////////////////////// Buy SecondTokens /////////////////////////////////////////

  describe("buySecondTokens()", async () => {
    let result;

    before(async () => {
      // buy 100 cool tokens
      await ethSwap.buyCoolTokens({
        from: investor,
        value: web3.utils.toWei("1", "ether"),
      });
      // Investor must approve cool tokens before the purchase
      await cooltoken.approve(ethSwap.address, tokens("100"), {
        from: investor,
      });
      // Investor buys second tokens using cool tokens
      result = await ethSwap.buySecondTokens(tokens("100"), {
        from: investor,
      });
    });

    it("Allows user to instantly purchase second tokens from ethSwap for a fixed cool token", async () => {
      // Check investor token balance after purchase
      let investorBalance = await secondtoken.balanceOf(investor);
      assert.equal(investorBalance.toString(), tokens("500"));
      // Check ethSwap balance after purchase
      let ethSwapBalance;
      ethSwapBalance = await secondtoken.balanceOf(ethSwap.address);
      assert.equal(ethSwapBalance.toString(), tokens("9999500"));
      ethSwapBalance = await cooltoken.balanceOf(ethSwap.address);
      assert.equal(ethSwapBalance.toString(), tokens("1000000"));
      // Check logs to ensure event was emitted with correct data
      const event = result.logs[0].args;
      assert.equal(event.account, investor);
      assert.equal(event.token, secondtoken.address);
      assert.equal(event.amount.toString(), tokens("500").toString());
      assert.equal(event.rate.toString(), "5");
    });
  });

  /////////////////////// Sell SecondTokens /////////////////////////////////////////

  describe("sellSecondTokens()", async () => {
    let result;

    before(async () => {
      // Investor must approve cool tokens before the purchase
      await secondtoken.approve(ethSwap.address, tokens("500"), {
        from: investor,
      });
      // Investor buys second tokens using cool tokens
      result = await ethSwap.sellSecondTokens(tokens("500"), {
        from: investor,
      });
    });

    it("Allows user to instantly sell second tokens from ethSwap for a fixed cool token", async () => {
      // Check investor token balance after purchase
      let investorBalance = await secondtoken.balanceOf(investor);
      assert.equal(investorBalance.toString(), tokens("0"));
      // Check ethSwap balance after purchase
      let ethSwapBalance;
      ethSwapBalance = await secondtoken.balanceOf(ethSwap.address);
      assert.equal(ethSwapBalance.toString(), tokens("10000000"));
      ethSwapBalance = await cooltoken.balanceOf(ethSwap.address);
      assert.equal(ethSwapBalance.toString(), tokens("999900"));
      // Check logs to ensure event was emitted with correct data
      const event = result.logs[0].args;
      assert.equal(event.account, investor);
      assert.equal(event.token, secondtoken.address);
      assert.equal(event.amount.toString(), tokens("500").toString());
      assert.equal(event.rate.toString(), "5");
    });
  });

  ///// Limit Buy Second Token //////

  describe("limitBuySecondTokens()", async () => {
    let result;

    before(async () => {
      // buy 100 cool tokens
      await ethSwap.buyCoolTokens({
        from: investor,
        value: web3.utils.toWei("1", "ether"),
      });
      // Investor must approve cool tokens before the purchase
      await cooltoken.approve(ethSwap.address, tokens("100"), {
        from: investor,
      });
      // Investor buys second tokens using cool tokens
      result = await ethSwap.limitBuySecondTokens(tokens("100"), 80, {
        from: investor,
      });
    });

    it("Allows user to instantly purchase second tokens from ethSwap for a fixed cool token", async () => {
      // Check investor token balance after purchase
      secondTokenBought = await secondtoken.balanceOf(investor);

      const event = result.logs[0].args;
      assert.equal(event.account, investor);
      assert.equal(event.token, secondtoken.address);
      assert.equal(
        event.amount.toString(),
        tokens((100 * event.rate).toString())
      );

      assert.equal(
        secondTokenBought.toString(),
        tokens((100 * event.rate).toString())
      );
      // Check ethSwap balance after purchase
      let ethSwapBalance;
      ethSwapBalance = await secondtoken.balanceOf(ethSwap.address);
      secondTokenBalance = 10000000 - event.rate * 100;
      assert.equal(
        ethSwapBalance.toString(),
        tokens((10000000 - 100 * event.rate).toString())
      );
      ethSwapBalance = await cooltoken.balanceOf(ethSwap.address);
      assert.equal(ethSwapBalance.toString(), tokens("999900"));
      // Check logs to ensure event was emitted with correct data

      //FAILURE: Limit order did not go through
      await ethSwap
        .limitBuySecondTokens(tokens("100"), 101, {
          from: investor,
        })
        .should.be.rejectedWith("fail");
    });
  });

  ////// Limit Sell Second Tokens /////////////

  describe("limitSellSecondTokens()", async () => {
    let result;

    before(async () => {
      // Investor must approve cool tokens before the purchase
      await secondtoken.approve(ethSwap.address, secondTokenBought, {
        from: investor,
      });
      // Investor buys second tokens using cool tokens
      result = await ethSwap.limitSellSecondTokens(secondTokenBought, 101, {
        from: investor,
      });
    });

    it("Allows user to instantly sell second tokens from ethSwap for a fixed cool token", async () => {
      // Check investor token balance after purchase
      let investorBalance = await secondtoken.balanceOf(investor);

      const event = result.logs[0].args;
      assert.equal(event.account, investor);
      assert.equal(event.token, secondtoken.address);
      assert.equal(event.amount.toString(), secondTokenBought);
      assert.equal(investorBalance.toString(), tokens("0"));
      // Check ethSwap balance after purchase
      let ethSwapBalance;
      ethSwapBalance = await secondtoken.balanceOf(ethSwap.address);
      assert.equal(ethSwapBalance.toString(), tokens("10000000"));
      ethSwapBalance = await cooltoken.balanceOf(ethSwap.address);
      assert.equal(
        ethSwapBalance.toString(),
        tokens(
          (
            999900 -
            web3.utils.fromWei(secondTokenBought) / event.rate
          ).toString()
        )
      );
      // Check logs to ensure event was emitted with correct data

      //FAILURE: Limit order did not go through

      await ethSwap
        .limitSellSecondTokens(tokens("500"), 70, {
          from: investor,
        })
        .should.be.rejectedWith("fail");
    });
  });
});
