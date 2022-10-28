pragma solidity ^0.5.0;

import "./CoolToken.sol";
import "./SecondToken.sol";

contract EthSwap {
    string public name = "EthSwap Instant Exchange";
    CoolToken public coolToken; // variable that represents token smart contract.
    uint256 public coolRate = 100; //uint means unsigned, no decimal and positive

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

    constructor(CoolToken _coolToken, SecondToken _secondToken) public {
        //pass the address of the Token in
        coolToken = _coolToken;
        secondToken = _secondToken;
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
        require(coolRate >= _rate, "fail");
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

    function limitSellCoolTokens(uint256 _amount, uint256 _rate) public {
        require(coolRate <= _rate, "fail");
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

    function buySecondTokens(uint256 _coolAmount) public {
        // Check if there is sufficient cool token in buyer acc
        require(coolToken.balanceOf(msg.sender) >= _coolAmount);
        // Calculate the amount of cool token to redeem
        uint256 secondAmount = _coolAmount * secondRate;
        // Check that there is enough seocond Token in ethSwap
        require(secondToken.balanceOf(address(this)) >= secondAmount);

        // Perform sale (this 2 method might be the problem)
        // secondToken.transferFrom(address(this), msg.sender, secondAmount);
        secondToken.transfer(msg.sender, secondAmount);
        coolToken.transferFrom(msg.sender, address(this), _coolAmount);
        // Emit an event
        emit SecondTokensPurchased(
            msg.sender,
            address(secondToken),
            secondAmount,
            secondRate
        );
    }

    function limitBuySecondTokens(uint256 _coolAmount, uint256 _secondRate)
        public
    {
        require(secondRate >= _secondRate, "fail");
        // Check if there is sufficient cool token in buyer acc
        require(coolToken.balanceOf(msg.sender) >= _coolAmount);
        // Calculate the amount of cool token to redeem
        uint256 secondAmount = _coolAmount * secondRate;
        // Check that there is enough seocond Token in ethSwap
        require(secondToken.balanceOf(address(this)) >= secondAmount);

        // Perform sale (this 2 method might be the problem)
        // secondToken.transferFrom(address(this), msg.sender, secondAmount);
        secondToken.transfer(msg.sender, secondAmount);
        coolToken.transferFrom(msg.sender, address(this), _coolAmount);
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
        require(coolToken.balanceOf(address(this)) >= coolAmount);

        // Check if there is sufficient second token in buyer acc
        require(secondToken.balanceOf(msg.sender) >= _secondAmount);

        // Perform sale
        secondToken.transferFrom(msg.sender, address(this), _secondAmount);
        coolToken.transfer(msg.sender, coolAmount);

        // Emit an event
        emit SecondTokensSold(
            msg.sender,
            address(secondToken),
            _secondAmount,
            secondRate
        );
    }

    function limitSellSecondTokens(uint256 _secondAmount, uint256 _secondRate)
        public
    {
        require(secondRate <= _secondRate, "fail");
        // Calculate the amount of cool token to redeem
        uint256 coolAmount = _secondAmount / secondRate;

        // Check that there is enough cool Token in ethSwap
        require(coolToken.balanceOf(address(this)) >= coolAmount);

        // Check if there is sufficient second token in buyer acc
        require(secondToken.balanceOf(msg.sender) >= _secondAmount);

        // Perform sale
        secondToken.transferFrom(msg.sender, address(this), _secondAmount);
        coolToken.transfer(msg.sender, coolAmount);

        // Emit an event
        emit SecondTokensSold(
            msg.sender,
            address(secondToken),
            _secondAmount,
            secondRate
        );
    }
}
