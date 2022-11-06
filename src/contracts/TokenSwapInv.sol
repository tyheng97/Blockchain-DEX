// SPDX-License-Identifier: MIT

pragma solidity >=0.6.8;

import "./AToken.sol";
import "./BToken.sol";
import {ITokenSwapInv} from "./interfaces/ITokenSwapInv.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {SafeMath} from "@openzeppelin/contracts/math/SafeMath.sol";
import {Math} from "@openzeppelin/contracts/math/Math.sol";

contract TokenSwapInv is ITokenSwapInv, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeMath for uint8;
    using Math for uint256;

    string public name = "TokenSwapInv Exchange";
    AToken public aToken;
    // uint256 public aRate = 1000;
    BToken public bToken;

    // uint256 public bRate = 1000;

    constructor(AToken _aToken, BToken _bToken) public {
        //pass the address of the Token in
        aToken = _aToken;
        bToken = _bToken;
    }
    uint256[] buyorderbookArray;
    uint256[] sellorderbookArray;

    uint256[] public sellrateidInv;
    uint256[] public buyrateidInv;

    uint256 public idOfBuyRateInv;
    uint256 public idOfSellRateInv;

    uint256 public buyCounterInv = 0;
    uint256 public minSellRate;
    mapping(uint256 => NewOrder) public newBuyOrderBookInv;

    uint256 public sellCounterInv = 0;
    mapping(uint256 => NewOrder) public newSellOrderBookInv;
    uint256 public maxBuyRate;

    function getbuyrateInv() public returns (uint256[] memory) {
        return buyrateidInv;
    }

    function getsellrateInv() public returns (uint256[] memory) {
        return sellrateidInv;
    }

    function _atobBookInv(uint256 rate, uint256 a) internal {
        require(rate > 0);
        buyCounterInv += 1;
        buyrateidInv.push(buyCounterInv);
        newBuyOrderBookInv[buyCounterInv] = NewOrder(msg.sender, a, rate);
    }
    function atobInverseRate(uint256 b, uint256 a) external override nonReentrant {
        require(aToken.balanceOf(msg.sender) >= a);

        aToken.transferFrom(msg.sender, address(this), a);
        // emit ATokensSent(msg.sender, address(this),a);
        uint256 rate = b / a;
        bool toAdd = true;

        for (uint256 i = 0; i < sellrateidInv.length; i++) {
            idOfSellRateInv = sellrateidInv[i];
            minSellRate = newSellOrderBookInv[idOfSellRateInv].rate;

            if (rate <= minSellRate && minSellRate > 0) {
                //give best order
                toAdd = false;
                if (newSellOrderBookInv[idOfSellRateInv].amount > b) {
                    uint256 arequired = newSellOrderBookInv[idOfSellRateInv].amount /
                        newSellOrderBookInv[idOfSellRateInv].rate;

                    if (arequired < a) {
                        aToken.transfer(
                            newSellOrderBookInv[idOfSellRateInv].maker,
                            arequired
                        );
                        bToken.transfer(msg.sender, arequired * minSellRate);

                        _atobBookInv(rate, a - arequired);
                        delete newSellOrderBookInv[idOfSellRateInv];
                        for (uint256 j = i; j < sellrateidInv.length - 1; j++) {
                            sellrateidInv[j] = sellrateidInv[j + 1];
                        }
                        sellrateidInv.pop();
                    } else if (arequired > a) {
                        aToken.transfer(
                            newSellOrderBookInv[idOfSellRateInv].maker,
                            a
                        );
                        bToken.transfer(msg.sender, a * minSellRate);
                        uint256 newAmount = newSellOrderBookInv[idOfSellRateInv]
                            .amount - a * minSellRate;
                        newSellOrderBookInv[idOfSellRateInv].amount = newAmount;
                    } else if (arequired == a) {
                        aToken.transfer(
                            newSellOrderBookInv[idOfSellRateInv].maker,
                            a
                        );
                        bToken.transfer(msg.sender, a * minSellRate);
                        delete newSellOrderBookInv[idOfSellRateInv];
                        for (uint256 j = i; j < sellrateidInv.length - 1; j++) {
                            sellrateidInv[j] = sellrateidInv[j + 1];
                        }
                        sellrateidInv.pop();
                    }
                } else if (newSellOrderBookInv[idOfSellRateInv].amount == b) {
                    uint256 arequired = newSellOrderBookInv[idOfSellRateInv].amount /
                        newSellOrderBookInv[idOfSellRateInv].rate;
                    if (arequired < a) {
                        aToken.transfer(
                            newSellOrderBookInv[idOfSellRateInv].maker,
                            arequired
                        );
                        bToken.transfer(msg.sender, arequired * minSellRate);

                        _atobBookInv(rate, a - arequired);
                        delete newSellOrderBookInv[idOfSellRateInv];
                        for (uint256 j = i; j < sellrateidInv.length - 1; j++) {
                            sellrateidInv[j] = sellrateidInv[j + 1];
                        }
                        sellrateidInv.pop();
                    } else if (arequired == a) {
                        aToken.transfer(
                            newSellOrderBookInv[idOfSellRateInv].maker,
                            a
                        );
                        bToken.transfer(msg.sender, a * minSellRate);
                        delete newSellOrderBookInv[idOfSellRateInv];
                        for (uint256 j = i; j < sellrateidInv.length - 1; j++) {
                            sellrateidInv[j] = sellrateidInv[j + 1];
                        }
                        sellrateidInv.pop();
                    }
                } else if (newSellOrderBookInv[idOfSellRateInv].amount < b) {
                    uint256 arequired = newSellOrderBookInv[idOfSellRateInv].amount *
                        newSellOrderBookInv[idOfSellRateInv].rate;
                    if (arequired < a) {
                        aToken.transfer(
                            newSellOrderBookInv[idOfSellRateInv].maker,
                            arequired
                        );
                        bToken.transfer(msg.sender, arequired * minSellRate);

                        _atobBookInv(rate, a - arequired);
                        delete newSellOrderBookInv[idOfSellRateInv];
                        for (uint256 j = i; j < sellrateidInv.length - 1; j++) {
                            sellrateidInv[j] = sellrateidInv[j + 1];
                        }
                        sellrateidInv.pop();
                    }
                }
                break;
            }
        }
        if (a > 0 && toAdd) {
            _atobBookInv(rate, a);
        }
    }
    function _btoaBookInv(uint256 rate, uint256 b) internal {
        require(rate > 0);
        sellCounterInv += 1;
        sellrateidInv.push(sellCounterInv);
        newSellOrderBookInv[sellCounterInv] = NewOrder(msg.sender, b, rate);
        // // emit DrawToSellBook(msg.sender, rate, amountSold);
    }

    function btoaInverseRate(uint256 a, uint256 b) external override nonReentrant {
        require(bToken.balanceOf(msg.sender) >= b);
        bToken.transferFrom(msg.sender, address(this), b);
        // emit BTokensSent(msg.sender, address(this),b);

        uint256 rate = b / a;
        bool toAdd = true;

        for (uint256 i = 0; i < buyrateidInv.length; i++) {
            idOfBuyRateInv = buyrateidInv[i];
            maxBuyRate = newBuyOrderBookInv[idOfBuyRateInv].rate;
            if (rate >= maxBuyRate && maxBuyRate > 0) {
                toAdd = false;
                if (newBuyOrderBookInv[idOfBuyRateInv].amount > a) {
                    //calculate new b amount
                    uint256 brequired = newBuyOrderBookInv[idOfBuyRateInv].amount *
                        maxBuyRate;
                    if (brequired < b) {
                        bToken.transfer(
                            newBuyOrderBookInv[idOfBuyRateInv].maker,
                            brequired
                        );
                        aToken.transfer(msg.sender, brequired / maxBuyRate);

                        _btoaBookInv(rate, b - brequired);
                        delete newBuyOrderBookInv[idOfBuyRateInv];
                        for (uint256 j = i; j < buyrateidInv.length - 1; j++) {
                            buyrateidInv[j] = buyrateidInv[j + 1];
                        }
                        buyrateidInv.pop();
                    } else if (brequired > b) {
                        bToken.transfer(newBuyOrderBookInv[idOfBuyRateInv].maker, b);
                        aToken.transfer(msg.sender, b / maxBuyRate);
                        //calculate new a amount
                        uint256 newAmount = newBuyOrderBookInv[idOfBuyRateInv]
                            .amount - b * maxBuyRate;
                        newBuyOrderBookInv[idOfBuyRateInv].amount = newAmount; //replace old amount with new
                    } else {
                        bToken.transfer(newBuyOrderBookInv[idOfBuyRateInv].maker, b);
                        aToken.transfer(msg.sender, b / maxBuyRate);

                        delete newBuyOrderBookInv[idOfBuyRateInv];
                        for (uint256 j = i; j < buyrateidInv.length - 1; j++) {
                            buyrateidInv[j] = buyrateidInv[j + 1];
                        }
                        buyrateidInv.pop();
                    }
                } else if (newBuyOrderBookInv[idOfBuyRateInv].amount == a) {
                    uint256 brequired = newBuyOrderBookInv[idOfBuyRateInv].amount *
                        maxBuyRate;

                    if (brequired < b) {
                        bToken.transfer(
                            newBuyOrderBookInv[idOfBuyRateInv].maker,
                            brequired
                        );
                        aToken.transfer(msg.sender, brequired / maxBuyRate);
                        _btoaBookInv(rate, b - brequired);
                        delete newBuyOrderBookInv[idOfBuyRateInv];
                        for (uint256 j = i; j < buyrateidInv.length - 1; j++) {
                            buyrateidInv[j] = buyrateidInv[j + 1];
                        }
                        buyrateidInv.pop();
                    } else if (b == brequired) {
                        bToken.transfer(newBuyOrderBookInv[idOfBuyRateInv].maker, b);
                        aToken.transfer(msg.sender, b / maxBuyRate);

                        delete newBuyOrderBookInv[idOfBuyRateInv];
                        for (uint256 j = i; j < buyrateidInv.length - 1; j++) {
                            buyrateidInv[j] = buyrateidInv[j + 1];
                        }
                        buyrateidInv.pop();
                    }
                } else if (newBuyOrderBookInv[idOfBuyRateInv].amount < a) {
                    uint256 brequired = newBuyOrderBookInv[idOfBuyRateInv].amount *
                        maxBuyRate;

                    if (brequired < b) {
                        bToken.transfer(
                            newBuyOrderBookInv[idOfBuyRateInv].maker,
                            brequired
                        );
                        aToken.transfer(msg.sender, brequired / maxBuyRate);
                        _btoaBookInv(rate, b - brequired);
                        delete newBuyOrderBookInv[idOfBuyRateInv];
                        for (uint256 j = i; j < buyrateidInv.length - 1; j++) {
                            buyrateidInv[j] = buyrateidInv[j + 1];
                        }
                        buyrateidInv.pop();
                    }
                }
                break;
            }
        }

        if (b > 0 && toAdd) {
            _btoaBookInv(rate, b);
        }
    }
////////////////////////////////////////////////////////////////////////////////////////////// delete orders  ///////////////////////////////////////////////////////////////////////////////////////////////

    function deleteBuyOrders() public {

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