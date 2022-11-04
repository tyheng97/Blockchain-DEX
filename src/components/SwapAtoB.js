import React, { Component } from "react";
import tokenLogo from "../token-logo.png";
import ethLogo from "../eth-logo.png";

class SwapAtoB extends Component {
  constructor(props) {
    super(props);
    this.state = {
      input: "0",
      output: "0",
      price: "1",
      disable: true,
    };
  }
  checkdisable = () => {
    let price = this.state.price;
    let quantity = this.state.input;
    if (quantity % price !== 0 && price % quantity !== 0) {
      this.setState({ disable: true });
    } else {
      this.setState({ disable: false });
    }
  };

  cancelOrder = () => this.props.deleteBuyOrders();

  render() {
    return (
      <>
        <form
          className="mb-3"
          onSubmit={(event) => {
            event.preventDefault();
            let quantity = this.state.input;
            quantity = window.web3.utils.toWei(quantity, "Ether");

            let price = this.state.price;
            price = window.web3.utils.toWei(price, "Ether");
            if (quantity / price >= 1) {
              this.props.placeBuyOrder(price, quantity);
            } else {
              this.props.placeBuyOrderInverse(price, quantity);
            }
          }}
        >
          <div>
            <label className="float-left">
              <b>Input</b>
            </label>

            <span className="float-right text-muted">
              {window.web3.utils.fromWei(this.props.aTokenBalance, "Ether")}
              {" A "}
            </span>
            <span className="float-right text-muted">Balance:</span>
          </div>
          <div className="input-group mb-4">
            <div>A Tokens you want to sell</div>
            <input
              type="text"
              onChange={(event) => {
                const etherAmount = event.target.value.toString();
                console.log(etherAmount);

                this.setState({
                  input: etherAmount,
                  output: etherAmount,
                  disable: true,
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
          <>
            <>
              <div>
                <label className="float-left">
                  <b>Number of B Tokens you want</b>
                </label>
              </div>
              <div className="input-group mb-4">
                <input
                  type="text"
                  onChange={(e) => {
                    const newprice = e.target.value.toString();
                    console.log(newprice);
                    this.setState({
                      price: newprice,
                      disable: true,
                    });
                  }}
                  ref={(price) => {
                    this.price = price;
                  }}
                  className="form-control form-control-lg"
                  placeholder="10"
                />
              </div>
            </>
          </>
          <button
            type="button"
            onClick={this.checkdisable}
            className="btn btn-primary btn-block btn-lg"
          >
            Check Rate
          </button>
          {!this.state.disable && (
            <button
              type="submit"
              disabled={this.state.disable}
              className="btn btn-primary btn-block btn-lg change"
            >
              Swap
            </button>
          )}
          <button
            type="button"
            onClick={this.cancelOrder}
            className="btn btn-primary btn-block btn-lg cancel"
          >
            Cancel Order
          </button>
        </form>
        <></>
      </>
    );
  }
}

export default SwapAtoB;