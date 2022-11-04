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
          aTokenName={this.props.aTokenName}
          ethBalance={this.props.ethBalance}
          aTokenBalance={this.props.aTokenBalance}
          buyATokens={this.props.buyATokens}
          isLimitOrder={this.state.limitOrder}
          limitBuyATokens={this.props.limitBuyATokens}
          aTokenRate={this.props.aTokenRate}
          bTokenName={this.props.bTokenName}
          bTokenRate={this.props.bTokenRate}
          bTokenBalance={this.props.bTokenBalance}
          buyBTokens={this.props.buyBTokens}
          sellBTokens={this.props.sellBTokens}
        />
      );
      buyButtonStyle = "btn-success";
    } else if (this.state.currentForm === "sell") {
      content = (
        <SellForm
          aTokenName={this.props.aTokenName}
          ethBalance={this.props.ethBalance}
          aTokenBalance={this.props.aTokenBalance}
          sellATokens={this.props.sellATokens}
          isLimitOrder={this.state.limitOrder}
          limitSellATokens={this.props.limitSellATokens}
          aTokenRate={this.props.aTokenRate}
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
            aTokenBalance={this.props.aTokenBalance}
            bTokenBalance={this.props.bTokenBalance}
          />

          <NewSellForm
            buyorsell="sell"
            placeBuyOrder={this.props.placeBuyOrder}
            placeSellOrder={this.props.placeSellOrder}
            aTokenBalance={this.props.aTokenBalance}
            bTokenBalance={this.props.bTokenBalance}
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
