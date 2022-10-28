import React, { Component } from "react";
import BuyForm from "./BuyForm";
import SellForm from "./SellForm";

class Main extends Component {
  constructor(props) {
    super(props);
    this.state = {
      currentForm: "buy",
      limitOrder: false,
    };
  }

  render() {
    let buttonStyle = "btn-light";
    let buyButtonStyle = "btn-light";

    if (this.state.limitOrder) {
      buttonStyle = "btn-success";
    }

    let content;
    if (this.state.currentForm === "buy") {
      content = (
        <BuyForm
          ethBalance={this.props.ethBalance}
          tokenBalance={this.props.tokenBalance}
          buyCoolTokens={this.props.buyCoolTokens}
          isLimitOrder={this.state.limitOrder}
          limitBuyCoolTokens={this.props.limitBuyCoolTokens}
        />
      );
      buyButtonStyle = "btn-success";
    } else {
      content = (
        <SellForm
          ethBalance={this.props.ethBalance}
          tokenBalance={this.props.tokenBalance}
          sellCoolTokens={this.props.sellCoolTokens}
        />
      );
    }

    return (
      <div id="content" className="mt-3">
        <div className="d-flex justify-content-between mb-3">
          <button
            className={`btn ${buyButtonStyle}`}
            onClick={(event) => {
              this.setState({ currentForm: "buy" });
            }}
          >
            Buy
          </button>

          <button
            className={`btn ${buttonStyle}`}
            onClick={(event) => {
              this.setState({ limitOrder: !this.state.limitOrder });
            }}
          >
            Limit Order
          </button>

          <button
            className="btn btn-light"
            onClick={(event) => {
              this.setState({ currentForm: "sell" });
            }}
          >
            Sell
          </button>
        </div>

        <div className="card mb-4">
          <div className="card-body">{content}</div>
        </div>
      </div>
    );
  }
}

export default Main;
