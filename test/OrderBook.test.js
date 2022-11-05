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

contract("OrderBook", ([investorA, investorB]) => {
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

  //Buy token A
  describe("buyATokens()", async () => {
    before(async () => {
      // Purchase tokens before each example
      result = await ethSwap.buyATokens({
        from: investorA,
        value: web3.utils.toWei("1", "ether"),
      });
    });

    it("Allows User to buy token A using eth", async () => {
      // check if the investor has the token A
      let investorBalance = await a.balanceOf(investorA);
      assert.equal(investorBalance.toString(), tokens("1000"));

      //check if ethSwap reduce in Token A
      let ethSwapBalance;
      ethSwapBalance = await a.balanceOf(ethSwap.address);
      assert.equal(ethSwapBalance.toString(), tokens("999000"));
      ethSwapBalance = await web3.eth.getBalance(ethSwap.address);
      assert.equal(ethSwapBalance.toString(), web3.utils.toWei("1", "Ether"));
    });
  });

  //Sell token A
  describe("sellATokens()", async () => {
    let result;

    before(async () => {
      // Investor must approve tokens before the purchase
      await a.approve(ethSwap.address, tokens("1000"), {
        from: investorA,
      });
      // Investor sells tokens
      result = await ethSwap.sellATokens(tokens("1000"), {
        from: investorA,
      });
    });

    it("Allows user to Sell token A", async () => {
      // Investor should not have any A left
      let investorBalance = await a.balanceOf(investorA);
      assert.equal(investorBalance.toString(), tokens("0"));

      // Check ethSwap balance after purchase
      let ethSwapBalance;
      ethSwapBalance = await a.balanceOf(ethSwap.address);
      assert.equal(ethSwapBalance.toString(), tokens("1000000"));
      ethSwapBalance = await web3.eth.getBalance(ethSwap.address);
      assert.equal(ethSwapBalance.toString(), web3.utils.toWei("0", "Ether"));
    });
  });

  //Buy token B
  describe("buyBTokens()", async () => {
    before(async () => {
      // Purchase tokens before each example
      result = await ethSwap.buyBTokens({
        from: investorB,
        value: web3.utils.toWei("1", "ether"),
      });
    });

    it("Allows User to buy token B using eth", async () => {
      // check if the investor has the token A
      let investorBalance = await b.balanceOf(investorB);
      assert.equal(investorBalance.toString(), tokens("1000"));

      //check if ethSwap reduce in Token A
      let ethSwapBalance;
      ethSwapBalance = await b.balanceOf(ethSwap.address);
      assert.equal(ethSwapBalance.toString(), tokens("9999000"));
      ethSwapBalance = await web3.eth.getBalance(ethSwap.address);
      assert.equal(ethSwapBalance.toString(), web3.utils.toWei("1", "Ether"));
    });
  });

  //Sell token B
  describe("sellBTokens()", async () => {
    let result;

    before(async () => {
      // Investor must approve tokens before the purchase
      await b.approve(ethSwap.address, tokens("1000"), {
        from: investorB,
      });
      // Investor sells tokens
      result = await ethSwap.sellBTokens(tokens("1000"), {
        from: investorB,
      });
    });

    it("Allows user to Sell token B", async () => {
      // Investor should not have any A left
      let investorBalance = await b.balanceOf(investorA);
      assert.equal(investorBalance.toString(), tokens("0"));

      // Check ethSwap balance after purchase
      let ethSwapBalance;
      ethSwapBalance = await b.balanceOf(ethSwap.address);
      assert.equal(ethSwapBalance.toString(), tokens("10000000"));
      ethSwapBalance = await web3.eth.getBalance(ethSwap.address);
      assert.equal(ethSwapBalance.toString(), web3.utils.toWei("0", "Ether"));
    });
  });

  //Buy token B
  //   describe("buyBTokens()", async () => {
  //     before(async () => {
  //       // Purchase tokens before each example
  //       result = await ethSwap.buyBTokens({
  //         from: investorB,
  //         value: web3.utils.toWei("1", "ether"),
  //       });
  //       await ethSwap.buyATokens({
  //         from: investorA,
  //         value: web3.utils.toWei("1", "ether"),
  //       });
  //     });

  //     it("Allows User to buy token B using eth", async () => {
  //       // check if the investor has the token A
  //       let investorBalanceB = await b.balanceOf(investorB);
  //       assert.equal(investorBalanceB.toString(), tokens("1000"));

  //       let investorBalanceA = await a.balanceOf(investorA);
  //       assert.equal(investorBalanceA.toString(), tokens("1000"));
  //     });
  //   });

  //InvestorA do a atob(1,1) InvestorB do a btoa(1,1)

  describe("atob(1,1) then btoa(1,1)", async () => {
    before(async () => {
      // Purchase tokens before each example
      await ethSwap.buyATokens({
        from: investorA,
        value: web3.utils.toWei("1", "ether"),
      });

      await ethSwap.buyBTokens({
        from: investorB,
        value: web3.utils.toWei("1", "ether"),
      });

      await a.approve(tokenSwap.address, tokens("1"), {
        from: investorA,
      });

      await b.approve(tokenSwap.address, tokens("1"), {
        from: investorB,
      });

      await tokenSwap.atob(tokens("1"), tokens("1"), {
        from: investorA,
      });

      await tokenSwap.btoa(tokens("1"), tokens("1"), {
        from: investorB,
      });
    });

    it("Allows a 1A to 1B Swap", async () => {
      let aBalanceOfInvestorA = await a.balanceOf(investorA);
      let aBalanceOfInvestorB = await a.balanceOf(investorB);

      let bBalanceOfInvestorA = await b.balanceOf(investorA);
      let bBalanceOfInvestorB = await b.balanceOf(investorB);

      //investorB has 1 A
      assert.equal(tokens("1"), aBalanceOfInvestorB);
      assert.equal(tokens("999"), bBalanceOfInvestorB);
      //investorA has 1 B
      assert.equal(tokens("1"), bBalanceOfInvestorA);
      assert.equal(tokens("999"), aBalanceOfInvestorA);
    });
  });

  ///InvestorA do a btoa(1,1) InvestorB do a atob(1,1)

  describe("btoa(1,1) then atoa(1,1)", async () => {
    before(async () => {
      // Purchase tokens before each example

      await a.approve(tokenSwap.address, tokens("1"), {
        from: investorB,
      });

      await b.approve(tokenSwap.address, tokens("1"), {
        from: investorA,
      });

      await tokenSwap.btoa(tokens("1"), tokens("1"), {
        from: investorA,
      });

      await tokenSwap.atob(tokens("1"), tokens("1"), {
        from: investorB,
      });
    });

    it("Allows a 1A to 1B Swap", async () => {
      aBalanceOfInvestorA = await a.balanceOf(investorA);
      aBalanceOfInvestorB = await a.balanceOf(investorB);

      bBalanceOfInvestorA = await b.balanceOf(investorA);
      bBalanceOfInvestorB = await b.balanceOf(investorB);

      //investorB
      assert.equal(tokens("0"), aBalanceOfInvestorB);
      assert.equal(tokens("1000"), bBalanceOfInvestorB);

      //investorA
      assert.equal(tokens("0"), bBalanceOfInvestorA);
      assert.equal(tokens("1000"), aBalanceOfInvestorA);
    });
  });

  // At this moment Investor A has 1000A, Investor B has 1000B

  //Do a partial order of atob(10,5), btoa(1,2) and btoa(4,8)
  describe("atob(10,5) then btoa(1,2) partial order filled", async () => {
    before(async () => {
      await a.approve(tokenSwap.address, tokens("10"), {
        from: investorA,
      });
      //FRONTEND THIS IS 10/5
      await tokenSwap.atob(tokens("5"), tokens("10"), {
        from: investorA,
      });

      await b.approve(tokenSwap.address, tokens("1"), {
        from: investorB,
      });
      //FRONTEND THIS IS 1/2
      await tokenSwap.btoa(tokens("2"), tokens("1"), {
        from: investorB,
      });
    });

    it("Allows a partial order of 1B to 2A filled", async () => {
      let aBalanceOfInvestorA = await a.balanceOf(investorA);
      let aBalanceOfInvestorB = await a.balanceOf(investorB);

      let bBalanceOfInvestorA = await b.balanceOf(investorA);
      let bBalanceOfInvestorB = await b.balanceOf(investorB);

      //investorB
      assert.equal(tokens("2"), aBalanceOfInvestorB);
      assert.equal(tokens("999"), bBalanceOfInvestorB);
      //investorA
      assert.equal(tokens("1"), bBalanceOfInvestorA);
      assert.equal(tokens("990"), aBalanceOfInvestorA);
    });
  });

  //Completely fill the partial Order

  describe("atob(10,5) then btoa(1,2) now do btoa(4,8) order fully filled", async () => {
    before(async () => {
      await b.approve(tokenSwap.address, tokens("4"), {
        from: investorB,
      });
      //FRONTEND THIS IS 4/8
      await tokenSwap.btoa(tokens("8"), tokens("4"), {
        from: investorB,
      });
    });

    it("Allows a partial order of 1B to 2A filled", async () => {
      let aBalanceOfInvestorA = await a.balanceOf(investorA);
      let aBalanceOfInvestorB = await a.balanceOf(investorB);

      let bBalanceOfInvestorA = await b.balanceOf(investorA);
      let bBalanceOfInvestorB = await b.balanceOf(investorB);

      //investorB
      assert.equal(tokens("10"), aBalanceOfInvestorB);
      assert.equal(tokens("995"), bBalanceOfInvestorB);
      //investorA
      assert.equal(tokens("5"), bBalanceOfInvestorA);
      assert.equal(tokens("990"), aBalanceOfInvestorA);
    });
  });

  //at this moment Investor B (10A, 995B),  Investor A (990A, 5B)

  //conduct limit order for atob then btoa
  describe("limit order for atob(10,2) then btoa(2,5) all orders are filled with best rate", async () => {
    before(async () => {
      await a.approve(tokenSwap.address, tokens("10"), {
        from: investorA,
      });
      //FRONTEND THIS IS 10/2
      await tokenSwap.atob(tokens("2"), tokens("10"), {
        from: investorA,
      });

      await b.approve(tokenSwap.address, tokens("2"), {
        from: investorB,
      });
      //FRONTEND THIS IS 2/8
      await tokenSwap.btoa(tokens("8"), tokens("2"), {
        from: investorB,
      });
    });

    it("All the orders are filled", async () => {
      let aBalanceOfInvestorA = await a.balanceOf(investorA);
      let aBalanceOfInvestorB = await a.balanceOf(investorB);

      let bBalanceOfInvestorA = await b.balanceOf(investorA);
      let bBalanceOfInvestorB = await b.balanceOf(investorB);

      //investorB
      assert.equal(tokens("20"), aBalanceOfInvestorB.toString());
      assert.equal(tokens("993"), bBalanceOfInvestorB.toString());
      //investorA
      assert.equal(tokens("7"), bBalanceOfInvestorA.toString());
      assert.equal(tokens("980"), aBalanceOfInvestorA.toString());
    });
  });

  describe("limit order for atob(10,2) then btoa(4,8) all orders are partially filled with best rate", async () => {
    before(async () => {
      await a.approve(tokenSwap.address, tokens("10"), {
        from: investorA,
      });
      //FRONTEND THIS IS 10/2
      await tokenSwap.atob(tokens("2"), tokens("10"), {
        from: investorA,
      });

      await b.approve(tokenSwap.address, tokens("4"), {
        from: investorB,
      });
      //FRONTEND THIS IS 4/8
      await tokenSwap.btoa(tokens("8"), tokens("4"), {
        from: investorB,
      });
    });

    it("Orders are partially filled", async () => {
      let aBalanceOfInvestorA = await a.balanceOf(investorA);
      let aBalanceOfInvestorB = await a.balanceOf(investorB);

      let bBalanceOfInvestorA = await b.balanceOf(investorA);
      let bBalanceOfInvestorB = await b.balanceOf(investorB);

      //investorB
      assert.equal(tokens("30"), aBalanceOfInvestorB.toString());
      assert.equal(tokens("989"), bBalanceOfInvestorB.toString());
      //investorA
      assert.equal(tokens("9"), bBalanceOfInvestorA.toString());
      assert.equal(tokens("970"), aBalanceOfInvestorA.toString());
    });
  });

  describe("limit order for atob(10,2) then btoa(4,8) all orders are now fully filled with best rate", async () => {
    before(async () => {
      await a.approve(tokenSwap.address, tokens("4"), {
        from: investorA,
      });
      //FRONTEND THIS IS 4/2
      await tokenSwap.atob(tokens("2"), tokens("4"), {
        from: investorA,
      });
    });

    it("Orders are now fully filled", async () => {
      let aBalanceOfInvestorA = await a.balanceOf(investorA);
      let aBalanceOfInvestorB = await a.balanceOf(investorB);

      let bBalanceOfInvestorA = await b.balanceOf(investorA);
      let bBalanceOfInvestorB = await b.balanceOf(investorB);

      //investorB
      assert.equal(tokens("34"), aBalanceOfInvestorB.toString());
      assert.equal(tokens("989"), bBalanceOfInvestorB.toString());
      //investorA
      assert.equal(tokens("11"), bBalanceOfInvestorA.toString());
      assert.equal(tokens("966"), aBalanceOfInvestorA.toString());
    });
  });

  //do a inverse order atob(5,10) then btoa(10,5)
  describe("inverse order of atob(5,10) then btoa(10,5)", async () => {
    before(async () => {
      await a.approve(tokenSwapInv.address, tokens("5"), {
        from: investorA,
      });
      //FRONTEND THIS IS 5/10
      await tokenSwapInv.atobInverseRate(tokens("10"), tokens("5"), {
        from: investorA,
      });

      await b.approve(tokenSwapInv.address, tokens("10"), {
        from: investorB,
      });
      //FRONTEND THIS IS 10/5
      await tokenSwapInv.btoaInverseRate(tokens("5"), tokens("10"), {
        from: investorB,
      });
    });

    it("Orders for inversed are filled", async () => {
      let aBalanceOfInvestorA = await a.balanceOf(investorA);
      let aBalanceOfInvestorB = await a.balanceOf(investorB);

      let bBalanceOfInvestorA = await b.balanceOf(investorA);
      let bBalanceOfInvestorB = await b.balanceOf(investorB);

      //investorB
      assert.equal(tokens("39"), aBalanceOfInvestorB.toString());
      assert.equal(tokens("979"), bBalanceOfInvestorB.toString());
      //investorA
      assert.equal(tokens("21"), bBalanceOfInvestorA.toString());
      assert.equal(tokens("961"), aBalanceOfInvestorA.toString());
    });
  });
});
