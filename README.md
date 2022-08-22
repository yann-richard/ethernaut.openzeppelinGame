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

```
await contract.owner()
player
await contract.contributions(player)
await contract.contribute({value:1})
await contract.contributions(player)
await contract.sendTransaction({value:1})
await contract.owner()
player
await contract.withdraw()
```

### Level 2 Fallout:
Solidity documentation release 0.8.0 :<br/>
*"A constructor is an optional function declared with the constructor keyword which is executed upon contract 
creation, and where you can run contract initialisation code."*  <br/>
*“Prior to version 0.4.22, constructors were defined as functions with the same name as the contract. This syntax 
was deprecated and is not allowed anymore in version 0.5.0.”* 

In this contract, the constructor syntax is deprecated and misspelled (fal1out written with the number 1 instead of 
the letter l). Therefore, to claim ownership of this contract you just need to call the *fal1out* function.

```
await contract.Fal1out({value: 1337});
```

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
applied to a contract’s storage, e.g. in order to implement a complex data structure”* <br/>
*“The first four bytes of the call data for a function call specifies the function to be called. It is the first (left, high-order in big-endian) four bytes of the Keccak-256 (SHA-3) hash of the signature of the function. The signature is defined as 
the canonical expression of the basic prototype without data location specifier”*   <br/>
*“Any interaction with another contract imposes a potential danger, especially if the source code of the contract  
is not known in advance.”* <br/>

example of explanation :<br/>
In other words, by using a delegatecall you let another contract’s code run inside the calling contract. This code is 
executed using the calling contract state (i.e. data, variables) and can potentially modify it. It’s a double-edged sword. 
Here is an example:

![Explanation2](https://user-images.githubusercontent.com/61462365/76687833-f77acf80-6627-11ea-9839-da28720ee233.png)

To solve this level DelegateCall means you take the implementation logic of the function in the contract you're making this call to but using the storage of the calling contract. Since msg.sender, msg.data, msg.value are all preserved when performing a DelegateCall, you just needed to pass in a malicious msg.data i.e. the encoded payload of `pwn()` function to gain ownership of the `Delegation` contract. you can directly in console do this :

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


### Level 7 Force:
Solidity documentation release 0.8.0 :<br/>
*“A contract without a receive Ether function can receive Ether as a recipient of a coinbase transaction (aka miner 
block reward) or as a destination of a selfdestruct. A contract cannot react to such Ether transfers and thus also 
cannot reject them. This is a design choice of the EVM and Solidity cannot work around it.”* <br/>

To solve this level we will deploy a malicious contract (Level7_III237HackForce.sol) and send some fund to it.Even if a contract doesn't implement a receive / fallback or any payable functions to handle incoming ETH, it is still possible to forcefully send ETH to a contract through the use of `selfdestruct`. If you're deploying this malicious contract through remix, don't forget to specify value before deploying the Attack to Force contract or the `selfdestruct` won't be able to send any ETH over as there are no ETH in the contract to be sent over! Then, we will designate the Force contract as owner of the malicious contract and destroy our malicious contract. Thus, sending fund to the Force 
contract that cannot be rejected.

## 8. Vault

Solidity documentation release 0.8.0 :<br/>
*“Everything that is inside a contract is visible to all observers external to the blockchain. Making something private
only prevents other contracts from reading or modifying the information, but it will still be visible to the whole world 
outside of the blockchain.”* <br/>
*“Even if a contract is removed by “selfdestruct”, it is still part of the history of the blockchain and probably retained 
by most Ethereum nodes. So, using “selfdestruct” is not the same as deleting data from a hard disk.”* <br/>
*“Statically-sized variables (everything except mapping and dynamically-sized array types) are laid out contiguously in
storage starting from position 0. Multiple, contiguous items that need less than 32 bytes are packed into a single 
storage slot if possible [...] ”.* <br/>

Everything you use in a smart contract is publicly visible. Moreover, keep in mind that a blockchain is an **append-only
ledger**. If you change the state of your contract or even destroy it, it will still be part of the history of the blockchain. 
Thus, everyone can have access to it. <br/>


Your private variables are private if you try to access it the normal way e.g. via another contract but the problem is that everything on the blockchain is visible so even if the variable's visibility is set to private, you can still access it based on its index in the smart contract. Learn more about this [here](https://docs.soliditylang.org/en/latest/internals/layout_in_storage.html).
To solve this level do this : 

```
const password = await web3.eth.getStorageAt(instance, 1); //access the state and get the value stored at slot 1 (slot 0 contains the bool 
//value)
await contract.unlock(password); //unlock the vault by using the function unlock with the value of password as argument
```



## 9. King
This is a classic example of DDoS with unexpected revert when the logic of the victim's contract involve sending funds to the previous "lead", which in this case is the king. A malicious user would create a smart contract with either:

- a `fallback` / `receive` function that does `revert()`
- or the absence of a `fallback` / `receive` function

Once the malicious user uses this smart contract to take over the "king" position, all funds in the victim's contract is effectively stuck in there because nobody can take over as the new "king" no matter how much ether they use because the fallback function in the victim's contract will always fail when it tries to do `king.transfer(msg.value);`
```


### Level 10 Re-entrancy:<br/>
Solidity documentation :<br/>
*“You should avoid using .call() whenever possible when executing another contract function as it bypasses type 
checking, function existence check, and argument packing.”* <br/>
*“Any interaction with another contract imposes a potential danger, especially if the source code of the contract  
is not known in advance. The current contract hands over control to the called contract and that may potentially do 
just about anything.”* <br/>
<br/>
In order to solve this level we will create a malicious contract with a fallback function that calls back the withdraw 
function. Thus, this will prevent the withdraw function completion until all the contract funds are drained (as shown 
below). Before calling the withdraw function we need to increase the balance of our malicious contract (by using 
the donate function of the Reentrance contract).

![reentrance](https://user-images.githubusercontent.com/61462365/77301685-6921e000-6cf0-11ea-90be-f94aac620b29.png)

### Level 11 Elevator:<br/>
Solidity documentation :<br/>
*“Interfaces are similar to abstract contracts, but they cannot have any functions implemented.”*<br/>
*“All functions declared in interfaces are implicitly virtual, which means that they can be overridden. This does
not automatically mean that an overriding function can be overridden again  - this is only possible if the 
overriding function is marked virtual.”* <br/>

To solve this level we will create a malicious contract that will implement the *isLastFloor* function. Then we 
will invoke the *goTo* function from the malicious contract. This will ensure that it’s the *isLastFloor* function from the malicious contract that will be used. The *isLastFloor* function needs to return false the first time it’s called (to pass the if statement) and true the second time it’s called (to change the boolean top value to true).




## 12. Privacy
This level is very similar to that of the level 8 Vault. In order to unlock the function, you need to be able to retrieve the value stored at `data[2]`. To do that, we need to determine the position of where `data[2]` is stored on the contract.

I used to link the solidity docs but the path keeps changing so just google "storage layout solidity docs" and find the latest one to read.

From the docs, we can tell that `data[2]` is stored at index 5. Index 0 contains the value for `locked`, index 1 contains the value for `ID`, index 2 contains the values for `flattening`, `denomination` and `awkwardness` (they're packed together to fit into a single bytes32 slot), index 3 contains the value for `data[0]` and finally, index 4 contains the value for `data[1]`.

Astute readers will also notice that the password is actually casted to bytes16! So you'd need to know what gets truncated when you go from bytes32 to byets16. You can learn about what gets truncated during type casting [here](https://www.tutorialspoint.com/solidity/solidity_conversions.htm).

```
var data = await web3.eth.getStorageAt(instance, 5);
var key = '0x' + data.slice(2, 34);
await contract.unlock(key);
```

```
Key Security Takeaways
1. In general, excessive slot usage wastes gas, especially if you declared structs that will reproduce many instances. Remember to optimize your storage to save gas!
2. Save your variables to memory if you don’t need to persist smart contract state. SSTORE <> SLOAD are very gas intensive opcodes.
3. All storage is publicly visible on the blockchain, even your privatevariables!
4. Never store passwords and private keys without hashing them first

```


Here are some useful links:
* [OpenZeppelin Forum](https://forum.openzeppelin.com/t/ethernaut-community-solutions/561)
* [Solidity documentation](https://solidity.readthedocs.io/en/latest/)
* [Ethereum Yellow Paper](https://ethereum.github.io/yellowpaper/paper.pdf)
* [Mastering Ethereum](https://github.com/ethereumbook/ethereumbook)


