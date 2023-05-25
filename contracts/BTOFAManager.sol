// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

interface IBTOFAToken is IERC721 {
    function isExpired(uint256 tokenId) external view returns (bool);
    function burn(uint256 tokenId) external;
    function getPrice(uint256 tokenId) external view returns(uint256);
    function getProfit(uint256 tokenId) external view returns(uint256);
}

contract BankManager is IERC721Receiver, Ownable {

    IERC20 private _BTOFACurrency;
    IBTOFAToken private _BTOFAToken;

    // Getting access to other contracts' functions.
    constructor(address currency, address token) {
        _BTOFACurrency = IERC20(currency);
        _BTOFAToken = IBTOFAToken(token);
    }

    // Try to buy all tokens with id-s lying in [startId; endId].
    function buyToken(uint256 startId, uint256 endId) external {
        // Right bound can't be less than the left one. If so function is reverted.
        require(startId <= endId, "BANK MANAGER: Right ID's bound is less than left one.");
        uint256 price = 0;
        
        // Calculating total price to pay.
        for (uint256 tokenId = startId; tokenId <= endId; ++tokenId) {
            price += _BTOFAToken.getPrice(tokenId);
            // Check if owner of token with tokenId is not the address that is requesting to buy this token. If so function is reverted.
            require(msg.sender != _BTOFAToken.ownerOf(tokenId),
                    string(abi.encodePacked("BTOT: User already is an owner of token with ID ", Strings.toString(tokenId), ".")));
        }

        // Check if buyer has enough funds to buy all of this tokens. Otherwise function is reverted.
        require(_BTOFACurrency.balanceOf(msg.sender) >= price, "BTOC: Insufficient amount of tokens.");
        // Check if buyer set allowance limit to spend for this contract equal or greater than total price. Otherwise function is reverted.
        require(_BTOFACurrency.allowance(msg.sender, address(this)) >= price, "BTOC: Insufficient allowed amount of tokens to spend.");

        // Transfer currency tokens.
        _BTOFACurrency.transferFrom(msg.sender, owner(), price);
        
        // Transfer all tokens with passed id-s.
        for (uint256 tokenId = startId; tokenId <= endId; ++tokenId) {
            _BTOFAToken.safeTransferFrom(owner(), msg.sender, tokenId);
        }
    }

    // Bank claims that it will redeem expired tokens and pay investors.
    function expireToken(uint256 startId, uint256 endId) public onlyOwner {
        uint256 price = 0;
        // Right bound can't be less than the left one. If so function is reverted.
        require(startId <= endId, "BANK MANAGER: Right ID's bound is less than left one.");
        
        // Calculating total price to pay.
        for (uint256 tokenId = startId; tokenId <= endId; ++tokenId) {
            price += _BTOFAToken.getProfit(tokenId);
            require(_BTOFAToken.isExpired(tokenId), "BTOT: Token with such ID hasn't expired yet.");
        }

        // Check if bank has enough funds to buy all of this tokens. Otherwise function is reverted.
        require(_BTOFACurrency.balanceOf(owner()) >= price, "BTOC: Insufficient amount of tokens.");
        // Check if bank set allowance limit to spend for this contract equal or greater than total price. Otherwise function is reverted.
        require(_BTOFACurrency.allowance(owner(), address(this)) >= price, "BTOC: Insufficient allowed amount of tokens to spend.");
        // Transfer currency tokens.
        _BTOFACurrency.transferFrom(owner(), _BTOFAToken.ownerOf(startId), price);
        
        // Transfer all tokens with passed id-s and burn them.
        for (uint256 tokenId = startId; tokenId <= endId; ++tokenId) {
            _BTOFAToken.safeTransferFrom(_BTOFAToken.ownerOf(tokenId), owner(), tokenId);
            _BTOFAToken.burn(tokenId);
        }
    }

    function onERC721Received(address, address, uint256, bytes calldata) external override pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}
