// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract BTOFAToken is ERC721, ERC721Burnable, Ownable {
    using SafeMath for uint256;

    struct TokenListing {
        uint256 serialNumber;
        uint256 expirationTime;
        uint256 price;
        uint256 profit;
        bool isPresented;
    }

    mapping(uint256 => TokenListing) private mintedTokens;

    // Set token's symbol and name.
    constructor() ERC721("BTOFAToken", "BTOT") {}

    // Creates tokens in interval [tokenId; tokenId + amount).
    // Assigns every token id to token data stored in TokenListing structure.
    // Sets smart contract's owner as an onwer of this tokens.
    function emitTokens(uint256 tokenId, uint256 amount, TokenListing memory data) external onlyOwner {
        for (uint256 i = tokenId; i < tokenId + amount; ++i) {
            // If there is token with such id, function is reverted.
            _safeMint(msg.sender, i);
            mintedTokens[i] = data;
        }
    }

    // Checks if token with such id has expired.
    function isExpired(uint256 tokenId) external view returns (bool) {
        // If there is no available token with provided id, function is reverted.
        require(mintedTokens[tokenId].isPresented, "BTOT: Token with such ID doesn't exist.");
        // Checks if time right now is equal or greater than expiration time.
        return mintedTokens[tokenId].expirationTime <= block.timestamp;
    }

    // Returns token's IPO price that investor has to pay to buy this token.
    function getPrice(uint256 tokenId) public view returns(uint256) {
        // If there is no available token with provided id, function is reverted.
        require(mintedTokens[tokenId].isPresented, "BTOT: Token with such ID doesn't exist.");
        return mintedTokens[tokenId].price;
    }

    // Returns the price at which the bank will buy the token from the investor when it expires.
    function getProfit(uint256 tokenId) public view returns(uint256) {
        // If there is no available token with provided id, function is reverted.
        require(mintedTokens[tokenId].isPresented, "BTOT: Token with such ID doesn't exist.");
        return mintedTokens[tokenId].profit;
    }

    // Returns all public data about token.
    function getToken(uint256 tokenId) external view returns(TokenListing memory) {
        // If there is no available token with provided id, function is reverted.
        require(mintedTokens[tokenId].isPresented, "BTOT: Token with such ID doesn't exist.");
        return mintedTokens[tokenId];
    }

    // Burns token with provided id.
    // Deletes token with such id from the pool of sold tokens.
    function burn(uint256 tokenId) override public {
        // If not owner of contract is calling or BTOFAManager than function is reverted.
        require(_isApprovedOrOwner(msg.sender, tokenId), "BTOT: This function is allowed only for owner.");
        _burn(tokenId);
        delete mintedTokens[tokenId];
    }
    
}
