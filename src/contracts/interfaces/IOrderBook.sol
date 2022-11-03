// SPDX-License-Identifier: MIT


pragma solidity >=0.6.8;

interface IOrderBook {
    struct Order {
        address maker;
        uint256 amount;
    }

    struct NewOrder{
        address maker;
        uint256 amount;
        uint256 rate;
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
/////////////////////////////////////////////
    function atob (
        uint256 b,
        uint256 a
    ) external;
    function btoa (
        uint256 a,
        uint256 b
    ) external;
/////////////////////////////////////////////
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

    // BOB
    // sell buy rate
    // 10 5 2
    // 10 2 5
    // 10 10 1 

    // ALICE
    // sell buy rate
    // 5 10 0.5->2

    // 2 5 rate 10
    // 3 2 rate 6

    // limitorder
    // rate always a/b
    // Alice
    // A B
    // 10 5 2
    // 8  5 1.6
    // 9  5

    // highest buy rate >= seller rate : execute

    // Bob
    // B A
    // 5 9 1.8

    // outcome
    // Bob -5B +10A
    // Alice -10A+5B


    // lowest sell rate <= buyer rate: execute
    // Bob
    // B A
    // 10 5 0.5
    // 9  5 0.55
    // 8  5 0.62
    // Alice
    // A B 
    // 5 9 0.55
