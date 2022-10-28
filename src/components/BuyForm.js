import React, { Component } from "react";
import tokenLogo from "../token-logo.png";
import ethLogo from "../eth-logo.png";

class BuyForm extends Component {
  constructor(props) {
    super(props);
    this.state = {
      input: "0",
      output: "0",
      rate: "10",
    };
  }

  render() {
    return (
      <form
        className="mb-3"
        onSubmit={(event) => {
          event.preventDefault();
          let etherAmount;
          etherAmount = this.state.input.toString();

          const rate = 111; //parseInt(this.state.rate, 18);
          etherAmount = window.web3.utils.toWei(etherAmount, "Ether");

          if (this.props.isLimitOrder) {
            this.props.limitBuyCoolTokens(rate, etherAmount);
          } else {
            this.props.buyCoolTokens(etherAmount);
          }
          // window.location.reload();
        }}
      >
        <div>
          <label className="float-left">
            <b>Input</b>
          </label>
          <span className="float-right text-muted">
            Balance: {window.web3.utils.fromWei(this.props.ethBalance, "Ether")}
          </span>
        </div>
        <div className="input-group mb-4">
          <input
            type="text"
            onChange={(event) => {
              const etherAmount = event.target.value.toString();
              console.log(etherAmount);

              this.setState({
                input: etherAmount,
                output: etherAmount * 100,
              });
            }}
            ref={(input) => {
              this.input = input;
            }}
            className="form-control form-control-lg"
            placeholder="0"
            required
          />
          <div className="input-group-append">
            <div className="input-group-text">
              <img src={ethLogo} height="32" alt="" />
              &nbsp;&nbsp;&nbsp; ETH
            </div>
          </div>
        </div>
        <>
          {this.props.isLimitOrder && (
            <>
              {" "}
              <div>
                <label className="float-left">
                  <b>Rate</b>
                </label>
              </div>
              <div className="input-group mb-4">
                <input
                  type="text"
                  onChange={(e) => {
                    const newRate = e.target.value.toString();
                    console.log(newRate);
                    this.setState({
                      rate: newRate,
                    });
                  }}
                  ref={(rate) => {
                    this.rate = rate;
                  }}
                  className="form-control form-control-lg"
                  placeholder="10"
                />
              </div>
            </>
          )}
        </>

        <div>
          <label className="float-left">
            <b>Output</b>
          </label>
          <span className="float-right text-muted">
            Balance:{" "}
            {window.web3.utils.fromWei(this.props.tokenBalance, "Ether")}
          </span>
        </div>
        <div className="input-group mb-2">
          <input
            type="text"
            className="form-control form-control-lg"
            placeholder="0"
            value={this.state.output}
            disabled
          />
          <div className="input-group-append">
            <div className="input-group-text">
              <img src={tokenLogo} height="32" alt="" />
              &nbsp; DApp
            </div>
          </div>
        </div>
        <div className="mb-5">
          <span className="float-left text-muted">Exchange Rate</span>
          <span className="float-right text-muted">1 ETH = 100 DApp</span>
        </div>
        <button type="submit" className="btn btn-primary btn-block btn-lg">
          SWAP!
        </button>
      </form>
    );
  }
}

export default BuyForm;
