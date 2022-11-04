// SPDX-License-Identifier: MIT

pragma solidity >=0.6.8;

import "./AToken.sol";
import "./BToken.sol";
import {ITokenSwap} from "./interfaces/ITokenSwap.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {SafeMath} from "@openzeppelin/contracts/math/SafeMath.sol";
import {Math} from "@openzeppelin/contracts/math/Math.sol";

contract TokenSwap is ITokenSwap, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeMath for uint8;
    using Math for uint256;

    string public name = "TokenSwap Exchange";
    AToken public aToken;
    // uint256 public aRate = 1000;
    BToken public bToken;
    // uint256 public bRate = 1000;

    constructor(AToken _aToken, BToken _bToken) public {
        //pass the address of the Token in
        aToken = _aToken;
        bToken = _bToken;
    }

    // function buyATokens() public payable {
    //     // Calculate the number of tokens to buy
    //     uint256 tokenAmount = msg.value * aRate; //msg.value = how much ether was sent

    //     // Require that TokenSwap has enough tokens
    //     require(aToken.balanceOf(address(this)) >= tokenAmount);

    //     // Transfer tokens to the user
    //     aToken.transfer(msg.sender, tokenAmount);

    //     // // emit an event
    //     // emit TokensPurchased(msg.sender, address(aToken), tokenAmount, aRate);
    // }

    // function sellATokens(uint256 _amount) public {
    //     // User can't sell more tokens than they have
    //     require(aToken.balanceOf(msg.sender) >= _amount);

    //     // Calculate the amount of Ether to redeem
    //     uint256 etherAmount = _amount / aRate;

    //     // Require that TokenSwap has enough Ether
    //     require(address(this).balance >= etherAmount);

    //     // Perform sale
    //     aToken.transferFrom(msg.sender, address(this), _amount);
    //     msg.sender.transfer(etherAmount);

    //     // // emit an event
    //     // emit TokensSold(msg.sender, address(aToken), _amount, aRate);
    // }

    // function buyBTokens() public payable {
    //     // Calculate the number of tokens to buy
    //     uint256 tokenAmount = msg.value * bRate; //msg.value = how much ether was sent

    //     // Require that TokenSwap has enough tokens
    //     require(bToken.balanceOf(address(this)) >= tokenAmount);

    //     // Transfer tokens to the user
    //     bToken.transfer(msg.sender, tokenAmount);

    //     // // emit an event
    //     // emit TokensPurchased(msg.sender, address(bToken), tokenAmount, bRate);
    // }

    // function sellBTokens(uint256 _amount) public {
    //     // User can't sell more tokens than they have
    //     require(bToken.balanceOf(msg.sender) >= _amount);

    //     // Calculate the amount of Ether to redeem
    //     uint256 etherAmount = _amount / bRate;

    //     // Require that TokenSwap has enough Ether
    //     require(address(this).balance >= etherAmount);

    //     // Perform sale
    //     bToken.transferFrom(msg.sender, address(this), _amount);
    //     msg.sender.transfer(etherAmount);

    //     // // emit an event
    //     // emit TokensSold(msg.sender, address(bToken), _amount, bRate);
    // }

    ///////////////////////////////////////////////////////////////////////// ORDERBOOK //////////////////////////////////////////////////////////////////////////////////////////

    uint256 public buyCounter = 0;
    uint256 public minSellRate;
    mapping(uint256 => NewOrder) public newBuyOrderBook;
    uint256 public idOfBuyRate;

    uint256 public sellCounter = 0;
    mapping(uint256 => NewOrder) public newSellOrderBook;
    uint256 public idOfSellRate;
    uint256 public maxBuyRate;

    uint256[] public sellrateid;
    uint256[] public buyrateid;

    uint256[] public amountsell;
    uint256[] public amountbuy;

    uint256[] buyorderbookArray;
    uint256[] sellorderbookArray;

    ////////////////////////////////////
    uint256[] public sellrateidInv;
    uint256[] public buyrateidInv;

    uint256 public idOfBuyRateInv;
    uint256 public idOfSellRateInv;

    uint256 public buyCounterInv = 0;
    uint256 public maxSellRate;
    mapping(uint256 => NewOrder) public newBuyOrderBookInv;

    uint256 public sellCounterInv = 0;
    mapping(uint256 => NewOrder) public newSellOrderBookInv;
    uint256 public minBuyRate;

    ////////////////////////////////////

    function getbuyrate() public returns (uint256[] memory) {
        return buyrateid;
    }

    function getsellrate() public returns (uint256[] memory) {
        return sellrateid;
    }

    function getbuyrateInv() public returns (uint256[] memory) {
        return buyrateidInv;
    }

    function getsellrateInv() public returns (uint256[] memory) {
        return sellrateidInv;
    }

    //buy B using A
    function atob(uint256 b, uint256 a) external override nonReentrant {
        require(aToken.balanceOf(msg.sender) >= a);

        aToken.transferFrom(msg.sender, address(this), a);
        // emit ATokensSent(msg.sender, address(this),a);
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
                    // emit ATokensSent( address(this), newSellOrderBook[idOfSellRate].maker, a);
                    // emit BTokensSent( address(this), msg.sender,a / minSellRate);
                } else if (newSellOrderBook[idOfSellRate].amount == b) {
                    // transfer
                    aToken.transfer(newSellOrderBook[idOfSellRate].maker, a);
                    bToken.transfer(msg.sender, a / minSellRate);
                    // emit ATokensSent( address(this), newSellOrderBook[idOfSellRate].maker, a);
                    // emit BTokensSent( address(this), msg.sender,a / minSellRate);
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
                    // emit ATokensSent( address(this), newSellOrderBook[idOfSellRate].maker, newSellOrderBook[idOfSellRate].amount);
                    // emit BTokensSent( address(this), msg.sender,newSellOrderBook[idOfSellRate].amount / minSellRate);

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

    function atobInverseRate(uint256 b, uint256 a)
        external
        override
        nonReentrant
    {
        require(aToken.balanceOf(msg.sender) >= a, "hello error here atob");

        aToken.transferFrom(msg.sender, address(this), a);
        // emit ATokensSent(msg.sender, address(this),a);

        uint256 rate = b / a;
        bool toAdd = true;

        for (uint256 i = 0; i < sellrateidInv.length; i++) {
            idOfSellRate = sellrateidInv[i];
            maxSellRate = newSellOrderBookInv[idOfSellRate].rate;

            if (rate >= maxSellRate && maxSellRate > 0) {
                //give best order
                toAdd = false;
                if (newSellOrderBookInv[idOfSellRate].amount > b) {
                    uint256 newAmount = newSellOrderBookInv[idOfSellRate]
                        .amount - b;
                    newSellOrderBookInv[idOfSellRate].amount = newAmount; //replace old amount with new
                    // transfer
                    aToken.transfer(newSellOrderBookInv[idOfSellRate].maker, a);
                    bToken.transfer(msg.sender, a * maxSellRate);
                    // emit ATokensSent( address(this), newSellOrderBookInv[idOfSellRate].maker, a);
                    // emit BTokensSent( address(this), msg.sender,a / maxSellRate);
                } else if (newSellOrderBookInv[idOfSellRate].amount == b) {
                    // transfer
                    aToken.transfer(newSellOrderBookInv[idOfSellRate].maker, a);
                    bToken.transfer(msg.sender, a * maxSellRate);
                    // emit ATokensSent( address(this), newSellOrderBookInv[idOfSellRate].maker, a);
                    // emit BTokensSent( address(this), msg.sender,a / maxSellRate);

                    delete newSellOrderBookInv[idOfSellRate];
                    for (uint256 j = i; j < sellrateidInv.length - 1; j++) {
                        sellrateidInv[j] = sellrateidInv[j + 1];
                    }
                    sellrateidInv.pop();
                } else if (newSellOrderBookInv[idOfSellRate].amount < b) {
                    aToken.transfer(
                        newSellOrderBookInv[idOfSellRate].maker,
                        newSellOrderBookInv[idOfSellRate].amount
                    );
                    bToken.transfer(
                        msg.sender,
                        newSellOrderBookInv[idOfSellRate].amount * maxSellRate
                    );
                    // emit ATokensSent( address(this), newSellOrderBookInv[idOfSellRate].maker, newSellOrderBookInv[idOfSellRate].amount);
                    // emit BTokensSent( address(this), msg.sender,newSellOrderBookInv[idOfSellRate].amount / maxSellRate);

                    delete newSellOrderBookInv[idOfSellRate];
                    for (uint256 j = i; j < sellrateidInv.length - 1; j++) {
                        sellrateidInv[j] = sellrateidInv[j + 1];
                    }
                    sellrateidInv.pop();
                    _atobBookInv(
                        rate,
                        a - newSellOrderBookInv[idOfSellRate].amount
                    );
                }
                break;
            }
        }

        if (a > 0 && toAdd) {
            _atobBookInv(rate, a);
        }
    }

    function _atobBook(uint256 rate, uint256 a) internal {
        require(rate > 0);
        buyCounter += 1;
        buyrateid.push(buyCounter);
        newBuyOrderBook[buyCounter] = NewOrder(msg.sender, a, rate);
    }

    function _atobBookInv(uint256 rate, uint256 a) internal {
        require(rate > 0);
        buyCounterInv += 1;
        buyrateidInv.push(buyCounterInv);
        newBuyOrderBookInv[buyCounterInv] = NewOrder(msg.sender, a, rate);
    }

    // buy A using b
    function btoa(uint256 a, uint256 b) external override nonReentrant {
        require(bToken.balanceOf(msg.sender) >= b);
        amountbuy.push(b);
        amountbuy.push(a);
        bToken.transferFrom(msg.sender, address(this), b);
        // emit BTokensSent(msg.sender, address(this),b);

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
                    // emit BTokensSent( address(this), newBuyOrderBook[idOfBuyRate].maker,b);
                    // emit ATokensSent( address(this), msg.sender,b * maxBuyRate);
                } else if (newBuyOrderBook[idOfBuyRate].amount == a) {
                    // transfer
                    bToken.transfer(newBuyOrderBook[idOfBuyRate].maker, b);
                    aToken.transfer(msg.sender, b * maxBuyRate);
                    // emit BTokensSent( address(this), newBuyOrderBook[idOfBuyRate].maker,b);
                    // emit ATokensSent( address(this), msg.sender,b * maxBuyRate);
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
                    // emit BTokensSent( address(this), newBuyOrderBook[idOfBuyRate].maker, newBuyOrderBook[idOfBuyRate].amount);
                    // emit ATokensSent( address(this), msg.sender,newBuyOrderBook[idOfBuyRate].amount * maxBuyRate);
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

    function btoaInverseRate(uint256 a, uint256 b)
        external
        override
        nonReentrant
    {
        require(bToken.balanceOf(msg.sender) >= b);
        amountbuy.push(b);
        amountbuy.push(a);
        bToken.transferFrom(msg.sender, address(this), b);
        // emit BTokensSent(msg.sender, address(this),b);

        uint256 rate = b / a;
        bool toAdd = true;

        for (uint256 i = 0; i < buyrateidInv.length; i++) {
            idOfBuyRate = buyrateidInv[i];
            minBuyRate = newBuyOrderBookInv[idOfBuyRate].rate;

            if (rate <= minBuyRate && minBuyRate > 0) {
                toAdd = false;
                if (newBuyOrderBookInv[idOfBuyRate].amount > a) {
                    amountbuy.push(newBuyOrderBookInv[idOfBuyRate].amount);
                    amountbuy.push(b);
                    uint256 newAmount = newBuyOrderBookInv[idOfBuyRate].amount -
                        a;
                    newBuyOrderBookInv[idOfBuyRate].amount = newAmount; //replace old amount with new
                    amountbuy.push(newBuyOrderBookInv[idOfBuyRate].amount);
                    // transfer
                    bToken.transfer(newBuyOrderBookInv[idOfBuyRate].maker, b);
                    aToken.transfer(msg.sender, b / minBuyRate);

                    // emit BTokensSent( address(this), newBuyOrderBookInv[idOfBuyRate].maker,b);
                    // emit ATokensSent( address(this), msg.sender,b * maxBuyRate);
                } else if (newBuyOrderBookInv[idOfBuyRate].amount == a) {
                    // transfer
                    bToken.transfer(newBuyOrderBookInv[idOfBuyRate].maker, b);
                    aToken.transfer(msg.sender, b / minBuyRate);

                    // emit BTokensSent( address(this), newBuyOrderBookInv[idOfBuyRate].maker,b);
                    // emit ATokensSent( address(this), msg.sender,b * maxBuyRate);
                    // update the minSellRate
                    delete newBuyOrderBookInv[idOfBuyRate];
                    for (uint256 j = i; j < buyrateidInv.length - 1; j++) {
                        buyrateidInv[j] = buyrateidInv[j + 1];
                    }
                    buyrateidInv.pop();
                } else if (newBuyOrderBookInv[idOfBuyRate].amount < a) {
                    bToken.transfer(
                        newBuyOrderBookInv[idOfBuyRate].maker,
                        newBuyOrderBookInv[idOfBuyRate].amount
                    );
                    aToken.transfer(
                        msg.sender,
                        newBuyOrderBookInv[idOfBuyRate].amount / minBuyRate
                    );
                    // emit BTokensSent( address(this), newBuyOrderBookInv[idOfBuyRate].maker, newBuyOrderBookInv[idOfBuyRate].amount);
                    // emit ATokensSent( address(this), msg.sender,newBuyOrderBookInv[idOfBuyRate].amount * maxBuyRate);

                    delete newBuyOrderBookInv[idOfBuyRate];
                    for (uint256 j = i; j < buyrateidInv.length - 1; j++) {
                        buyrateidInv[j] = buyrateidInv[j + 1];
                    }
                    buyrateidInv.pop();
                    _btoaBookInv(rate, b);
                    (rate, b - newBuyOrderBookInv[idOfBuyRate].amount);
                }
                break;
            }
        }

        if (b > 0 && toAdd) {
            _btoaBookInv(rate, b);
        }
    }

    function _btoaBookInv(uint256 rate, uint256 b) internal {
        require(rate > 0);
        sellCounterInv += 1;
        sellrateidInv.push(sellCounterInv);
        newSellOrderBookInv[sellCounterInv] = NewOrder(msg.sender, b, rate);
        // // emit DrawToSellBook(msg.sender, rate, amountSold);
    }

    function _btoaBook(uint256 rate, uint256 b) internal {
        require(rate > 0);
        sellCounter += 1;
        sellrateid.push(sellCounter);
        newSellOrderBook[sellCounter] = NewOrder(msg.sender, b, rate);
        // // emit DrawToSellBook(msg.sender, rate, amountSold);
    }

    ////////////////////////////////////////////////////////////////////////////////////////////// delete orders  ///////////////////////////////////////////////////////////////////////////////////////////////

    function deleteBuyOrders() public {
        for (uint256 i = 0; i < buyrateid.length; i++) {
            uint256 key = buyrateid[i];
            if (msg.sender == newBuyOrderBook[key].maker) {
                aToken.transfer(msg.sender, newBuyOrderBook[key].amount);
                delete newBuyOrderBook[key];
                for (uint256 j = i; j < buyrateid.length - 1; j++) {
                    buyrateid[j] = buyrateid[j + 1];
                }
                buyrateid.pop();
                i--;
            }
        }

        for (uint256 i = 0; i < buyrateidInv.length; i++) {
            uint256 key = buyrateidInv[i];
            if (msg.sender == newBuyOrderBookInv[key].maker) {
                aToken.transfer(msg.sender, newBuyOrderBookInv[key].amount);
                delete newBuyOrderBookInv[key];
                for (uint256 j = i; j < buyrateidInv.length - 1; j++) {
                    buyrateidInv[j] = buyrateidInv[j + 1];
                }
                buyrateidInv.pop();
                i--;
            }
        }
    }

    function deleteSellOrders() public {
        for (uint256 i = 0; i < sellrateid.length; i++) {
            uint256 key = sellrateid[i];
            if (msg.sender == newSellOrderBook[key].maker) {
                bToken.transfer(msg.sender, newSellOrderBook[key].amount);
                delete newSellOrderBook[key];
                for (uint256 j = i; j < sellrateid.length - 1; j++) {
                    sellrateid[j] = sellrateid[j + 1];
                }
                sellrateid.pop();
                i--;
            }
        }

        for (uint256 i = 0; i < sellrateidInv.length; i++) {
            uint256 key = sellrateidInv[i];
            if (msg.sender == newSellOrderBookInv[key].maker) {
                bToken.transfer(msg.sender, newSellOrderBookInv[key].amount);
                delete newSellOrderBookInv[key];
                for (uint256 j = i; j < sellrateidInv.length - 1; j++) {
                    sellrateidInv[j] = sellrateidInv[j + 1];
                }
                sellrateidInv.pop();
                i--;
            }
        }
    }

    ////////////////////////////////////////////////////////////////////////////////////////////// display orderbooks ///////////////////////////////////////////////////////////////////////////////////////////////
    function getBuyOrderBook(address account)
        public
        returns (uint256[] memory)
    {
        buyorderbookArray = new uint256[](0);
        for (uint256 i = 0; i < buyrateid.length; i++) {
            uint256 key = buyrateid[i];
            if (account == newBuyOrderBook[key].maker) {
                buyorderbookArray.push(
                    newBuyOrderBook[key].amount / newBuyOrderBook[key].rate
                );
            }
        }

        for (uint256 j = 0; j < buyrateidInv.length; j++) {
            uint256 key = buyrateidInv[j];
            if (account == newBuyOrderBookInv[key].maker) {
                buyorderbookArray.push(
                    newBuyOrderBookInv[key].amount *
                        newBuyOrderBookInv[key].rate
                );
            }
        }

        return buyorderbookArray;
    }

    function getSellOrderBook(address account)
        public
        returns (uint256[] memory)
    {
        sellorderbookArray = new uint256[](0);
        for (uint256 i = 0; i < sellrateid.length; i++) {
            uint256 key = sellrateid[i];
            if (account == newSellOrderBook[key].maker) {
                sellorderbookArray.push(
                    newSellOrderBook[key].amount * newSellOrderBook[key].rate
                );
            }
        }

        for (uint256 i = 0; i < sellrateidInv.length; i++) {
            uint256 key = sellrateidInv[i];
            if (account == newSellOrderBookInv[key].maker) {
                sellorderbookArray.push(
                    newSellOrderBookInv[key].amount /
                        newSellOrderBookInv[key].rate
                );
            }
        }

        return sellorderbookArray;
    }
}
