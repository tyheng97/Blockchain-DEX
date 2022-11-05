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
    BToken public bToken;
    constructor(AToken _aToken, BToken _bToken) public {
        aToken = _aToken;
        bToken = _bToken;
    }

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



    function getbuyrate() public returns (uint256[] memory) {
        return buyrateid;
    }

    function getsellrate() public returns (uint256[] memory) {
        return sellrateid;
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
                    uint256 arequired = newSellOrderBook[idOfSellRate].amount *
                        minSellRate;

                    if (arequired < a) {
                        aToken.transfer(
                            newSellOrderBook[idOfSellRate].maker,
                            arequired
                        );
                        bToken.transfer(msg.sender, arequired / minSellRate);

                        _atobBook(rate, a - arequired);
                        delete newSellOrderBook[idOfSellRate];
                        for (uint256 j = i; j < sellrateid.length - 1; j++) {
                            sellrateid[j] = sellrateid[j + 1];
                        }
                        sellrateid.pop();
                    } else if (arequired > a) {
                        aToken.transfer(
                            newSellOrderBook[idOfSellRate].maker,
                            a
                        );
                        bToken.transfer(msg.sender, a / minSellRate);
                        uint256 newAmount = newSellOrderBook[idOfSellRate]
                            .amount - a / minSellRate;
                        newSellOrderBook[idOfSellRate].amount = newAmount;
                    } else if (arequired == a) {
                        aToken.transfer(
                            newSellOrderBook[idOfSellRate].maker,
                            a
                        );
                        bToken.transfer(msg.sender, a / minSellRate);
                        delete newSellOrderBook[idOfSellRate];
                        for (uint256 j = i; j < sellrateid.length - 1; j++) {
                            sellrateid[j] = sellrateid[j + 1];
                        }
                        sellrateid.pop();
                    }
                } else if (newSellOrderBook[idOfSellRate].amount == b) {
                    uint256 arequired = newSellOrderBook[idOfSellRate].amount *
                        minSellRate;
                    if (arequired < a) {
                        aToken.transfer(
                            newSellOrderBook[idOfSellRate].maker,
                            arequired
                        );
                        bToken.transfer(msg.sender, arequired / minSellRate);

                        _atobBook(rate, a - arequired);
                        delete newSellOrderBook[idOfSellRate];
                        for (uint256 j = i; j < sellrateid.length - 1; j++) {
                            sellrateid[j] = sellrateid[j + 1];
                        }
                        sellrateid.pop();
                    } else if (arequired == a) {
                        aToken.transfer(
                            newSellOrderBook[idOfSellRate].maker,
                            a
                        );
                        bToken.transfer(msg.sender, a / minSellRate);
                        delete newSellOrderBook[idOfSellRate];
                        for (uint256 j = i; j < sellrateid.length - 1; j++) {
                            sellrateid[j] = sellrateid[j + 1];
                        }
                        sellrateid.pop();
                    }
                } else if (newSellOrderBook[idOfSellRate].amount < b) {
                    uint256 arequired = newSellOrderBook[idOfSellRate].amount *
                        minSellRate;
                    if (arequired < a) {
                        aToken.transfer(
                            newSellOrderBook[idOfSellRate].maker,
                            arequired
                        );
                        bToken.transfer(msg.sender, arequired / minSellRate);

                        _atobBook(rate, a - arequired);
                        delete newSellOrderBook[idOfSellRate];
                        for (uint256 j = i; j < sellrateid.length - 1; j++) {
                            sellrateid[j] = sellrateid[j + 1];
                        }
                        sellrateid.pop();
                    }
                }
                break;
            }
        }
        if (a > 0 && toAdd) {
            _atobBook(rate, a);
        }
    }

    function _atobBook(uint256 rate, uint256 a) internal {
        require(rate > 0);
        buyCounter += 1;
        buyrateid.push(buyCounter);
        newBuyOrderBook[buyCounter] = NewOrder(msg.sender, a, rate);
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
                    //calculate new b amount
                    uint256 brequired = newBuyOrderBook[idOfBuyRate].amount /
                        newBuyOrderBook[idOfBuyRate].rate;
                    if (brequired < b) {
                        bToken.transfer(
                            newBuyOrderBook[idOfBuyRate].maker,
                            brequired
                        );
                        aToken.transfer(msg.sender, brequired * maxBuyRate);
                        delete newBuyOrderBook[idOfBuyRate];
                        for (uint256 j = i; j < buyrateid.length - 1; j++) {
                            buyrateid[j] = buyrateid[j + 1];
                        }
                        buyrateid.pop();
                        _btoaBook(rate, b - brequired);
                    } else if (brequired > b) {
                        bToken.transfer(newBuyOrderBook[idOfBuyRate].maker, b);
                        aToken.transfer(msg.sender, b * maxBuyRate);
                        //calculate new a amount
                        uint256 newAmount = newBuyOrderBook[idOfBuyRate]
                            .amount - b * maxBuyRate;
                        newBuyOrderBook[idOfBuyRate].amount = newAmount; //replace old amount with new
                    } else {
                        bToken.transfer(newBuyOrderBook[idOfBuyRate].maker, b);
                        aToken.transfer(msg.sender, b * maxBuyRate);

                        delete newBuyOrderBook[idOfBuyRate];
                        for (uint256 j = i; j < buyrateid.length - 1; j++) {
                            buyrateid[j] = buyrateid[j + 1];
                        }
                        buyrateid.pop();
                    }
                } else if (newBuyOrderBook[idOfBuyRate].amount == a) {
                    uint256 brequired = newBuyOrderBook[idOfBuyRate].amount /
                        newBuyOrderBook[idOfBuyRate].rate;

                    if (brequired < b) {
                        bToken.transfer(
                            newBuyOrderBook[idOfBuyRate].maker,
                            brequired
                        );
                        aToken.transfer(msg.sender, brequired * maxBuyRate);
                        _btoaBook(rate, b - brequired);
                        delete newBuyOrderBook[idOfBuyRate];
                        for (uint256 j = i; j < buyrateid.length - 1; j++) {
                            buyrateid[j] = buyrateid[j + 1];
                        }
                        buyrateid.pop();
                    } else if (b == brequired) {
                        bToken.transfer(newBuyOrderBook[idOfBuyRate].maker, b);
                        aToken.transfer(msg.sender, b * maxBuyRate);

                        delete newBuyOrderBook[idOfBuyRate];
                        for (uint256 j = i; j < buyrateid.length - 1; j++) {
                            buyrateid[j] = buyrateid[j + 1];
                        }
                        buyrateid.pop();
                    }
                } else if (newBuyOrderBook[idOfBuyRate].amount < a) {
                    uint256 brequired = newBuyOrderBook[idOfBuyRate].amount /
                        newBuyOrderBook[idOfBuyRate].rate;

                    if (brequired < b) {
                        bToken.transfer(
                            newBuyOrderBook[idOfBuyRate].maker,
                            brequired
                        );
                        aToken.transfer(msg.sender, brequired * maxBuyRate);
                        _btoaBook(rate, b - brequired);
                        delete newBuyOrderBook[idOfBuyRate];
                        for (uint256 j = i; j < buyrateid.length - 1; j++) {
                            buyrateid[j] = buyrateid[j + 1];
                        }
                        buyrateid.pop();
                    }
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



        return sellorderbookArray;
    }
}
