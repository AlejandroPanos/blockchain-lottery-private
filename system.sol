// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;
import {ERC20Basic} from './ERC20.sol';

/**
 * @title Lottery
 * @notice A decentralised lottery system where users buy tokens with ETH,
 * use tokens to purchase lottery tickets, and the owner selects a winner
 * who receives the entire token jackpot.
 * @dev Uses a custom ERC20Basic token for internal accounting.
 * @dev WARNING: Randomness is derived from block.timestamp and is manipulable.
 * Do not use in production — replace with Chainlink VRF.
 */
contract Lottery {
    // Custom errors
    error Lottery__NotTheOwner();
    error Lottery_TransferFailed();
    error Lottery__PriceGreaterThanAmountSent();
    error Lottery__NotEnoughBalanceAvailable();
    error Lottery__NotEnoughTokens();
    error Lottery__NoTicketsBought();

    // Initial declarations
    ERC20Basic private token;
    address public owner;
    address public smartContract;
    uint public createdTokens = 10000;

    constructor() {
        token = new ERC20Basic(createdTokens);
        owner = msg.sender;
        smartContract = address(this);
    }

    // --- Token functionality ---

    // Events
    event BuyTokens(uint, address);
    event TokensReturned(uint, address);

    // Modifiers
    modifier OnlyOwner(address _address) {
        if (_address != owner) {
            revert Lottery__NotTheOwner();
        }
        _;
    }

    // Function to establish a price
    function setTokenValue(uint _numTokens) internal pure returns(uint){
        return _numTokens * (1 ether);
    }

    // Function to generate tokens
    function generateTokens(uint _numTokens) public OnlyOwner(msg.sender) {
        token.increaseTotalSupply(_numTokens);
    }  

    // Function to check contract balance
    function availableTokens() public view returns(uint) {
        return token.balanceOf(smartContract);
    }

    // Function to allow people to buy tokens
    function buyTokens(uint _numTokens) public payable {
        
        // Calculate token price
        uint price = setTokenValue(_numTokens);

        // Check
        if (msg.value < price) {
            revert Lottery__PriceGreaterThanAmountSent();
        }

        // Check return value
        uint returnValue = msg.value - price;

        // Transfer the remainder
        (bool success, ) = payable(msg.sender).call{value: returnValue}('');
        if (!success) {
            revert Lottery_TransferFailed();
        }

        // Find token balance in contract
        uint balance = availableTokens();

        // Filter to chack if person can buy the specified amount
        if (_numTokens > balance) {
            revert Lottery__NotEnoughBalanceAvailable();
        }

        // Transfer tokens to buyer
        token.transfer(msg.sender, _numTokens);

        // Emit buy tokens event
        emit BuyTokens(_numTokens, msg.sender);
    }

    // Function to check tokens in jackpot
    function jackpotTokens() public view returns(uint){
        return token.balanceOf(owner);
    }

    // Function to allow a user to check their tokens
    function checkPersonalTokens() public view returns(uint){
        return token.balanceOf(msg.sender);
    }

    // --- Lottery functionality ---

    // Declare variables
    uint public ticketPrice = 5;
    mapping(address => uint[]) userTickets;
    mapping(uint => address) winner;
    uint randNonce = 0;
    uint[] ticketsBought;

    // Declare events
    event TicketBought(uint, address);
    event Winner(uint);

    // Function to allow users to buy tickets
    function buyTickets(uint _numTickets) public {

        // Calculate price
        uint price = _numTickets * ticketPrice;

        // Check if person has enough tokens
        if (price > checkPersonalTokens()) {
            revert Lottery__NotEnoughTokens();
        }

        // Transfer tokens to owner
        token.transferLottery(msg.sender, owner, price);

        // Generate random ticket numbers & push them to mappings and array
        for (uint i = 0; i < _numTickets; i++) {
            uint random = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce))) % 10000;
            randNonce++;
            userTickets[msg.sender].push(random);
            ticketsBought.push(random);
            winner[random] = msg.sender;
            emit TicketBought(random, msg.sender);
        }
    }

    // Function to check tickets
    function checkTickets() public view returns(uint[] memory){
        return userTickets[msg.sender];
    }

    // Function to create winner and send tokens
    function createWinner() public OnlyOwner(msg.sender){

        // Check if there are tickets sold
        if (ticketsBought.length == 0) {
            revert Lottery__NoTicketsBought();
        }

        // Declare length of array
        uint length = ticketsBought.length;

        // Randomly select a number between 0 and the length
        uint position = uint (uint(keccak256(abi.encodePacked(block.timestamp))) % length);
        
        // Select the random number
        uint result = ticketsBought[position];

        // Emit the event
        emit Winner(result);

        // Send the winner the jackpot
        address winnerAddress = winner[result];
        token.transferLottery(msg.sender, winnerAddress, jackpotTokens());
    }

    // Function to return tokens
    function returnTokens(uint _numTokens) public {

        // Check that the number of tokes is greater than 0
        require(_numTokens > 0, 'Need to return a number greater than 0');

        // User should have the tokens to be returned
        require(_numTokens <= checkPersonalTokens(), 'You do not have the required amount of tokens');

        // Client returns tokens
        token.transferLottery(msg.sender, smartContract, _numTokens);
        uint returnValue = setTokenValue(_numTokens);
        (bool success, ) = payable(msg.sender).call{value: returnValue}('');
        require(success, 'ETH transfer failed');

        // Emit event
        emit TokensReturned(returnValue, msg.sender);

    }
}