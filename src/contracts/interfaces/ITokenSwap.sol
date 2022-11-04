// SPDX-License-Identifier: MIT

pragma solidity >=0.6.8;

interface ITokenSwap {
 
    struct NewOrder {
        address maker;
        uint256 amount;
        uint256 rate;
    }
    function atob(uint256 b, uint256 a) external;
    function atobInverseRate(uint256 b, uint256 a) external;

    function btoa(uint256 a, uint256 b) external;
    function btoaInverseRate(uint256 a, uint256 b) external;

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

    event ATokensSent(
        address accountSent,
        address accountReceived,
        uint256 amount
    );
        event BTokensSent(
        address accountSent,
        address accountReceived,
        uint256 amount
    );
}
