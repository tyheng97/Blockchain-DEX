import React, { Component } from "react";
import BuyA from "./BuyA";
import BuyB from "./BuyB";

import NewSellForm from "./NewSellForm";
import NewBuyForm from "./NewBuyForm";

import SellA from "./SellA";
import SellB from "./SellB";

class Main extends Component {
  constructor(props) {
    super(props);
    this.state = {
      currentForm: "orderbook",
    };
  }

  render() {
    let buyButtonStyle = "btn-light";
    let sellButtonStyle = "btn-light";
    let orderBookButtonStyle = "btn-light";

    if (this.state.currentForm === "orderbook") {
      orderBookButtonStyle = "btn-success";
    }

    let content;
    if (this.state.currentForm === "buy") {
      content = (
        <>
          <BuyA
            ethBalance={this.props.ethBalance}
            aTokenName={this.props.aTokenName}
            aTokenBalance={this.props.aTokenBalance}
            buyATokens={this.props.buyATokens}
            aTokenRate={this.props.aTokenRate}
          />
          <BuyB
            ethBalance={this.props.ethBalance}
            bTokenName={this.props.bTokenName}
            bTokenBalance={this.props.bTokenBalance}
            buyBTokens={this.props.buyBTokens}
            bTokenRate={this.props.bTokenRate}
          />
        </>
      );
      buyButtonStyle = "btn-success";
    } else if (this.state.currentForm === "sell") {
      content = (
        <>
          <SellA
            aTokenName={this.props.aTokenName}
            ethBalance={this.props.ethBalance}
            aTokenBalance={this.props.aTokenBalance}
            sellATokens={this.props.sellATokens}
            aTokenRate={this.props.aTokenRate}
          />
          <SellB
            bTokenName={this.props.bTokenName}
            ethBalance={this.props.ethBalance}
            bTokenBalance={this.props.bTokenBalance}
            sellBTokens={this.props.sellBTokens}
            bTokenRate={this.props.bTokenRate}
          />
        </>
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
