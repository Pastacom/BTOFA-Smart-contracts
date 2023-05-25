// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BTOFACurrency is ERC20, Ownable {

    // Set token's symbol and name.
    constructor() ERC20("BTOFACurrency", "BTOC") {}

    // Mint currency to passed address.
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}