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

    // function testContract() public {
    //     vm.deal(msg.sender,10e18);
    //     payable(address(K_ether)).transfer(3e18);
    //     payable(address(K_attack)).transfer(3e18);
    //     K_attack.attack();
    // }

    function depositPoint() public {
        vm.deal(address(999),10e18);
        vm.deal(address(333),10e18);
        vm.deal(address(787),7e18);

        vm.warp(K_ether.startTime()+ 2 days);

        vm.prank(address(999));
        K_ether.deposit{value:5e18}(5e18);

        vm.prank(address(333));
        K_ether.deposit{value:7e18}(7e18);

         vm.prank(address(787));
        K_ether.deposit{value:6e18}(6e18);

    }

    function test_withdrawal() public {
        depositPoint();
        vm.warp(K_ether.startTime()+ 30 days);
        K_ether.gameFinished();
        // vm.prank(address(999));
        // K_ether.withdraw();
        //  console2.log(K_ether.winner(),K_ether.balances(K_ether.winner()));

        while(K_ether.winner()==address(333)){
            vm.prank(address(999));
            K_ether.withdraw();
            console2.log(K_ether.winner(),K_ether.balances(K_ether.winner()));

            continue;
        }
    }
}