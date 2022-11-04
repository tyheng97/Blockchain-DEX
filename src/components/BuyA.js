import React, { Component } from "react";
import tokenLogo from "../AToken.png";
import ethLogo from "../eth-logo.png";

class BuyA extends Component {
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
      <>
        <form
          className="mb-3"
          onSubmit={(event) => {
            event.preventDefault();
            let etherAmount;
            etherAmount = this.state.input.toString();
            etherAmount = window.web3.utils.toWei(etherAmount, "Ether");

            this.props.buyATokens(etherAmount);
          }}
        >
          <div>
            <label className="float-left">
              <b>Input</b>
            </label>
            <span className="float-right text-muted">
              ETH Balance:{" "}
              {window.web3.utils.fromWei(this.props.ethBalance, "Ether")}
            </span>
          </div>
          <div className="input-group mb-4">
            <div className="input-group-append">
              <div className="input-group-text">
                <img src={ethLogo} height="32" alt="" />
                &nbsp;&nbsp;&nbsp; ETH
              </div>
            </div>
            <input
              type="text"
              onChange={(event) => {
                const etherAmount = event.target.value.toString();
                console.log(etherAmount);

                this.setState({
                  input: etherAmount,
                  output: etherAmount * this.props.aTokenRate,
                });
              }}
              ref={(input) => {
                this.input = input;
              }}
              className="form-control form-control-lg"
              placeholder="0"
              required
            />
          </div>

          <div>
            <label className="float-left">
              <b>Output</b>
            </label>
            <span className="float-right text-muted">
              {" " + this.props.aTokenName + " "}
              Balance:{" "}
              {window.web3.utils.fromWei(this.props.aTokenBalance, "Ether")}
            </span>
          </div>
          <div className="input-group mb-2">
            <div className="input-group-text">
              <img src={tokenLogo} height="32" alt="" />
              &nbsp; {this.props.aTokenName}
            </div>

            <input
              type="text"
              className="form-control form-control-lg"
              placeholder="0"
              value={this.state.output}
              disabled
            />
          </div>

          <button type="submit" className="btn btn-primary btn-block btn-lg">
            Swap
          </button>
        </form>
        <></>
      </>
    );
  }
}

export default BuyA;
