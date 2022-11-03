pragma solidity >=0.6.8;

import "./CoolToken.sol";
import "./SecondToken.sol";
import {IOrderBook} from "./interfaces/IOrderBook.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {SafeMath} from "@openzeppelin/contracts/math/SafeMath.sol";
import {Math} from "@openzeppelin/contracts/math/Math.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract EthSwap is IOrderBook, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeMath for uint8;
    using Math for uint256;
    using SafeERC20 for IERC20;
    IERC20 public tradeToken;
    IERC20 public baseToken;

    string public name = "EthSwap Instant Exchange";
    CoolToken public coolToken;
    uint256 public coolRate = 1000;
    SecondToken public secondToken;
    uint256 public secondRate = 1000;

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

    event SecondTokensPurchased(
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

    event SecondTokensSold(
        address account,
        address token,
        uint256 amount,
        uint256 rate
    );

    constructor(CoolToken _coolToken, SecondToken _secondToken) public {
        //pass the address of the Token in
        coolToken = _coolToken;
        secondToken = _secondToken;
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

    function buyCoolTokens() public payable {
        // Calculate the number of tokens to buy
        uint256 tokenAmount = msg.value * coolRate; //msg.value = how much ether was sent

        // Require that EthSwap has enough tokens
        require(coolToken.balanceOf(address(this)) >= tokenAmount);

        // Transfer tokens to the user
        coolToken.transfer(msg.sender, tokenAmount);

        // Emit an event
        emit TokensPurchased(
            msg.sender,
            address(coolToken),
            tokenAmount,
            coolRate
        );
    }

    function limitBuyCoolTokens(uint256 _rate) public payable {
        uint256 testrate = random();

        require(testrate >= _rate, "fail");
        // Calculate the number of tokens to buy
        uint256 tokenAmount = msg.value * testrate; //msg.value = how much ether was sent

        // Require that EthSwap has enough tokens
        require(coolToken.balanceOf(address(this)) >= tokenAmount);

        // Transfer tokens to the user
        coolToken.transfer(msg.sender, tokenAmount);

        // Emit an event
        emit TokensPurchased(
            msg.sender,
            address(coolToken),
            tokenAmount,
            testrate
        );
    }

    function sellCoolTokens(uint256 _amount) public {
        // User can't sell more tokens than they have
        require(coolToken.balanceOf(msg.sender) >= _amount);

        // Calculate the amount of Ether to redeem
        uint256 etherAmount = _amount / coolRate;

        // Require that EthSwap has enough Ether
        require(address(this).balance >= etherAmount);

        // Perform sale
        coolToken.transferFrom(msg.sender, address(this), _amount);
        msg.sender.transfer(etherAmount);

        // Emit an event
        emit TokensSold(msg.sender, address(coolToken), _amount, coolRate);
    }

    // function limitSellCoolTokens(uint256 _amount, uint256 _rate) public {
    //     uint256 testrate = random();

    //     require(testrate <= _rate, "fail");
    //     // User can't sell more tokens than they have
    //     require(coolToken.balanceOf(msg.sender) >= _amount);

    //     // // Calculate the amount of Ether to redeem
    //     uint256 etherAmount = _amount / testrate;

    //     // Require that EthSwap has enough Ether
    //     require(address(this).balance >= etherAmount);

    //     // Perform sale
    //     coolToken.transferFrom(msg.sender, address(this), _amount);
    //     msg.sender.transfer(etherAmount);

    //     // // Emit an event
    //     emit TokensSold(msg.sender, address(coolToken), _amount, coolRate);
    // }

    // function buySecondTokensFromCool(uint256 _coolAmount) public {
    //     // Check if there is sufficient cool token in buyer acc
    //     require(coolToken.balanceOf(msg.sender) >= _coolAmount);
    //     // Calculate the amount of cool token to redeem
    //     uint256 secondAmount = _coolAmount * secondRate;
    //     // Check that there is enough seocond Token in ethSwap
    //     require(secondToken.balanceOf(address(this)) >= secondAmount);

    //     // Perform sale (this 2 method might be the problem)
    //     // secondToken.transferFrom(address(this), msg.sender, secondAmount);
    //     secondToken.transfer(msg.sender, secondAmount);
    //     coolToken.transferFrom(msg.sender, address(this), _coolAmount);
    //     // Emit an event
    //     emit SecondTokensPurchased(
    //         msg.sender,
    //         address(secondToken),
    //         secondAmount,
    //         secondRate
    //     );
    // }

    // function limitBuySecondTokens(uint256 _coolAmount, uint256 _secondRate)
    //     public
    // {
    //     uint256 testrate = random();
    //     require(testrate >= _secondRate, "fail");
    //     // Check if there is sufficient cool token in buyer acc
    //     require(coolToken.balanceOf(msg.sender) >= _coolAmount);
    //     // Calculate the amount of cool token to redeem
    //     uint256 secondAmount = _coolAmount * testrate;
    //     // Check that there is enough seocond Token in ethSwap
    //     require(secondToken.balanceOf(address(this)) >= secondAmount);

    //     // Perform sale (this 2 method might be the problem)
    //     // secondToken.transferFrom(address(this), msg.sender, secondAmount);
    //     secondToken.transfer(msg.sender, secondAmount);
    //     coolToken.transferFrom(msg.sender, address(this), _coolAmount);
    //     // Emit an event
    //     emit SecondTokensPurchased(
    //         msg.sender,
    //         address(secondToken),
    //         secondAmount,
    //         testrate
    //     );
    // }

    // function sellSecondTokensFromCool(uint256 _secondAmount) public {
    //     // Calculate the amount of cool token to redeem
    //     uint256 coolAmount = _secondAmount / secondRate;

    //     // Check that there is enough cool Token in ethSwap
    //     require(coolToken.balanceOf(address(this)) >= coolAmount);

    //     // Check if there is sufficient second token in buyer acc
    //     require(secondToken.balanceOf(msg.sender) >= _secondAmount);

    //     // Perform sale
    //     secondToken.transferFrom(msg.sender, address(this), _secondAmount);
    //     coolToken.transfer(msg.sender, coolAmount);

    //     // Emit an event
    //     emit SecondTokensSold(
    //         msg.sender,
    //         address(secondToken),
    //         _secondAmount,
    //         secondRate
    //     );
    // }

    // function limitSellSecondTokens(uint256 _secondAmount, uint256 _secondRate)
    //     public
    // {
    //     uint256 testrate = random();
    //     require(testrate <= _secondRate, "fail");
    //     // Calculate the amount of cool token to redeem
    //     uint256 coolAmount = _secondAmount / testrate;

    //     // Check that there is enough cool Token in ethSwap
    //     require(coolToken.balanceOf(address(this)) >= coolAmount);

    //     // Check if there is sufficient second token in buyer acc
    //     require(secondToken.balanceOf(msg.sender) >= _secondAmount);

    //     // Perform sale
    //     secondToken.transferFrom(msg.sender, address(this), _secondAmount);
    //     coolToken.transfer(msg.sender, coolAmount);

    //     // Emit an event
    //     emit SecondTokensSold(
    //         msg.sender,
    //         address(secondToken),
    //         _secondAmount,
    //         testrate
    //     );
    // }

    function buySecondTokens() public payable {
        // Calculate the number of tokens to buy
        uint256 tokenAmount = msg.value * secondRate; //msg.value = how much ether was sent

        // Require that EthSwap has enough tokens
        require(secondToken.balanceOf(address(this)) >= tokenAmount);

        // Transfer tokens to the user
        secondToken.transfer(msg.sender, tokenAmount);

        // Emit an event
        emit TokensPurchased(
            msg.sender,
            address(secondToken),
            tokenAmount,
            secondRate
        );
    }

    function sellSecondTokens(uint256 _amount) public {
        // User can't sell more tokens than they have
        require(secondToken.balanceOf(msg.sender) >= _amount);

        // Calculate the amount of Ether to redeem
        uint256 etherAmount = _amount / secondRate;

        // Require that EthSwap has enough Ether
        require(address(this).balance >= etherAmount);

        // Perform sale
        secondToken.transferFrom(msg.sender, address(this), _amount);
        msg.sender.transfer(etherAmount);

        // Emit an event
        emit TokensSold(msg.sender, address(secondToken), _amount, secondRate);
    }

    ///////////////////////////////////////////////////////////////////////// ORDERBOOK //////////////////////////////////////////////////////////////////////////////////////////
    // price = number of second u want
    // amount of baseToken = coolToken
    // buying second using cool

    // dont gwei in frontend
    // use price * 1 ether

    //b = cool
    //a = second
    uint256[] public sellrateid;
    uint256[] public buyrateid;

    function getbuyrate() public returns (uint256[] memory) {
        return buyrateid;
    }

    function getsellrate() public returns (uint256[] memory) {
        return sellrateid;
    }

    //buy B using A
    function atob(uint256 b, uint256 a) external override nonReentrant {
        require(coolToken.balanceOf(msg.sender) >= a, "hello error here atob");

        coolToken.transferFrom(msg.sender, address(this), a);
        // emit PlaceBuyOrder(msg.sender, amountOfBuyToken, amountOfSellToken);
        // b = b * 1 ether;
        // a = a * 1 ether;
        uint256 rate = a / b;
        uint256 sellRate = minSellRate;
        uint256 amountSold = a;
        bool toAdd = true;

        for (uint256 i = 0; i < sellrateid.length; i++) {
            idOfSellRate = sellrateid[i];
            minSellRate = newSellOrderBook[idOfSellRate].rate;

            if (rate >= minSellRate && minSellRate > 0) {
                //give best order
                toAdd = false;
                if (newSellOrderBook[idOfSellRate].amount > a) {
                    uint256 newAmount = newSellOrderBook[idOfSellRate].amount -
                        a;
                    newSellOrderBook[idOfSellRate].amount = newAmount; //replace old amount with new
                    // transfer
                    coolToken.transfer(newSellOrderBook[idOfSellRate].maker, a);
                    secondToken.transfer(msg.sender, a);
                } else if (newSellOrderBook[idOfSellRate].amount == a) {
                    // transfer
                    coolToken.transfer(newSellOrderBook[idOfSellRate].maker, a);
                    secondToken.transfer(msg.sender, a);
                    // update the minSellRate
                    delete newSellOrderBook[idOfSellRate];
                    delete sellrateid[i];
                } else if (newSellOrderBook[idOfSellRate].amount < a) {
                    coolToken.transfer(
                        newSellOrderBook[idOfSellRate].maker,
                        newSellOrderBook[idOfSellRate].amount
                    );
                    secondToken.transfer(msg.sender, a);
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
    function btoa(uint256 b, uint256 a) external override nonReentrant {
        require(
            secondToken.balanceOf(msg.sender) >= b,
            "Hello error here btoa"
        );
        secondToken.transferFrom(msg.sender, address(this), b);
        // emit PlaceSellOrder(msg.sender, amountOfBuyToken, amountOfSellToken);

        uint256 rate = a / b;
        uint256 sellRate = minSellRate;
        uint256 amountSold = b;
        bool toAdd = true;
        // b = b * 1 ether;
        // a = a * 1 ether;
        for (uint256 i = 0; i < buyrateid.length; i++) {
            idOfBuyRate = buyrateid[i];
            maxBuyRate = newBuyOrderBook[idOfBuyRate].rate;

            if (rate <= maxBuyRate && maxBuyRate > 0) {
                toAdd = false;
                if (newBuyOrderBook[idOfBuyRate].amount > b) {
                    uint256 newAmount = newBuyOrderBook[idOfBuyRate].amount - b;
                    newBuyOrderBook[idOfBuyRate].amount = newAmount; //replace old amount with new
                    // transfer
                    coolToken.transfer(newBuyOrderBook[idOfBuyRate].maker, b);
                    secondToken.transfer(msg.sender, b);
                } else if (newBuyOrderBook[idOfBuyRate].amount == b) {
                    // transfer
                    coolToken.transfer(newBuyOrderBook[idOfBuyRate].maker, b);
                    secondToken.transfer(msg.sender, b);
                    // update the minSellRate
                    delete newBuyOrderBook[idOfBuyRate];
                    delete buyrateid[i];
                } else if (newBuyOrderBook[idOfBuyRate].amount < b) {
                    coolToken.transfer(
                        newBuyOrderBook[idOfBuyRate].maker,
                        newBuyOrderBook[idOfBuyRate].amount
                    );
                    secondToken.transfer(msg.sender, b);
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

    function placeBuyOrder(
        uint256 price,
        uint256 amountOfBaseToken,
        uint256 amount
    ) external override nonReentrant {
        require(coolToken.balanceOf(msg.sender) >= amountOfBaseToken);

        coolToken.transferFrom(msg.sender, address(this), amountOfBaseToken);
        emit PlaceBuyOrder(msg.sender, price, amountOfBaseToken);

        /**
         * @notice if has order in sell book, and price >= min sell price
         */
        //minSellPrice
        //
        uint256 sellPricePointer = minSellPrice;
        uint256 amountReflect = amountOfBaseToken;
        if (minSellPrice > 0 && price >= minSellPrice) {
            while (
                amountReflect > 0 &&
                sellPricePointer <= price &&
                sellPricePointer != 0
            ) {
                uint8 i = 1;
                uint256 higherPrice = sellSteps[sellPricePointer].higherPrice;
                while (
                    i <= sellOrdersInStepCounter[sellPricePointer] &&
                    amountReflect > 0
                ) {
                    if (
                        amountReflect >=
                        sellOrdersInStep[sellPricePointer][i].amount
                    ) {
                        //if the last order has been matched, delete the step
                        if (i == sellOrdersInStepCounter[sellPricePointer]) {
                            if (higherPrice > 0)
                                sellSteps[higherPrice].lowerPrice = 0;
                            delete sellSteps[sellPricePointer];
                            minSellPrice = higherPrice;
                        }

                        amountReflect = amountReflect.sub(
                            sellOrdersInStep[sellPricePointer][i].amount
                        );
                        //send before delete order

                        coolToken.transfer(
                            sellOrdersInStep[sellPricePointer][i].maker,
                            sellOrdersInStep[sellPricePointer][i].amount
                        );
                        // delete order from storage
                        delete sellOrdersInStep[sellPricePointer][i];
                        sellOrdersInStepCounter[sellPricePointer] -= 1;
                        ///////////////////////////////
                        secondToken.transfer(msg.sender, sellPricePointer);

                        //token.transferFrom(ethswap to other party)
                    } else {
                        sellSteps[sellPricePointer].amount = sellSteps[
                            sellPricePointer
                        ].amount.sub(amountReflect);
                        sellOrdersInStep[sellPricePointer][i]
                            .amount = sellOrdersInStep[sellPricePointer][i]
                            .amount
                            .sub(amountReflect);
                        amountReflect = 0;
                    }
                    i += 1;
                }
                sellPricePointer = higherPrice;
            }
        }
        /**
         * @notice draw to buy book the rest
         */
        if (amountReflect > 0) {
            _drawToBuyBook(price, amountReflect);
        }
    }

    /**
     * @notice Place buy order.
     */
    function placeSellOrder(
        uint256 price,
        uint256 amountOfTradeToken,
        uint256 amount
    ) external override nonReentrant {
        secondToken.transferFrom(msg.sender, address(this), amountOfTradeToken);
        emit PlaceSellOrder(msg.sender, price, amountOfTradeToken);

        /**
         * @notice if has order in buy book, and price <= max buy price
         */
        uint256 buyPricePointer = maxBuyPrice;
        uint256 amountReflect = amountOfTradeToken;
        if (maxBuyPrice > 0 && price <= maxBuyPrice) {
            while (
                amountReflect > 0 &&
                buyPricePointer >= price &&
                buyPricePointer != 0
            ) {
                uint8 i = 1;
                uint256 lowerPrice = buySteps[buyPricePointer].lowerPrice;
                while (
                    i <= buyOrdersInStepCounter[buyPricePointer] &&
                    amountReflect > 0
                ) {
                    if (
                        amountReflect >=
                        buyOrdersInStep[buyPricePointer][i].amount
                    ) {
                        //if the last order has been matched, delete the step
                        if (i == buyOrdersInStepCounter[buyPricePointer]) {
                            if (lowerPrice > 0)
                                buySteps[lowerPrice].higherPrice = 0;
                            delete buySteps[buyPricePointer];
                            maxBuyPrice = lowerPrice;
                        }

                        amountReflect =
                            amountReflect -
                            (buyOrdersInStep[buyPricePointer][i].amount);
                        //send before delete order
                        secondToken.transfer(
                            buyOrdersInStep[buyPricePointer][i].maker,
                            buyOrdersInStep[buyPricePointer][i].amount
                        );
                        // delete order from storage

                        delete buyOrdersInStep[buyPricePointer][i];
                        buyOrdersInStepCounter[buyPricePointer] -= 1;

                        ///////
                        coolToken.transfer(msg.sender, buyPricePointer);
                    } else {
                        buySteps[buyPricePointer].amount =
                            buySteps[buyPricePointer].amount -
                            (amountReflect);
                        buyOrdersInStep[buyPricePointer][i].amount =
                            buyOrdersInStep[buyPricePointer][i].amount -
                            (amountReflect);
                        amountReflect = 0;
                    }
                    i += 1;
                }
                buyPricePointer = lowerPrice;
            }
        }
        /**
         * @notice draw to buy book the rest
         */
        if (amountReflect > 0) {
            _drawToSellBook(price, amountReflect);
        }
    }

    /**
     * @notice draw buy order.
     */
    function _drawToBuyBook(uint256 price, uint256 amount) internal {
        require(price > 0, "Can not place order with price equal 0");

        buyOrdersInStepCounter[price] += 1;
        // order creation here
        buyOrdersInStep[price][buyOrdersInStepCounter[price]] = Order(
            msg.sender,
            amount
        );
        buySteps[price].amount = buySteps[price].amount + (amount);
        emit DrawToBuyBook(msg.sender, price, amount);

        if (maxBuyPrice == 0) {
            maxBuyPrice = price;
            return;
        }

        if (price > maxBuyPrice) {
            buySteps[maxBuyPrice].higherPrice = price;
            buySteps[price].lowerPrice = maxBuyPrice;
            maxBuyPrice = price;
            return;
        }

        if (price == maxBuyPrice) {
            return;
        }

        uint256 buyPricePointer = maxBuyPrice;
        while (price <= buyPricePointer) {
            buyPricePointer = buySteps[buyPricePointer].lowerPrice;
        }

        if (price < buySteps[buyPricePointer].higherPrice) {
            buySteps[price].higherPrice = buySteps[buyPricePointer].higherPrice;
            buySteps[price].lowerPrice = buyPricePointer;

            buySteps[buySteps[buyPricePointer].higherPrice].lowerPrice = price;
            buySteps[buyPricePointer].higherPrice = price;
        }
    }

    /**
     * @notice draw sell order.
     */
    function _drawToSellBook(uint256 price, uint256 amount) internal {
        require(price > 0, "Can not place order with price equal 0");

        sellOrdersInStepCounter[price] += 1;
        sellOrdersInStep[price][sellOrdersInStepCounter[price]] = Order(
            msg.sender,
            amount
        );
        sellSteps[price].amount += amount;
        emit DrawToSellBook(msg.sender, price, amount);

        if (minSellPrice == 0) {
            minSellPrice = price;
            return;
        }

        if (price < minSellPrice) {
            sellSteps[minSellPrice].lowerPrice = price;
            sellSteps[price].higherPrice = minSellPrice;
            minSellPrice = price;
            return;
        }

        if (price == minSellPrice) {
            return;
        }

        uint256 sellPricePointer = minSellPrice;
        while (
            price >= sellPricePointer &&
            sellSteps[sellPricePointer].higherPrice != 0
        ) {
            sellPricePointer = sellSteps[sellPricePointer].higherPrice;
        }

        if (sellPricePointer < price) {
            sellSteps[price].lowerPrice = sellPricePointer;
            sellSteps[sellPricePointer].higherPrice = price;
        }

        if (
            sellPricePointer > price &&
            price > sellSteps[sellPricePointer].lowerPrice
        ) {
            sellSteps[price].lowerPrice = sellSteps[sellPricePointer]
                .lowerPrice;
            sellSteps[price].higherPrice = sellPricePointer;

            sellSteps[sellSteps[sellPricePointer].lowerPrice]
                .higherPrice = price;
            sellSteps[sellPricePointer].lowerPrice = price;
        }
    }
}
