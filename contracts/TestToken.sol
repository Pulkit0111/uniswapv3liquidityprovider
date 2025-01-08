// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TestToken is ERC20, Ownable {
    // Constructor sets the name and symbol of the token
    constructor(string memory name, string memory symbol) 
        ERC20(name, symbol) 
        Ownable(msg.sender)
    {}

    // Mint function that only owner can call
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    // Optional: Function to mint tokens to anyone (useful for testing)
    function faucet() public {
        _mint(msg.sender, 100 * 10**decimals()); // Mints 100 tokens to caller
    }
}

//TestToken deployed to Sepolia: 0xE59f49C92043160Aa18525eA3C9Ac70bFd035608

//Pool Address for VAL/WETH: 0x5483d76A4a67Be5D1e3977d5f9cd0Ba37931E6E8