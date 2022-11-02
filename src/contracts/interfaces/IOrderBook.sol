// SPDX-License-Identifier: MIT


pragma solidity >=0.6.8;

interface IOrderBook {
    struct Order {
        address maker;
        uint256 amount;
    }

    struct Step {
        uint256 higherPrice;
        uint256 lowerPrice;
        uint256 amount;
    }

    function placeBuyOrder (
        uint256 price,
        uint256 amountOfBaseToken,
        uint256 amount
    ) external; 

    function placeSellOrder (
        uint256 price,
        uint256 amountOfTradeToken,
        uint256 amount

    ) external;

    event PlaceBuyOrder(address sender, uint256 price, uint256 amountOfBaseToken);
    event PlaceSellOrder(address sender, uint256 price, uint256 amountOfTradeToken);
    event DrawToBuyBook(address sender, uint256 price, uint256 amountOfBaseToken);
    event DrawToSellBook(address sender, uint256 price, uint256 amountOfTradeToken);

}