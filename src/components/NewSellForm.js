import React, { Component } from "react";

class NewSellForm extends Component {
  constructor(props) {
    super(props);
    this.state = {
      input: "0",
      output: "0",
      price: "1",
    };
  }

  render() {
    return (
      <>
        <form
          className="mb-3"
          onSubmit={(event) => {
            event.preventDefault();
            let quantity = this.state.input;
            let price = this.state.price;
            quantity = window.web3.utils.toWei(quantity, "Ether");
            price = window.web3.utils.toWei(price, "Ether");
            if (this.props.buyorsell === "buy") {
              console.log("BUY", price, quantity);
              this.props.placeBuyOrder(price, quantity);
            } else {
              console.log("SELL", price, quantity);
              this.props.placeSellOrder(price, quantity);
            }
          }}
        >
          <div>
            <label className="float-left">
              <b>Input</b>
            </label>
            <span className="float-right text-muted">
              CoolBalance:{" "}
              {window.web3.utils.fromWei(this.props.coolTokenBalance, "Ether")}
            </span>
            <span>{"  "}</span>
            <span className="float-right text-muted">
              SecondBalance:{" "}
              {window.web3.utils.fromWei(
                this.props.secondTokenBalance,
                "Ether"
              )}
            </span>
          </div>
          <div className="input-group mb-4">
            <div>SECOND Tokens you want to sell</div>
            <input
              type="text"
              onChange={(event) => {
                const etherAmount = event.target.value.toString();
                console.log(etherAmount);

                this.setState({
                  input: etherAmount,
                  output: etherAmount,
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
                  <b>Number of COOL you want</b>
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

          <button type="submit" className="btn btn-primary btn-block btn-lg">
            Swap
          </button>
        </form>
        <></>
      </>
    );
  }
}

export default NewSellForm;
