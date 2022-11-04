pragma solidity >=0.6.8;

import "./AToken.sol";
import "./BToken.sol";
import {ITokenSwap} from "./interfaces/ITokenSwap.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {SafeMath} from "@openzeppelin/contracts/math/SafeMath.sol";
import {Math} from "@openzeppelin/contracts/math/Math.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenSwap is ITokenSwap, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeMath for uint8;
    using Math for uint256;

    string public name = "TokenSwap Instant Exchange";
    AToken public aToken;
    uint256 public aRate = 1000;
    BToken public bToken;
    uint256 public bRate = 1000;

    constructor(AToken _aToken, BToken _bToken) public {
        //pass the address of the Token in
        aToken = _aToken;
        bToken = _bToken;
    }

    function buyATokens() public payable {
        // Calculate the number of tokens to buy
        uint256 tokenAmount = msg.value * aRate; //msg.value = how much ether was sent

        // Require that TokenSwap has enough tokens
        require(aToken.balanceOf(address(this)) >= tokenAmount);

        // Transfer tokens to the user
        aToken.transfer(msg.sender, tokenAmount);

        // // emit an event
        // emit TokensPurchased(msg.sender, address(aToken), tokenAmount, aRate);
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

        // // emit an event
        // emit TokensSold(msg.sender, address(aToken), _amount, aRate);
    }

    function buyBTokens() public payable {
        // Calculate the number of tokens to buy
        uint256 tokenAmount = msg.value * bRate; //msg.value = how much ether was sent

        // Require that TokenSwap has enough tokens
        require(bToken.balanceOf(address(this)) >= tokenAmount);

        // Transfer tokens to the user
        bToken.transfer(msg.sender, tokenAmount);

        // // emit an event
        // emit TokensPurchased(msg.sender, address(bToken), tokenAmount, bRate);
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

        // // emit an event
        // emit TokensSold(msg.sender, address(bToken), _amount, bRate);
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

    uint256[] buyorderbookArrary;
    uint256[] sellorderbookArrary;

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

 function atobInverseRate(uint256 b, uint256 a) external override nonReentrant {
        require(aToken.balanceOf(msg.sender) >= a, "hello error here atob");

        aToken.transferFrom(msg.sender, address(this), a);
        // emit ATokensSent(msg.sender, address(this),a);

        uint256 rate = b / a;
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
    function btoaInverseRate(uint256 a, uint256 b) external override nonReentrant {
        require(bToken.balanceOf(msg.sender) >= b);
        amountbuy.push(b);
        amountbuy.push(a);
        bToken.transferFrom(msg.sender, address(this), b);
        // emit BTokensSent(msg.sender, address(this),b);

        uint256 rate = b / a;
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

    function _btoaBook(uint256 rate, uint256 b) internal {
        require(rate > 0);
        sellCounter += 1;
        sellrateid.push(sellCounter);

        newSellOrderBook[sellCounter] = NewOrder(msg.sender, b, rate);
        // // emit DrawToSellBook(msg.sender, rate, amountSold);
    }

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

    function getBuyOrderBook(address account)
        public
        returns (uint256[] memory)
    {
        for (uint256 i = 0; i < buyrateid.length; i++) {
            uint256 key = buyrateid[i];
            if (account == newBuyOrderBook[key].maker) {
                buyorderbookArrary.push(
                    newBuyOrderBook[key].amount / newBuyOrderBook[key].rate
                );
            }
        }

        return buyorderbookArrary;
    }

    function getSellOrderBook(address account)
        public
        returns (uint256[] memory)
    {
        for (uint256 i = 0; i < sellrateid.length; i++) {
            uint256 key = sellrateid[i];
            if (account == newSellOrderBook[key].maker) {
                sellorderbookArrary.push(
                    newSellOrderBook[key].amount * newSellOrderBook[key].rate
                );
            }
        }

        return sellorderbookArrary;
    }

 
}
