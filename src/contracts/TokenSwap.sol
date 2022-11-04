pragma solidity >=0.6.8;

import "./AToken.sol";
import "./BToken.sol";
import {IOrderBook} from "./interfaces/IOrderBook.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {SafeMath} from "@openzeppelin/contracts/math/SafeMath.sol";
import {Math} from "@openzeppelin/contracts/math/Math.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenSwap is IOrderBook, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeMath for uint8;
    using Math for uint256;
    using SafeERC20 for IERC20;
    IERC20 public tradeToken;
    IERC20 public baseToken;

    string public name = "TokenSwap Instant Exchange";
    AToken public aToken;
    uint256 public aRate = 1000;
    BToken public bToken;
    uint256 public bRate = 1000;

    ///////////////////////////
    //mapping is a hashtable
    mapping(uint256 => mapping(uint8 => Order)) public buyOrdersInStep;
    mapping(uint256 => Step) public buySteps;
    mapping(uint256 => uint8) public buyOrdersInStepCounter;
    uint256 public maxBuyPrice;

    mapping(uint256 => mapping(uint8 => Order)) public sellOrdersInStep;
    mapping(uint256 => Step) public sellSteps;
    mapping(uint256 => uint8) public sellOrdersInStepCounter;
    uint256 public minSellPrice;
    ////////////////////////////

    uint256 public buyCounter = 0;
    uint256 public minSellRate;
    mapping(uint256 => NewOrder) public newBuyOrderBook;
    uint256 public idOfBuyRate;

    uint256 public sellCounter = 0;
    mapping(uint256 => NewOrder) public newSellOrderBook;
    uint256 public idOfSellRate;
    uint256 public maxBuyRate;
    uint256 public selltx = 0;
    //////////////
    event TokensPurchased(
        address account,
        address token,
        uint256 amount,
        uint256 rate
    );

    event BTokensPurchased(
        address account,
        address token,
        uint256 amount,
        uint256 rate
    );

    event TokensSold(
        address account,
        address token,
        uint256 amount,
        uint256 rate
    );

    event BTokensSold(
        address account,
        address token,
        uint256 amount,
        uint256 rate
    );

    constructor(AToken _aToken, BToken _bToken) public {
        //pass the address of the Token in
        aToken = _aToken;
        bToken = _bToken;
    }

    function random() internal returns (uint256) {
        uint256 randomnumber = uint256(
            keccak256(
                abi.encodePacked(block.timestamp, msg.sender, block.timestamp)
            )
        ) % 10;
        randomnumber = randomnumber + 90;
        return randomnumber;
    }

    function buyATokens() public payable {
        // Calculate the number of tokens to buy
        uint256 tokenAmount = msg.value * aRate; //msg.value = how much ether was sent

        // Require that TokenSwap has enough tokens
        require(aToken.balanceOf(address(this)) >= tokenAmount);

        // Transfer tokens to the user
        aToken.transfer(msg.sender, tokenAmount);

        // Emit an event
        emit TokensPurchased(msg.sender, address(aToken), tokenAmount, aRate);
    }

 

    function sellATokens(uint256 _amount) public {
        // User can't sell more tokens than they have
        require(aToken.balanceOf(msg.sender) >= _amount);

        // Calculate the amount of Ether to redeem
        uint256 etherAmount = _amount / aRate;

        // Require that TokenSwap has enough Ether
        require(address(this).balance >= etherAmount);

        // Perform sale
        aToken.transferFrom(msg.sender, address(this), _amount);
        msg.sender.transfer(etherAmount);

        // Emit an event
        emit TokensSold(msg.sender, address(aToken), _amount, aRate);
    }

  

    function buyBTokens() public payable {
        // Calculate the number of tokens to buy
        uint256 tokenAmount = msg.value * bRate; //msg.value = how much ether was sent

        // Require that TokenSwap has enough tokens
        require(bToken.balanceOf(address(this)) >= tokenAmount);

        // Transfer tokens to the user
        bToken.transfer(msg.sender, tokenAmount);

        // Emit an event
        emit TokensPurchased(msg.sender, address(bToken), tokenAmount, bRate);
    }

    function sellBTokens(uint256 _amount) public {
        // User can't sell more tokens than they have
        require(bToken.balanceOf(msg.sender) >= _amount);

        // Calculate the amount of Ether to redeem
        uint256 etherAmount = _amount / bRate;

        // Require that TokenSwap has enough Ether
        require(address(this).balance >= etherAmount);

        // Perform sale
        bToken.transferFrom(msg.sender, address(this), _amount);
        msg.sender.transfer(etherAmount);

        // Emit an event
        emit TokensSold(msg.sender, address(bToken), _amount, bRate);
    }

    ///////////////////////////////////////////////////////////////////////// ORDERBOOK //////////////////////////////////////////////////////////////////////////////////////////

    uint256[] public sellrateid;
    uint256[] public buyrateid;

    uint256[] public amountsell;
    uint256[] public amountbuy;

    function getbuyrate() public returns (uint256[] memory) {
        return buyrateid;
    }

    function getsellrate() public returns (uint256[] memory) {
        return sellrateid;
    }

    function getamountbuy() public returns (uint256[] memory) {
        return amountbuy;
    }

    //buy B using A
    function atob(uint256 b, uint256 a) external override nonReentrant {
        require(aToken.balanceOf(msg.sender) >= a, "hello error here atob");

        aToken.transferFrom(msg.sender, address(this), a);
        // emit PlaceBuyOrder(msg.sender, amountOfBuyToken, amountOfSellToken);
        // b = b * 1 ether;
        // a = a * 1 ether;
        uint256 rate = a / b;
        bool toAdd = true;

        for (uint256 i = 0; i < sellrateid.length; i++) {
            idOfSellRate = sellrateid[i];
            minSellRate = newSellOrderBook[idOfSellRate].rate;

            if (rate >= minSellRate && minSellRate > 0) {
                //give best order
                toAdd = false;
                if (newSellOrderBook[idOfSellRate].amount > b) {
                    uint256 newAmount = newSellOrderBook[idOfSellRate].amount -
                        b;
                    newSellOrderBook[idOfSellRate].amount = newAmount; //replace old amount with new
                    // transfer
                    aToken.transfer(newSellOrderBook[idOfSellRate].maker, a);
                    bToken.transfer(msg.sender, a / minSellRate);
                } else if (newSellOrderBook[idOfSellRate].amount == b) {
                    // transfer
                    aToken.transfer(newSellOrderBook[idOfSellRate].maker, a);
                    bToken.transfer(msg.sender, a / minSellRate);
                    // update the minSellRate
                    delete newSellOrderBook[idOfSellRate];
                    for (uint256 j = i; j < sellrateid.length - 1; j++) {
                        sellrateid[j] = sellrateid[j + 1];
                    }
                    sellrateid.pop();
                } else if (newSellOrderBook[idOfSellRate].amount < b) {
                    aToken.transfer(
                        newSellOrderBook[idOfSellRate].maker,
                        newSellOrderBook[idOfSellRate].amount
                    );
                    bToken.transfer(
                        msg.sender,
                        newSellOrderBook[idOfSellRate].amount / minSellRate
                    );
                    delete newSellOrderBook[idOfSellRate];
                    for (uint256 j = i; j < sellrateid.length - 1; j++) {
                        sellrateid[j] = sellrateid[j + 1];
                    }
                    sellrateid.pop();
                    _atobBook(rate, a - newSellOrderBook[idOfSellRate].amount);
                }
                break;
            }
        }

        if (a > 0 && toAdd) {
            _atobBook(rate, a);
        }
    }

    function maxNumber(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function minNumber(uint256 a, uint256 b) internal pure returns (uint256) {
        return a <= b ? a : b;
    }

    function _atobBook(uint256 rate, uint256 a) internal {
        require(rate > 0);
        buyCounter += 1;
        buyrateid.push(buyCounter);
        newBuyOrderBook[buyCounter] = NewOrder(msg.sender, a, rate);
    }

    // buy A using b
    function btoa(uint256 a, uint256 b) external override nonReentrant {
        require(bToken.balanceOf(msg.sender) >= b, "Hello error here btoa");
        amountbuy.push(b);
        amountbuy.push(a);
        bToken.transferFrom(msg.sender, address(this), b);

        uint256 rate = a / b;
        bool toAdd = true;

        for (uint256 i = 0; i < buyrateid.length; i++) {
            idOfBuyRate = buyrateid[i];
            maxBuyRate = newBuyOrderBook[idOfBuyRate].rate;

            if (rate <= maxBuyRate && maxBuyRate > 0) {
                toAdd = false;
                if (newBuyOrderBook[idOfBuyRate].amount > a) {
                    amountbuy.push(newBuyOrderBook[idOfBuyRate].amount);
                    amountbuy.push(b);
                    uint256 newAmount = newBuyOrderBook[idOfBuyRate].amount - a;
                    newBuyOrderBook[idOfBuyRate].amount = newAmount; //replace old amount with new
                    amountbuy.push(newBuyOrderBook[idOfBuyRate].amount);
                    // transfer
                    bToken.transfer(newBuyOrderBook[idOfBuyRate].maker, b);
                    aToken.transfer(msg.sender, b * maxBuyRate);
                } else if (newBuyOrderBook[idOfBuyRate].amount == a) {
                    // transfer
                    bToken.transfer(newBuyOrderBook[idOfBuyRate].maker, b);
                    aToken.transfer(msg.sender, b * maxBuyRate);
                    // update the minSellRate
                    delete newBuyOrderBook[idOfBuyRate];
                    for (uint256 j = i; j < buyrateid.length - 1; j++) {
                        buyrateid[j] = buyrateid[j + 1];
                    }
                    buyrateid.pop();
                } else if (newBuyOrderBook[idOfBuyRate].amount < a) {
                    bToken.transfer(
                        newBuyOrderBook[idOfBuyRate].maker,
                        newBuyOrderBook[idOfBuyRate].amount
                    );
                    aToken.transfer(
                        msg.sender,
                        newBuyOrderBook[idOfBuyRate].amount * maxBuyRate
                    );
                    delete newBuyOrderBook[idOfBuyRate];
                    for (uint256 j = i; j < buyrateid.length - 1; j++) {
                        buyrateid[j] = buyrateid[j + 1];
                    }
                    buyrateid.pop();
                    _btoaBook(rate, b - newBuyOrderBook[idOfBuyRate].amount);
                }
                break;
            }
        }

        if (b > 0 && toAdd) {
            _btoaBook(rate, b);
        }
    }

    function _btoaBook(uint256 rate, uint256 b) internal {
        require(rate > 0);
        sellCounter += 1;
        sellrateid.push(sellCounter);

        newSellOrderBook[sellCounter] = NewOrder(msg.sender, b, rate);
        // emit DrawToSellBook(msg.sender, rate, amountSold);
    }

    // function placeBuyOrder(
    //     uint256 price,
    //     uint256 amountOfBaseToken,
    //     uint256 amount
    // ) external override nonReentrant {
    //     require(aToken.balanceOf(msg.sender) >= amountOfBaseToken);

    //     aToken.transferFrom(msg.sender, address(this), amountOfBaseToken);
    //     emit PlaceBuyOrder(msg.sender, price, amountOfBaseToken);

    //     /**
    //      * @notice if has order in sell book, and price >= min sell price
    //      */
    //     //minSellPrice
    //     //
    //     uint256 sellPricePointer = minSellPrice;
    //     uint256 amountReflect = amountOfBaseToken;
    //     if (minSellPrice > 0 && price >= minSellPrice) {
    //         while (
    //             amountReflect > 0 &&
    //             sellPricePointer <= price &&
    //             sellPricePointer != 0
    //         ) {
    //             uint8 i = 1;
    //             uint256 higherPrice = sellSteps[sellPricePointer].higherPrice;
    //             while (
    //                 i <= sellOrdersInStepCounter[sellPricePointer] &&
    //                 amountReflect > 0
    //             ) {
    //                 if (
    //                     amountReflect >=
    //                     sellOrdersInStep[sellPricePointer][i].amount
    //                 ) {
    //                     //if the last order has been matched, delete the step
    //                     if (i == sellOrdersInStepCounter[sellPricePointer]) {
    //                         if (higherPrice > 0)
    //                             sellSteps[higherPrice].lowerPrice = 0;
    //                         delete sellSteps[sellPricePointer];
    //                         minSellPrice = higherPrice;
    //                     }

    //                     amountReflect = amountReflect.sub(
    //                         sellOrdersInStep[sellPricePointer][i].amount
    //                     );
    //                     //send before delete order

    //                     aToken.transfer(
    //                         sellOrdersInStep[sellPricePointer][i].maker,
    //                         sellOrdersInStep[sellPricePointer][i].amount
    //                     );
    //                     // delete order from storage
    //                     delete sellOrdersInStep[sellPricePointer][i];
    //                     sellOrdersInStepCounter[sellPricePointer] -= 1;
    //                     ///////////////////////////////
    //                     bToken.transfer(msg.sender, sellPricePointer);

    //                     //token.transferFrom(ethswap to other party)
    //                 } else {
    //                     sellSteps[sellPricePointer].amount = sellSteps[
    //                         sellPricePointer
    //                     ].amount.sub(amountReflect);
    //                     sellOrdersInStep[sellPricePointer][i]
    //                         .amount = sellOrdersInStep[sellPricePointer][i]
    //                         .amount
    //                         .sub(amountReflect);
    //                     amountReflect = 0;
    //                 }
    //                 i += 1;
    //             }
    //             sellPricePointer = higherPrice;
    //         }
    //     }
    //     /**
    //      * @notice draw to buy book the rest
    //      */
    //     if (amountReflect > 0) {
    //         _drawToBuyBook(price, amountReflect);
    //     }
    // }

    // /**
    //  * @notice Place buy order.
    //  */
    // function placeSellOrder(
    //     uint256 price,
    //     uint256 amountOfTradeToken,
    //     uint256 amount
    // ) external override nonReentrant {
    //     bToken.transferFrom(msg.sender, address(this), amountOfTradeToken);
    //     emit PlaceSellOrder(msg.sender, price, amountOfTradeToken);

    //     /**
    //      * @notice if has order in buy book, and price <= max buy price
    //      */
    //     uint256 buyPricePointer = maxBuyPrice;
    //     uint256 amountReflect = amountOfTradeToken;
    //     if (maxBuyPrice > 0 && price <= maxBuyPrice) {
    //         while (
    //             amountReflect > 0 &&
    //             buyPricePointer >= price &&
    //             buyPricePointer != 0
    //         ) {
    //             uint8 i = 1;
    //             uint256 lowerPrice = buySteps[buyPricePointer].lowerPrice;
    //             while (
    //                 i <= buyOrdersInStepCounter[buyPricePointer] &&
    //                 amountReflect > 0
    //             ) {
    //                 if (
    //                     amountReflect >=
    //                     buyOrdersInStep[buyPricePointer][i].amount
    //                 ) {
    //                     //if the last order has been matched, delete the step
    //                     if (i == buyOrdersInStepCounter[buyPricePointer]) {
    //                         if (lowerPrice > 0)
    //                             buySteps[lowerPrice].higherPrice = 0;
    //                         delete buySteps[buyPricePointer];
    //                         maxBuyPrice = lowerPrice;
    //                     }

    //                     amountReflect =
    //                         amountReflect -
    //                         (buyOrdersInStep[buyPricePointer][i].amount);
    //                     //send before delete order
    //                     bToken.transfer(
    //                         buyOrdersInStep[buyPricePointer][i].maker,
    //                         buyOrdersInStep[buyPricePointer][i].amount
    //                     );
    //                     // delete order from storage

    //                     delete buyOrdersInStep[buyPricePointer][i];
    //                     buyOrdersInStepCounter[buyPricePointer] -= 1;

    //                     ///////
    //                     aToken.transfer(msg.sender, buyPricePointer);
    //                 } else {
    //                     buySteps[buyPricePointer].amount =
    //                         buySteps[buyPricePointer].amount -
    //                         (amountReflect);
    //                     buyOrdersInStep[buyPricePointer][i].amount =
    //                         buyOrdersInStep[buyPricePointer][i].amount -
    //                         (amountReflect);
    //                     amountReflect = 0;
    //                 }
    //                 i += 1;
    //             }
    //             buyPricePointer = lowerPrice;
    //         }
    //     }
    //     /**
    //      * @notice draw to buy book the rest
    //      */
    //     if (amountReflect > 0) {
    //         _drawToSellBook(price, amountReflect);
    //     }
    // }

    // /**
    //  * @notice draw buy order.
    //  */
    // function _drawToBuyBook(uint256 price, uint256 amount) internal {
    //     require(price > 0, "Can not place order with price equal 0");

    //     buyOrdersInStepCounter[price] += 1;
    //     // order creation here
    //     buyOrdersInStep[price][buyOrdersInStepCounter[price]] = Order(
    //         msg.sender,
    //         amount
    //     );
    //     buySteps[price].amount = buySteps[price].amount + (amount);
    //     emit DrawToBuyBook(msg.sender, price, amount);

    //     if (maxBuyPrice == 0) {
    //         maxBuyPrice = price;
    //         return;
    //     }

    //     if (price > maxBuyPrice) {
    //         buySteps[maxBuyPrice].higherPrice = price;
    //         buySteps[price].lowerPrice = maxBuyPrice;
    //         maxBuyPrice = price;
    //         return;
    //     }

    //     if (price == maxBuyPrice) {
    //         return;
    //     }

    //     uint256 buyPricePointer = maxBuyPrice;
    //     while (price <= buyPricePointer) {
    //         buyPricePointer = buySteps[buyPricePointer].lowerPrice;
    //     }

    //     if (price < buySteps[buyPricePointer].higherPrice) {
    //         buySteps[price].higherPrice = buySteps[buyPricePointer].higherPrice;
    //         buySteps[price].lowerPrice = buyPricePointer;

    //         buySteps[buySteps[buyPricePointer].higherPrice].lowerPrice = price;
    //         buySteps[buyPricePointer].higherPrice = price;
    //     }
    // }

    // /**
    //  * @notice draw sell order.
    //  */
    // function _drawToSellBook(uint256 price, uint256 amount) internal {
    //     require(price > 0, "Can not place order with price equal 0");

    //     sellOrdersInStepCounter[price] += 1;
    //     sellOrdersInStep[price][sellOrdersInStepCounter[price]] = Order(
    //         msg.sender,
    //         amount
    //     );
    //     sellSteps[price].amount += amount;
    //     emit DrawToSellBook(msg.sender, price, amount);

    //     if (minSellPrice == 0) {
    //         minSellPrice = price;
    //         return;
    //     }

    //     if (price < minSellPrice) {
    //         sellSteps[minSellPrice].lowerPrice = price;
    //         sellSteps[price].higherPrice = minSellPrice;
    //         minSellPrice = price;
    //         return;
    //     }

    //     if (price == minSellPrice) {
    //         return;
    //     }

    //     uint256 sellPricePointer = minSellPrice;
    //     while (
    //         price >= sellPricePointer &&
    //         sellSteps[sellPricePointer].higherPrice != 0
    //     ) {
    //         sellPricePointer = sellSteps[sellPricePointer].higherPrice;
    //     }

    //     if (sellPricePointer < price) {
    //         sellSteps[price].lowerPrice = sellPricePointer;
    //         sellSteps[sellPricePointer].higherPrice = price;
    //     }

    //     if (
    //         sellPricePointer > price &&
    //         price > sellSteps[sellPricePointer].lowerPrice
    //     ) {
    //         sellSteps[price].lowerPrice = sellSteps[sellPricePointer]
    //             .lowerPrice;
    //         sellSteps[price].higherPrice = sellPricePointer;

    //         sellSteps[sellSteps[sellPricePointer].lowerPrice]
    //             .higherPrice = price;
    //         sellSteps[sellPricePointer].lowerPrice = price;
    //     }
    // }
}
