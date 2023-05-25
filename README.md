# Smart-contracts
## API
## ERC721 Token smart contract (BTOT)
### Structure of token:
- serialNumber - serial number to which the token belongs
- expirationTime - timestamp in seconds (GMT)
- price - IPO price that investor has to pay to buy this token
- profit - the price at which the bank will buy the token from the investor when it expires.
- isPresented - this token is presented in mapping (set always as true, this is solidity specifics)
### setApprovalForAll - allow Bank Manager to freely work with your tokens without approvals
***Public***
***
***Args***

address spender - contract's address

bool approved - whether operator can transfer tokens without approval
***
***Returns***

no return value
***
### emitTokens - emit new tokens for selling
***Only for owner***
***
***Args***

uint256 tokenId - id of the first token that would be emitted

uint256 amount - number of tokens to emit

TokenListing data - token structure
***
***Returns***

reverted - one of the token id-s is occupied
***
### isExpired - check if token has expired 
***Public***
***
***Args***

uint256 tokenId - id of the token you want to check
***
***Returns***

bool - whether token has expired

reverted - token with such id doesn't exist
***
### getPrice - returns purchase price for the investor
***Public***
***
***Args***

uint256 tokenId - id of the token
***
***Returns***

uint256 - the price of token

reverted - token with such id doesn't exist
***
### getProfit - returns price at which bank will redeem token from investor
***Public***
***
***Args***

uint256 tokenId - id of the token
***
***Returns***

uint256 - the price of token

reverted - token with such id doesn't exist
***
### getToken - get TokenListing object
***Public***
***
***Args***

uint256 tokenId - id of the token
***
***Returns***

TokenListing - the token with passed id

reverted - token with such id doesn't exist
***
## ERC20 Currency smart contract (BTOC)
### mint - mint tokens to address
***Only for owner***
***
***Args***

address to - wallet's address to which you want to mint

uint256 amount - number of tokens to mint
***
***Returns***

no return value
***
### increaseAllowance - allow Bank Manager spend more tokens
***Public***
***
***Args***

address spender - contract's address

uint256 addedValue - allowed amount to spend
***
***Returns***

no return value
***
## BankManager

### constructor
***Args***

address currency - address of ERC20 smart contract

address token - address of ERC721 smart contract

### buyToken - buy batch of tokens
***Public***
***
***Args***

uint256 startId - id of the first token (included)

uint256 endId - id of the last token (included)
***
***Returns***

reverted - right bound is less than left one

reverted - address that calls this function already owns token with one of the ids in given interval

reverted - payment amount exceeds balance

reverted - payment amount exceeds allowed amount to spend from wallet

reverted - didn't set allowance to transfer BTOT-s
***
### expireToken - bank redeems tokens from investors
***Only for owner***
***
***Args***

uint256 startId - id of the first token (included)

uint256 endId - id of the last token (included)
***
***Returns***

reverted - right bound is less than left one

reverted - address that calls this function already owns token with one of the ids in given interval

reverted - one of the tokens hasn't expired yet

reverted - payment amount exceeds balance

reverted - payment amount exceeds allowed amount to spend from wallet

reverted - didn't set allowance to transfer BTOT-s
***
