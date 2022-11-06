// SPDX-License-Identifier: MIT

pragma solidity >=0.6.8;

import "./AToken.sol";
import "./BToken.sol";
import {IEthSwap} from "./interfaces/IEthSwap.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {SafeMath} from "@openzeppelin/contracts/math/SafeMath.sol";
import {Math} from "@openzeppelin/contracts/math/Math.sol";

contract EthSwap is IEthSwap, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeMath for uint8;
    using Math for uint256;

    string public name = "EthSwap Exchange";
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

        // Require that EthSwap has enough tokens
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

        // Require that EthSwap has enough Ether
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

        // Require that EthSwap has enough tokens
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

        // Require that EthSwap has enough Ether
        require(address(this).balance >= etherAmount);

        // Perform sale
        bToken.transferFrom(msg.sender, address(this), _amount);
        msg.sender.transfer(etherAmount);

        // // emit an event
        // emit TokensSold(msg.sender, address(bToken), _amount, bRate);
    }
}
