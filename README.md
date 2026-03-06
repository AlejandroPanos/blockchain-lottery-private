# Blockchain Lottery System

A decentralized lottery platform built on Ethereum using ERC20 tokens. Players purchase tokens with ETH, buy lottery tickets, and compete for a jackpot prize. The winner is randomly selected and receives all accumulated tokens.

## Overview

This project demonstrates a complete token-based lottery economy on the blockchain. Players exchange ETH for lottery tokens, purchase numbered tickets, and have a chance to win the entire jackpot. All transactions are transparent and verifiable on-chain.

## Features

### Token System

- **Buy Tokens**: Exchange ETH for lottery tokens (1:1 ratio)
- **Return Tokens**: Cash out unused tokens for ETH
- **Token Tracking**: View personal token balance and jackpot size
- **Token Minting**: Owner can create additional tokens for the lottery pool

### Lottery Mechanics

- **Purchase Tickets**: Buy numbered lottery tickets with tokens (5 tokens per ticket)
- **Random Numbers**: Each ticket receives a unique random number (0-9999)
- **Ticket History**: Track all purchased tickets
- **Winner Selection**: Owner draws a random winner from all tickets sold
- **Jackpot Payout**: Winner receives all tokens in the owner's address

### Transparency

- All ticket purchases emit events
- Winner announcement broadcast on-chain
- Complete transaction history available

## Tech Stack

- **Solidity** ^0.8.0
- **ERC20** Token Standard (custom implementation)
- **SafeMath** Library for secure arithmetic
- **Ethereum** Blockchain
- **Keccak256** for random number generation

## Project Structure

```
├── ERC20.sol          # Custom ERC20 token (ERC20AZ)
├── SafeMath.sol       # Arithmetic overflow protection
└── Lottery.sol        # Main lottery logic
```

## How It Works

### 1. Token Purchase Flow

```
Player sends ETH → Receives lottery tokens → Can now buy tickets
```

### 2. Ticket Purchase Flow

```
Select number of tickets → Pay with tokens → Receive random ticket numbers → Wait for draw
```

### 3. Winner Selection Flow

```
Owner triggers draw → Random ticket selected → Winner receives jackpot → Cycle resets
```

## Smart Contract Functions

### For Players:

```solidity
buyTokens(uint _numTokens)           // Purchase tokens with ETH
checkPersonalTokens()                // Check your token balance
buyTickets(uint _numTickets)         // Buy lottery tickets (5 tokens each)
checkTickets()                       // View your ticket numbers
returnTokens(uint _numTokens)        // Convert tokens back to ETH
```

### For Owner:

```solidity
generateTokens(uint _numTokens)      // Mint new tokens
createWinner()                       // Randomly select winner and distribute jackpot
jackpotTokens()                      // View current jackpot size
```

### View Functions:

```solidity
availableTokens()                    // Check tokens available for purchase
ticketPrice()                        // Current price per ticket (5 tokens)
```

## Example Usage

```solidity
// 1. Player buys 100 tokens
buyTokens(100) payable { value: 100 ether }

// 2. Check balance
checkPersonalTokens()  // Returns: 100

// 3. Buy 10 lottery tickets
buyTickets(10)  // Costs 50 tokens (5 per ticket)

// 4. View your tickets
checkTickets()  // Returns: [3847, 1092, 8736, ...]

// 5. Check remaining tokens
checkPersonalTokens()  // Returns: 50

// 6. Owner draws winner
createWinner()  // Randomly selects winning ticket

// 7. Winner receives jackpot automatically!
```

## Lottery Economics

| Item        | Price      | Details                        |
| ----------- | ---------- | ------------------------------ |
| **Tokens**  | 1 ETH each | 1:1 exchange rate              |
| **Ticket**  | 5 tokens   | Each ticket gets unique number |
| **Jackpot** | Variable   | All tokens held by owner       |

**Flow of Tokens:**

1. Players buy tokens from contract → Contract's token balance decreases
2. Players buy tickets → Tokens transfer to owner → Jackpot grows
3. Winner selected → Entire jackpot transfers to winner
4. Players can cash out unused tokens anytime

## Security Features

- **Access Control**: Only owner can generate tokens and select winners
- **SafeMath Integration**: Prevents arithmetic overflow/underflow
- **Balance Verification**: Ensures sufficient tokens before transactions
- **Proper ETH Handling**: Uses `.call()` for safe ETH transfers
- **Event Emissions**: All major actions logged on-chain

## Events

Track lottery activity through emitted events:

- `BuyTokens` - Player purchases tokens
- `TicketBought` - Lottery ticket purchased (includes ticket number and buyer)
- `Winner` - Winning ticket number announced
- `TokensReturned` - Player cashes out tokens

## Key Concepts Demonstrated

- **ERC20 Token Integration** - Custom token with specialized lottery functions
- **Randomness on Blockchain** - Keccak256-based random number generation
- **Token Economics** - Buy, spend, win, and cash-out mechanisms
- **Mapping & Arrays** - Ticket tracking and winner selection
- **Access Control** - Owner-only administrative functions
- **Event-Driven Architecture** - Transparent activity logging

## Contract Details

### ERC20AZ Token

- **Name**: ERC20AZ
- **Symbol**: ERC
- **Decimals**: 2
- **Initial Supply**: 10,000 tokens
- **Special Function**: `transferLottery()` for seamless lottery transactions

### Lottery Contract

- **Ticket Price**: 5 tokens (fixed)
- **Ticket Range**: 0 - 9,999
- **Winner Selection**: Pseudo-random using keccak256

## Important Notes

### Random Number Generation

This lottery uses **pseudo-random** number generation based on `block.timestamp` and `keccak256`. This is:

- ✅ Sufficient for educational purposes
- ⚠️ **NOT cryptographically secure** for production
- ⚠️ Potentially predictable by miners

**For production**, use:

- Chainlink VRF (Verifiable Random Function)
- Commit-reveal schemes
- External randomness oracles

### Known Limitations

- Winner selection is centralized (owner-triggered)
- No automatic payout mechanism
- Pseudo-random numbers not suitable for high-stakes gambling
- No protection against owner not calling `createWinner()`
- Jackpot goes to single winner (no prize tiers)

## Game Flow Example

```
Round 1:
├─ Alice buys 100 tokens (100 ETH)
├─ Alice buys 5 tickets (25 tokens)
│  └─ Tickets: [1234, 5678, 9012, 3456, 7890]
├─ Bob buys 50 tokens (50 ETH)
├─ Bob buys 3 tickets (15 tokens)
│  └─ Tickets: [2468, 1357, 8024]
├─ Charlie buys 200 tokens (200 ETH)
├─ Charlie buys 10 tickets (50 tokens)
│  └─ Tickets: [...]
├─ Total tickets: 18
├─ Jackpot: 90 tokens (5×18)
├─ Owner draws winner → Ticket #1357
└─ Bob wins 90 tokens! 🎉
```

## License

MIT

---

**⚠️ Educational Project Notice:**  
This lottery implementation is for **educational purposes only**. It demonstrates blockchain concepts but is **not suitable for real gambling applications** due to:

- Centralized winner selection
- Pseudo-random number generation
- Lack of regulatory compliance
- No player protection mechanisms
