// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {KingOfEther} from "../src/KingOfEther.sol";
import {Attacker} from "./KingOfAttack.sol";
import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";

contract KOEtherTest is Test {
    KingOfEther K_ether;
    Attacker K_attack;

    function setUp() public{
        K_ether = new KingOfEther();
        K_attack = new Attacker(address(K_ether));
    }

    function testContract() public {
        vm.deal(msg.sender,10e18);
        payable(address(K_ether)).transfer(3e18);
        payable(address(K_attack)).transfer(3e18);
        K_attack.attack();
    }

    function testContractAgain() public {
        
    }
}