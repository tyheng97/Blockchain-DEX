pragma solidity ^0.5.0;

import "./Token.sol";
import "./SecondToken.sol";

contract EthSwap {
    string public name = "EthSwap Instant Exchange";
    Token public token; // variable that represents token smart contract.
    uint256 public rate = 100; //uint means unsigned, no decimal and positive

    // This is just the code, does not tell us where the smart contract is.
    // It requires constructor
    SecondToken public secondToken;
    uint256 public secondRate = 5; //uint means unsigned, no decimal and positive

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

    constructor(Token _token, SecondToken _secondToken) public {
        //pass the address of the Token in
        token = _token;
        secondToken = _secondToken;
    }

    function buyTokens() public payable {
        // Calculate the number of tokens to buy
        uint256 tokenAmount = msg.value * rate; //msg.value = how much ether was sent

        // Require that EthSwap has enough tokens
        require(token.balanceOf(address(this)) >= tokenAmount);

        // Transfer tokens to the user
        token.transfer(msg.sender, tokenAmount);

        // Emit an event
        emit TokensPurchased(msg.sender, address(token), tokenAmount, rate);
    }

    function sellTokens(uint256 _amount) public {
        // User can't sell more tokens than they have
        require(token.balanceOf(msg.sender) >= _amount);

        // Calculate the amount of Ether to redeem
        uint256 etherAmount = _amount / rate;

        // Require that EthSwap has enough Ether
        require(address(this).balance >= etherAmount);

        // Perform sale
        token.transferFrom(msg.sender, address(this), _amount);
        msg.sender.transfer(etherAmount);

        // Emit an event
        emit TokensSold(msg.sender, address(token), _amount, rate);
    }

    function buySecondTokens(uint256 _coolAmount) public {
        // Check if there is sufficient cool token in buyer acc
        require(token.balanceOf(msg.sender) >= _coolAmount);
        // Calculate the amount of cool token to redeem
        uint256 secondAmount = _coolAmount * secondRate;
        // Check that there is enough seocond Token in ethSwap
        require(secondToken.balanceOf(address(this)) >= secondAmount);

        // Perform sale (this 2 method might be the problem)
        secondToken.transferFrom(address(this), msg.sender, secondAmount);
        token.transferFrom(msg.sender, address(this), _coolAmount);
        // Emit an event
        emit SecondTokensPurchased(
            msg.sender,
            address(secondToken),
            secondAmount,
            secondRate
        );
    }

    function sellSecondTokens(uint256 _secondAmount) public {
        // Calculate the amount of cool token to redeem
        uint256 coolAmount = _secondAmount / secondRate;

        // Check that there is enough cool Token in ethSwap
        require(secondToken.balanceOf(address(this)) >= coolAmount);

        // Check if there is sufficient second token in buyer acc
        require(token.balanceOf(msg.sender) >= _secondAmount);

        // Perform sale
        secondToken.transferFrom(msg.sender, address(this), _secondAmount);
        token.transferFrom(address(this), msg.sender, coolAmount);

        // Emit an event
        emit SecondTokensSold(
            msg.sender,
            address(secondToken),
            _secondAmount,
            secondRate
        );
    }
}
