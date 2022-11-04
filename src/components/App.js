import React, { Component } from "react";
import Web3 from "web3"; // import web3
import AToken from "../abis/AToken.json";
import BToken from "../abis/BToken.json";
import TokenSwap from "../abis/TokenSwap.json";
import Navbar from "./Navbar";
import Main from "./Main";
import "./App.css";

class App extends Component {
  async componentWillMount() {
    await this.loadWeb3();
    await this.loadBlockchainData();
  }

  async loadBlockchainData() {
    const web3 = window.web3;

    const accounts = await web3.eth.getAccounts();
    this.setState({ account: accounts[0] });

    const ethBalance = await web3.eth.getBalance(this.state.account);
    this.setState({ ethBalance });

    /////////////////////// Load BToken balance name ///////////////////////
    const networkId = await web3.eth.net.getId();

    const bTokenData = BToken.networks[networkId];
    if (bTokenData) {
      const bToken = new web3.eth.Contract(BToken.abi, bTokenData.address);
      this.setState({ bToken });
      let bTokenName = await bToken.methods.symbol.call();
      let bTokenBalance = await bToken.methods
        .balanceOf(this.state.account)
        .call();
      this.setState({ bTokenBalance: bTokenBalance.toString() });
      this.setState({ bTokenName: bTokenName.toString() });
    } else {
      window.alert("Token contract not deployed to detected network.");
    }

    /////////////////////// Load AToken balance name ///////////////////////
    const tokenData = AToken.networks[networkId];
    if (tokenData) {
      const token = new web3.eth.Contract(AToken.abi, tokenData.address);
      this.setState({ token });
      let aTokenName = await token.methods.symbol.call();
      let aTokenBalance = await token.methods
        .balanceOf(this.state.account)
        .call();

      this.setState({ aTokenBalance: aTokenBalance.toString() });
      this.setState({ aTokenName: aTokenName.toString() });
    } else {
      window.alert("Token contract not deployed to detected network.");
    }

    /////////////////////// Load TokenSwap ///////////////////////
    const tokenSwapData = TokenSwap.networks[networkId];
    if (tokenSwapData) {
      const tokenSwap = new web3.eth.Contract(
        TokenSwap.abi,
        tokenSwapData.address
      );
      this.setState({ tokenSwap });
      let bTokenRate = await tokenSwap.methods.bRate.call();
      this.setState({ bTokenRate: bTokenRate.toString() });
      let aTokenRate = await tokenSwap.methods.aRate.call();
      this.setState({ aTokenRate: aTokenRate.toString() });
      let maxBuyPrice = await tokenSwap.methods.maxBuyPrice.call();
      this.setState({ maxBuyPrice: maxBuyPrice.toString() });
      let minSellPrice = await tokenSwap.methods.minSellPrice.call();
      this.setState({ minSellPrice: minSellPrice.toString() });

      let sellrateid = await tokenSwap.methods.getsellrate.call();
      let buyrateid = await tokenSwap.methods.getbuyrate.call();

      let getamountbuy = await tokenSwap.methods.getamountbuy.call();

      console.log("getamountbuy", getamountbuy);

      console.log("sellrateid", sellrateid);

      console.log("buyrateid", buyrateid);

      // let buyOrdersInStepCounter = await tokenSwap.methods.buyOrdersInStepCounter.call();

      // tokenSwap.methods.buyOrdersInStepCounter.call(0).then(function(tester) {
      //   console.log("tester", tester);
      // });

      // this.setState({
      //   buyOrdersInStepCounter: buyOrdersInStepCounter.toString(),
      // });

      // let buySteps = await tokenSwap.methods.buySteps.call();
      // this.setState({ buySteps: buySteps.toString() });
      // let buyOrdersInStepCounter = await tokenSwap.methods.buyOrdersInStepCounter.call();
      // this.setState({
      //   buyOrdersInStepCounter: buyOrdersInStepCounter.toString(),
      // });
    } else {
      window.alert("TokenSwap contract not deployed to detected network.");
    }

    this.setState({ loading: false });
  }

  async loadWeb3() {
    if (window.ethereum) {
      window.web3 = new Web3(window.ethereum);
      await window.ethereum.enable();
    } else if (window.web3) {
      window.web3 = new Web3(window.web3.currentProvider);
    } else {
      window.alert(
        "Non-Ethereum browser detected. You should consider trying MetaMask!"
      );
    }
  }

  /////////////////////// Order book placeBuyOrder TokenSwap ///////////////////////

  placeBuyOrder = (price, quantity) => {
    this.setState({ loading: true });

    this.state.token.methods
      .approve(this.state.tokenSwap.address, quantity)
      .send({ from: this.state.account })
      .on("transactionHash", (hash) => {
        this.state.tokenSwap.methods
          .atob(price, quantity)
          .send({ from: this.state.account })
          .on("transactionHash", (hash) => {
            this.setState({ loading: false });
          })
          .on("error", (err) => {
            console.log(err);
            this.setState({ limitError: true });
          });
      });
  };

  placeSellOrder = (price, quantity) => {
    this.setState({ loading: true });

    this.state.bToken.methods
      .approve(this.state.tokenSwap.address, quantity)
      .send({ from: this.state.account })
      .on("transactionHash", (hash) => {
        this.state.tokenSwap.methods
          .btoa(price, quantity)
          .send({ from: this.state.account })
          .on("transactionHash", (hash) => {
            this.setState({ loading: false });
          })
          .on("error", (err) => {
            console.log(err);
            this.setState({ limitError: true });
          });
      });
  };
  /////////////////////// bToken TokenSwap ///////////////////////

  buyBTokens = (etherAmount) => {
    this.setState({ loading: true });
    try {
      this.state.tokenSwap.methods
        .buyBTokens()
        .send({ value: etherAmount, from: this.state.account })
        .on("transactionHash", (hash) => {
          this.setState({ loading: false });
        })
        .on("error", (err) => {
          console.log("inside here", err);
          this.setState({ limitError: true });
        });
    } catch (err) {
      console.log("here is the errrr look heree", err);
      this.setState({ loading: false });
    }
  };

  sellBTokens = (tokenAmount) => {
    this.setState({ loading: true });
    this.state.token.methods
      .approve(this.state.tokenSwap.address, tokenAmount)
      .send({ from: this.state.account })
      .on("transactionHash", (hash) => {
        this.state.tokenSwap.methods
          .sellATokens(tokenAmount)
          .send({ from: this.state.account })
          .on("transactionHash", (hash) => {
            this.setState({ loading: false });
          });
      });
  };
  /////////////////////// aToken TokenSwap ///////////////////////

  buyATokens = (etherAmount) => {
    this.setState({ loading: true });
    this.state.tokenSwap.methods
      .buyATokens()
      .send({ value: etherAmount, from: this.state.account })
      .on("transactionHash", (hash) => {
        this.setState({ loading: false });
      });
  };

  limitBuyATokens = (rate, etherAmount) => {
    this.setState({ loading: true });
    try {
      this.state.tokenSwap.methods
        .limitBuyATokens(rate)
        .send({ value: etherAmount, from: this.state.account })
        .on("transactionHash", (hash) => {
          this.setState({ loading: false });
        })
        .on("error", (err) => {
          console.log("inside here", err);
          this.setState({ limitError: true });
        });
    } catch (err) {
      console.log("here is the errrr look heree", err);
      this.setState({ loading: false });
    }
  };

  sellATokens = (tokenAmount) => {
    this.setState({ loading: true });
    this.state.token.methods
      .approve(this.state.tokenSwap.address, tokenAmount)
      .send({ from: this.state.account })
      .on("transactionHash", (hash) => {
        this.state.tokenSwap.methods
          .sellATokens(tokenAmount)
          .send({ from: this.state.account })
          .on("transactionHash", (hash) => {
            this.setState({ loading: false });
          });
      });
  };

  limitSellATokens = (rate, tokenAmount) => {
    this.setState({ loading: true });
    try {
      this.state.token.methods
        .approve(this.state.tokenSwap.address, tokenAmount)
        .send({ from: this.state.account })
        .on("transactionHash", (hash) => {
          this.state.tokenSwap.methods
            .limitSellATokens(tokenAmount, rate)
            .send({ from: this.state.account })
            .on("transactionHash", (hash) => {
              this.setState({ loading: false });
            })
            .on("error", (err) => {
              console.log("inside here", err);
              this.setState({ limitError: true });
            });
        });
    } catch (err) {
      console.log("here is the errrr look heree", err);
      this.setState({ loading: false });
    }
  };

  //////////////////// Error handling /////////////////////////////
  retryLimitOrder = () => {
    this.setState({ limitError: false });
    this.setState({ loading: false });
  };

  constructor(props) {
    super(props);
    this.state = {
      account: "",
      token: {},
      tokenSwap: {},
      ethBalance: "0",
      aTokenBalance: "0",
      bTokenBalance: "0",
      loading: true,
      limitError: false,
    };
  }

  render() {
    let content;
    if (this.state.loading && this.state.limitError === false) {
      content = (
        <p id="loader" className="text-center">
          Loading...
        </p>
      );
    } else if (this.state.limitError) {
      content = (
        <div>
          <p className="text-center">Limit Order Failed</p>
          <button
            onClick={this.retryLimitOrder}
            className="btn btn-primary btn-block btn-lg"
          >
            Click to Retry again
          </button>
        </div>
      );
    } else {
      content = (
        <>
          <Main
            aTokenName={this.state.aTokenName}
            ethBalance={this.state.ethBalance}
            aTokenBalance={this.state.aTokenBalance}
            buyATokens={this.buyATokens}
            sellATokens={this.sellATokens}
            limitBuyATokens={this.limitBuyATokens}
            limitSellATokens={this.limitSellATokens}
            aTokenRate={this.state.aTokenRate}
            bTokenRate={this.state.bTokenRate}
            bTokenName={this.state.bTokenName}
            bTokenBalance={this.state.bTokenBalance}
            buyBTokens={this.buyBTokens}
            sellBTokens={this.sellBTokens}
            placeBuyOrder={this.placeBuyOrder}
            placeSellOrder={this.placeSellOrder}
            maxBuyPrice={this.state.maxBuyPrice}
            minSellPrice={this.state.minSellPrice}
            // buyOrdersInStep={this.state.buyOrdersInStep}
            // buySteps={this.state.buySteps}
            // buyOrdersInStepCounter={this.state.buyOrdersInStepCounter}
          />
        </>
      );
    }

    return (
      <div>
        <Navbar account={this.state.account} />
        <div className="mt-5 container-fluid">
          <div className="row">
            <main
              role="main"
              className="ml-auto mr-auto col-lg-12"
              style={{ maxWidth: "600px" }}
            >
              <div className="ml-auto mr-auto content">{content}</div>
            </main>
          </div>
        </div>
      </div>
    );
  }
}

export default App;
