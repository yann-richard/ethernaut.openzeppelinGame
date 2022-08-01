# EthernautChallenges

## Solution:
### Level 1 Fallback:
Solidity documentation release 0.8.0 :<br/>
*"A contract can have at most one fallback function, declared using fallback () external [payable] (without the function keyword). This function cannot have arguments, cannot return anything and must have external visibility. It is executed on a call to the contract if none of the other functions match the given function signature, or if no data was supplied at all and there is no receive Ether function. The fallback function always receives data, but in order to also receive Ether it must be marked payable."* 

*"msg.value (uint): number of wei sent with the message"* 

In the case of this contract, in order to execute the fallback function we need to pass the require condition: <br/>
*require (msg.value > 0 && contributions[msg.sender] > 0)*<br/>
Therefore, before calling the fallback function with an amount attached to it, we also need to increase our contributions (using the *contribute* function). Once that’s done we will become the new owner of the contract. We can then use the *withdraw* function to reduce its balance to 0.

We will solve this challenge using the following command in the console (can be access by clicking F12):<br/>
*await contract.owner()*<br/>
*player*<br/>
*await contract.contributions(player)*<br/>
*await contract.contribute({value:1})*<br/>
*await contract.contributions(player)*<br/>
*await contract.sendTransaction({value:1})*<br/>
*await contract.owner()*<br/>
*player*<br/>
*await contract.withdraw()*<br/>

### Level 2 Fallout:
Solidity documentation release 0.8.0 :<br/>
*"A constructor is an optional function declared with the constructor keyword which is executed upon contract 
creation, and where you can run contract initialisation code."*  <br/>
*“Prior to version 0.4.22, constructors were defined as functions with the same name as the contract. This syntax 
was deprecated and is not allowed anymore in version 0.5.0.”* 

In this contract, the constructor syntax is deprecated and misspelled (fal1out written with the number 1 instead of 
the letter l). Therefore, to claim ownership of this contract you just need to call the *fal1out* function.

### Level 3 CoinFlip:
Solidity documentation release 0.8.0 :<br/>
*“A blockchain is a globally shared, transactional database. This means that everyone can read entries in the database
just by participating in the network”* <br/>
*“Everything you use in a smart contract is publicly visible, even local variables and state variables marked private.
Using random numbers in smart contracts is quite tricky if you do not want miners to be able to cheat.”* 

Ethereum Yellow paper:<br/>
*“Providing random numbers within a deterministic system is, naturally, an impossible task. However, we can approximate with pseudo-random numbers by utilising data which is generally unknowable at the time of transacting. Such data might include the block’s hash, the block’s timestamp and the block’s beneficiary address”.*

In this case, the block number is knowable at the time of transacting. Thus, we can create a malicious contract (Level3_III237HackCoinFlip.sol) that computes the right guess and use this value to call the *flip* function of the CoinFlip contract (before a new block gets mined). Therefore, we are able to guess the right outcome everytime.


### Level 4 Telephone:
Solidity documentation release 0.8.0 :<br/>
*“msg.sender (address payable): sender of the message (current call)”* <br/>
*“tx.origin (address payable): sender of the transaction (full call chain)”*  

In other words, *tx.origin* is the original address that sends a transaction while *msg.sender* is the current (i.e. last, closest) sender of a message. For instance, assume user/contract A calls contract B which triggers it to call contract C which triggers it to call contract D, we have the following: 

![tel_graph2](https://user-images.githubusercontent.com/61462365/76195000-a9109f80-61e7-11ea-81ab-585464e51b3d.png)

To solve this level, we (the user) will call the function of a malicious contract (Level4_III237HackTelephone.sol) that will call the *changeOwner* function of the Telephone contract. Thus, for the Telephone contract: *tx.origin* (= user’s address)  *≠* *msg.sender* (= malicious contract’s address). This will allow us to pass the if statement and become the new owner of the contract. 

### Level 5 Token:
Solidity documentation release 0.8.0 :<br/>
*“As in many programming languages, Solidity’s integer types are not actually integers. They resemble integers when the values are small, but behave differently if the numbers are larger. For example, the following is true: uint8(255)+ uint8(1) == 0.  This situation is called an overflow.  It occurs when an operation is performed that requires a fixed size variable to store a number (or piece of data) that is outside the range of the variable’s data type. An underflow is the converse situation:uint8(0) - uint8(1) == 255”* <br/>

As suggested by the level, it’s similar to how an odometer (instrument measuring the distance traveled by a vehicle)
works:

![Explanation2](https://user-images.githubusercontent.com/61462365/76195124-e9701d80-61e7-11ea-8102-d60b79b4b89b.png)

To solve this level we will perform an underflow by using the *transfer* function with the following two inputs: another address (than the one we are currently using , for example take other address on etherscan) and a number bigger than 20 (= amount of tokens given). We used the following command in the console:<br/>
```
await contract.balanceOf(player) 
await contract.transfer("0xab5801a7d398351b8be11c439e05c5b3259aec9b", 21)
await contract.balanceOf(player)
```

### Level 6 Delegation:
Solidity documentation release 0.8.0 :<br/>
*“There exists a special variant of a message call, named delegatecall which is identical to a message call apart from 
the fact that the code at the target address is executed in the context of the calling contract and msg.sender and
msg.value do not change their values. This means that a contract can dynamically load code from a different address 
at runtime.  Storage, current address and balance still refer to the calling contract, only the code is taken from the 
called address. This makes it possible to implement the “library” feature in Solidity:  Reusable library code that can be
applied to a contract’s storage, e.g. in order to implement a complex data structure”* p. 13<br/>
*“The first four bytes of the call data for a function call specifies the function to be called. It is the first (left, high-order in big-endian) four bytes of the Keccak-256 (SHA-3) hash of the signature of the function. The signature is defined as 
the canonical expression of the basic prototype without data location specifier”* p. 179  <br/>
*“Any interaction with another contract imposes a potential danger, especially if the source code of the contract  
is not known in advance.”* p. 78<br/>

In other words, by using a delegatecall you let another contract’s code run inside the calling contract. This code is 
executed using the calling contract state (i.e. data, variables) and can potentially modify it. It’s a double-edged sword. 
Here is an example:

![Explanation2](https://user-images.githubusercontent.com/61462365/76687833-f77acf80-6627-11ea-9839-da28720ee233.png)

To solve this level we will use the pwn function in the context of the Delegation contract by using a delegatecall
(located in its fallback function). In order to precisely call the pwn function, we need to pass its function signature 
(i.e. first four bytes of the Keccak-256 hash). 

or Since msg.sender, msg.data, msg.value are all persisted when executing a DelegateCall, all you had to do was pass malicious msg.data, i.e. the encoded payload of the pwn() function to get the property of the Delegationcontract you can directly in console do this :

```
let payload = web3.eth.abi.encodeFunctionSignature({
    name: 'pwn',
    type: 'function',
    inputs: []
});

await web3.eth.sendTransaction({
    from: player,
    to: instance,
    data: payload
});
```

### Key Security Takeaways <br/>
Use the higher level call() function to inherit from libraries, especially when you <br/>
i) don’t need to change contract storage and <br/>
ii) do not care about gas control. When inheriting from a library intending to alter your contract’s storage, make sure to line up your storage slots with the library’s storage slots to avoid these edge cases.<br/>
Authenticate and do conditional checks on functions that invoke delegatecalls. <br/>


Here are some useful links:
* [OpenZeppelin Forum](https://forum.openzeppelin.com/t/ethernaut-community-solutions/561)
* [Solidity documentation](https://solidity.readthedocs.io/en/latest/)
* [Ethereum Yellow Paper](https://ethereum.github.io/yellowpaper/paper.pdf)
* [Mastering Ethereum](https://github.com/ethereumbook/ethereumbook)


