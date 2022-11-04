import React, { Component } from "react";

class NewSellForm extends Component {
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
    if (price % quantity != 0) {
      this.setState({ disable: true });
    } else {
      this.setState({ disable: false });
    }
  };

  cancelOrder = () => this.props.deleteSellOrders();

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
              ABalance:{" "}
              {window.web3.utils.fromWei(this.props.aTokenBalance, "Ether")}
            </span>
            <span>{"  "}</span>
            <span className="float-right text-muted">
              BBalance:{" "}
              {window.web3.utils.fromWei(this.props.bTokenBalance, "Ether")}
            </span>
          </div>
          <div className="input-group mb-4">
            <div>B Tokens you want to sell</div>
            <input
              type="text"
              onChange={(event) => {
                const etherAmount = event.target.value.toString();
                console.log("hererere", etherAmount);

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
                  <b>Number of A you want</b>
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

export default NewSellForm;
