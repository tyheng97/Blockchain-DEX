import React, { Component } from "react";
import BuyForm from "./BuyForm";
import NewSellForm from "./NewSellForm";
import NewBuyForm from "./NewBuyForm";

import SellForm from "./SellForm";

class Main extends Component {
  constructor(props) {
    super(props);
    this.state = {
      currentForm: "orderbook",
      limitOrder: false,
    };
  }

  render() {
    let buttonStyle = "btn-light";
    let buyButtonStyle = "btn-light";
    let sellButtonStyle = "btn-light";
    let orderBookButtonStyle = "btn-light";

    if (this.state.limitOrder) {
      buttonStyle = "btn-success";
    }

    if (this.state.currentForm === "orderbook") {
      orderBookButtonStyle = "btn-success";
    }

    let content;
    if (this.state.currentForm === "buy") {
      content = (
        <BuyForm
          coolTokenName={this.props.coolTokenName}
          ethBalance={this.props.ethBalance}
          coolTokenBalance={this.props.coolTokenBalance}
          buyCoolTokens={this.props.buyCoolTokens}
          isLimitOrder={this.state.limitOrder}
          limitBuyCoolTokens={this.props.limitBuyCoolTokens}
          coolTokenRate={this.props.coolTokenRate}
          secondTokenName={this.props.secondTokenName}
          secondTokenRate={this.props.secondTokenRate}
          secondTokenBalance={this.props.secondTokenBalance}
          buySecondTokens={this.props.buySecondTokens}
          sellSecondTokens={this.props.sellSecondTokens}
        />
      );
      buyButtonStyle = "btn-success";
    } else if (this.state.currentForm === "sell") {
      content = (
        <SellForm
          coolTokenName={this.props.coolTokenName}
          ethBalance={this.props.ethBalance}
          coolTokenBalance={this.props.coolTokenBalance}
          sellCoolTokens={this.props.sellCoolTokens}
          isLimitOrder={this.state.limitOrder}
          limitSellCoolTokens={this.props.limitSellCoolTokens}
          coolTokenRate={this.props.coolTokenRate}
        />
      );
      sellButtonStyle = "btn-success";
    } else {
      content = (
        <div>
          <NewBuyForm
            buyorsell="buy"
            placeBuyOrder={this.props.placeBuyOrder}
            placeSellOrder={this.props.placeSellOrder}
            coolTokenBalance={this.props.coolTokenBalance}
            secondTokenBalance={this.props.secondTokenBalance}
          />

          <NewSellForm
            buyorsell="sell"
            placeBuyOrder={this.props.placeBuyOrder}
            placeSellOrder={this.props.placeSellOrder}
            coolTokenBalance={this.props.coolTokenBalance}
            secondTokenBalance={this.props.secondTokenBalance}
          />
        </div>
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
            className={`btn ${orderBookButtonStyle}`}
            onClick={(event) => {
              this.setState({ currentForm: "orderbook" });
            }}
          >
            Orderbook
          </button>
          <button
            className={`btn ${sellButtonStyle}`}
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
