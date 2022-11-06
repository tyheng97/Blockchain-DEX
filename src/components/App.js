import React, { Component } from "react";
import Web3 from "web3"; // import web3
import AToken from "../abis/AToken.json";
import BToken from "../abis/BToken.json";
import TokenSwap from "../abis/TokenSwap.json";
import TokenSwapInv from "../abis/TokenSwapInv.json";

import EthSwap from "../abis/EthSwap.json";

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
      let sellrateid = await tokenSwap.methods.getsellrate.call();
      let buyrateid = await tokenSwap.methods.getbuyrate.call();

      console.log("sellrateid", sellrateid);
      console.log("buyrateid", buyrateid);

      let buyBook = [];
      let getBuyOrderBook = await tokenSwap.methods
        .getBuyOrderBook(this.state.account)
        .call();
      getBuyOrderBook.forEach((element) => {
        element = window.web3.utils.fromWei(element.toString());
        buyBook.push(element);
      });
      console.log("buy orders", buyBook);
      this.setState({ buyBook: buyBook });
      console.log("buy orders state", this.state.buyBook);

      let sellBook = [];
      let getSellOrderBook = await tokenSwap.methods
        .getSellOrderBook(this.state.account)
        .call();
      getSellOrderBook.forEach((element) => {
        element = window.web3.utils.fromWei(element.toString());
        sellBook.push(element);
      });
      console.log("sell orders", sellBook);
      this.setState({ sellBook: sellBook });
      console.log("sell orders state", this.state.sellBook);
    } else {
      window.alert("TokenSwap contract not deployed to detected network.");
    }
    ////////////////////////////////////////////////
    const tokenSwapInvData = TokenSwapInv.networks[networkId];
    if (tokenSwapInvData) {
      const tokenSwapInv = new web3.eth.Contract(
        TokenSwapInv.abi,
        tokenSwapInvData.address
      );
      this.setState({ tokenSwapInv });

      let sellrateidInv = await tokenSwapInv.methods.getsellrateInv.call();
      let buyrateidInv = await tokenSwapInv.methods.getbuyrateInv.call();

      console.log("INVsellrateid", sellrateidInv);
      console.log("INVbuyrateid", buyrateidInv);

      let buyBookInv = [];

      let getBuyOrderBookInv = await tokenSwapInv.methods
        .getBuyOrderBook(this.state.account)
        .call();
      getBuyOrderBookInv.forEach((element) => {
        element = window.web3.utils.fromWei(element.toString());
        buyBookInv.push(element);
      });
      console.log("buy ordersInv", buyBookInv);
      this.setState({ buyBookInv: buyBookInv });
      console.log("buy orders stateInv", this.state.buyBookInv);

      let sellBookInv = [];
      let getSellOrderBookInv = await tokenSwapInv.methods
        .getSellOrderBook(this.state.account)
        .call();
      getSellOrderBookInv.forEach((element) => {
        element = window.web3.utils.fromWei(element.toString());
        sellBookInv.push(element);
      });
      console.log("sell ordersInv", sellBookInv);
      this.setState({ sellBookInv: sellBookInv });
      console.log("sell orders stateInv", this.state.sellBookInv);
    } else {
      window.alert("TokenSwap contract not deployed to detected network.");
    }

    /////////////////////// Load EthSwap ///////////////////////
    const ethSwapData = EthSwap.networks[networkId];
    if (tokenSwapData) {
      const ethSwap = new web3.eth.Contract(EthSwap.abi, ethSwapData.address);
      this.setState({ ethSwap });
      let bTokenRate = await ethSwap.methods.bRate.call();
      this.setState({ bTokenRate: bTokenRate.toString() });
      let aTokenRate = await ethSwap.methods.aRate.call();
      this.setState({ aTokenRate: aTokenRate.toString() });
    } else {
      window.alert("EthSwap contract not deployed to detected network.");
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

  /////////////////////// Order book TokenSwap ///////////////////////

  placeBuyOrder = (price, quantity) => {
    this.setState({ loading: true });
    try {
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
              console.log("placeBuyOrder", err);
              this.setState({ FailError: true });
            });
        });
    } catch (err) {
      console.log("placeBuyOrder", err);
      this.setState({ FailError: true });
    }
  };
  placeBuyOrderInverse = (price, quantity) => {
    this.setState({ loading: true });
    try {
      this.state.token.methods
        .approve(this.state.tokenSwapInv.address, quantity)
        .send({ from: this.state.account })
        .on("transactionHash", (hash) => {
          this.state.tokenSwapInv.methods
            .atobInverseRate(price, quantity)
            .send({ from: this.state.account })
            .on("transactionHash", (hash) => {
              this.setState({ loading: false });
            })
            .on("error", (err) => {
              console.log("placeBuyOrderInverse", err);
              this.setState({ FailError: true });
            });
        });
    } catch (err) {
      console.log("placeBuyOrderInverse", err);
      this.setState({ FailError: true });
    }
  };

  placeSellOrder = (price, quantity) => {
    this.setState({ loading: true });
    try {
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
              console.log("placeSellOrder", err);
              this.setState({ FailError: true });
            });
        });
    } catch (err) {
      console.log("placeSellOrder", err);
      this.setState({ FailError: true });
    }
  };

  placeSellOrderInverse = (price, quantity) => {
    this.setState({ loading: true });
    try {
      this.state.bToken.methods
        .approve(this.state.tokenSwapInv.address, quantity)
        .send({ from: this.state.account })
        .on("transactionHash", (hash) => {
          this.state.tokenSwapInv.methods
            .btoaInverseRate(price, quantity)
            .send({ from: this.state.account })
            .on("transactionHash", (hash) => {
              this.setState({ loading: false });
            })
            .on("error", (err) => {
              console.log("placeSellOrderInverse", err);
              this.setState({ FailError: true });
            });
        });
    } catch (err) {
      console.log("placeSellOrderInverse", err);
      this.setState({ FailError: true });
    }
  };

  /////////////////////// bToken TokenSwap ///////////////////////

  buyBTokens = (etherAmount) => {
    this.setState({ loading: true });
    try {
      this.state.ethSwap.methods
        .buyBTokens()
        .send({ value: etherAmount, from: this.state.account })
        .on("transactionHash", (hash) => {
          this.setState({ loading: false });
        })
        .on("error", (err) => {
          console.log("inside here", err);
          this.setState({ FailError: true });
        });
    } catch (err) {
      console.log("buyBTokens", err);
      this.setState({ FailError: true });
    }
  };

  sellBTokens = (tokenAmount) => {
    this.setState({ loading: true });
    try {
      this.state.bToken.methods
        .approve(this.state.ethSwap.address, tokenAmount)
        .send({ from: this.state.account })
        .on("transactionHash", (hash) => {
          this.state.ethSwap.methods
            .sellBTokens(tokenAmount)
            .send({ from: this.state.account })
            .on("transactionHash", (hash) => {
              this.setState({ loading: false });
            });
        });
    } catch (err) {
      console.log("sellBTokens", err);
      this.setState({ FailError: true });
    }
  };
  /////////////////////// aToken TokenSwap ///////////////////////

  buyATokens = (etherAmount) => {
    this.setState({ loading: true });
    try {
      this.state.ethSwap.methods
        .buyATokens()
        .send({ value: etherAmount, from: this.state.account })
        .on("transactionHash", (hash) => {
          this.setState({ loading: false });
        });
    } catch (err) {
      console.log("sellBTokens", err);
      this.setState({ FailError: true });
    }
  };

  sellATokens = (tokenAmount) => {
    this.setState({ loading: true });
    try {
      this.state.token.methods
        .approve(this.state.ethSwap.address, tokenAmount)
        .send({ from: this.state.account })
        .on("transactionHash", (hash) => {
          this.state.ethSwap.methods
            .sellATokens(tokenAmount)
            .send({ from: this.state.account })
            .on("transactionHash", (hash) => {
              this.setState({ loading: false });
            });
        });
    } catch (err) {
      console.log("sellBTokens", err);
      this.setState({ FailError: true });
    }
  };

  /////////////////////// Delete Orders that were unfulfilled ///////////////////////

  deleteBuyOrders = () => {
    this.setState({ loading: true });
    try {
      this.state.tokenSwap.methods
        .deleteBuyOrders()
        .send({ from: this.state.account })
        .on("transactionHash", (hash) => {
          this.setState({ loading: false });
        })
        .on("error", (err) => {
          console.log("deleteBuyOrders", err);
          this.setState({ FailError: true });
        });
      this.state.tokenSwapInv.methods
        .deleteBuyOrders()
        .send({ from: this.state.account })
        .on("transactionHash", (hash) => {
          this.setState({ loading: false });
        })
        .on("error", (err) => {
          console.log("deleteBuyOrders", err);
          this.setState({ FailError: true });
        });
    } catch (err) {
      console.log("deleteBuyOrders", err);
      this.setState({ loading: true });
    }
  };

  deleteSellOrders = () => {
    this.setState({ loading: true });
    try {
      this.state.tokenSwap.methods
        .deleteSellOrders()
        .send({ from: this.state.account })
        .on("transactionHash", (hash) => {
          this.setState({ loading: false });
        })
        .on("error", (err) => {
          console.log("deleteSellOrders", err);
          this.setState({ FailError: true });
        });
      this.state.tokenSwapInv.methods
        .deleteSellOrders()
        .send({ from: this.state.account })
        .on("transactionHash", (hash) => {
          this.setState({ loading: false });
        })
        .on("error", (err) => {
          console.log("deleteSellOrders", err);
          this.setState({ FailError: true });
        });
    } catch (err) {
      console.log("deleteSellOrders", err);
      this.setState({ loading: true });
    }
  };

  //////////////////// Error handling /////////////////////////////
  retryFailOrder = () => {
    this.setState({ FailError: false });
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
      FailError: false,
      buyBook: [],
      buyBookInv: [],
      sellBook: [],
      sellBookInv: [],
    };
  }

  render() {
    let content;
    if (this.state.loading && this.state.FailError === false) {
      content = (
        <p id="loader" className="text-center">
          Loading...
        </p>
      );
    } else if (this.state.FailError) {
      content = (
        <div>
          <p className="text-center">
            You rejected the request on MetaMask or an error has occurred
          </p>
          <button
            onClick={this.retryFailOrder}
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
            aTokenRate={this.state.aTokenRate}
            bTokenRate={this.state.bTokenRate}
            bTokenName={this.state.bTokenName}
            bTokenBalance={this.state.bTokenBalance}
            buyBTokens={this.buyBTokens}
            sellBTokens={this.sellBTokens}
            placeBuyOrder={this.placeBuyOrder}
            placeBuyOrderInverse={this.placeBuyOrderInverse}
            placeSellOrder={this.placeSellOrder}
            placeSellOrderInverse={this.placeSellOrderInverse}
            maxBuyPrice={this.state.maxBuyPrice}
            minSellPrice={this.state.minSellPrice}
            deleteSellOrders={this.deleteSellOrders}
            deleteBuyOrders={this.deleteBuyOrders}
            sellBook={this.state.sellBook}
            buyBook={this.state.buyBook}
            sellBookInv={this.state.sellBookInv}
            buyBookInv={this.state.buyBookInv}
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
