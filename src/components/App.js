import React, { Component } from "react";
import Web3 from "web3"; // import web3
import CoolToken from "../abis/CoolToken.json";
import SecondToken from "../abis/SecondToken.json";
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

    // Load Token
    const networkId = await web3.eth.net.getId();
    const tokenData = CoolToken.networks[networkId];
    if (tokenData) {
      const token = new web3.eth.Contract(CoolToken.abi, tokenData.address);
      this.setState({ token });
      let coolTokenName = await token.methods.name.call();
      let coolTokenBalance = await token.methods
        .balanceOf(this.state.account)
        .call();
      this.setState({ coolTokenBalance: coolTokenBalance.toString() });
      this.setState({ coolTokenName: coolTokenName.toString() });
    } else {
      window.alert("Token contract not deployed to detected network.");
    }

    // Load EthSwap
    const ethSwapData = EthSwap.networks[networkId];
    if (ethSwapData) {
      const ethSwap = new web3.eth.Contract(EthSwap.abi, ethSwapData.address);
      this.setState({ ethSwap });
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

  buyCoolTokens = (etherAmount) => {
    this.setState({ loading: true });
    this.state.ethSwap.methods
      .buyCoolTokens()
      .send({ value: etherAmount, from: this.state.account })
      .on("transactionHash", (hash) => {
        this.setState({ loading: false });
      });
  };

  limitBuyCoolTokens = (rate, etherAmount) => {
    this.setState({ loading: true });
    try {
      this.state.ethSwap.methods
        .limitBuyCoolTokens(rate)
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

  sellCoolTokens = (tokenAmount) => {
    this.setState({ loading: true });
    this.state.token.methods
      .approve(this.state.ethSwap.address, tokenAmount)
      .send({ from: this.state.account })
      .on("transactionHash", (hash) => {
        this.state.ethSwap.methods
          .sellCoolTokens(tokenAmount)
          .send({ from: this.state.account })
          .on("transactionHash", (hash) => {
            this.setState({ loading: false });
          });
      });
  };

  limitSellCoolTokens = (rate, tokenAmount) => {
    this.setState({ loading: true });
    try {
      this.state.token.methods
        .approve(this.state.ethSwap.address, tokenAmount)
        .send({ from: this.state.account })
        .on("transactionHash", (hash) => {
          this.state.ethSwap.methods
            .limitSellCoolTokens(tokenAmount, rate)
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

  retryLimitOrder = () => {
    this.setState({ limitError: false });
    this.setState({ loading: false });
  };

  constructor(props) {
    super(props);
    this.state = {
      account: "",
      token: {},
      ethSwap: {},
      ethBalance: "0",
      coolTokenBalance: "0",
      loading: true,
      limitError: false,
    };
  }

  render() {
    let content;
    if (this.state.loading && this.state.limitError == false) {
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
        <Main
          coolTokenName={this.state.coolTokenName}
          ethBalance={this.state.ethBalance}
          coolTokenBalance={this.state.coolTokenBalance}
          buyCoolTokens={this.buyCoolTokens}
          sellCoolTokens={this.sellCoolTokens}
          limitBuyCoolTokens={this.limitBuyCoolTokens}
          limitSellCoolTokens={this.limitSellCoolTokens}
        />
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
