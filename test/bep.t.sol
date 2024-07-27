// SPDX-License-Identifier: MIT
pragma solidity >0.4.0 <= 0.9.0;

import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import {BEP20Token} from "../src/BEP20.sol";

contract BEPTest is Test{
    BEP20Token bep;

    function setUp() public {
        bep = new BEP20Token();
    }

    /**
     * Turns out i was right 
     * from the test you can see it reverts but money is still sent
     * check balance of address(0xabc)
     * also analyse the bal of sender and receiver logged
     */
    function test_send_with_allowance() public {
        vm.startPrank(address(this));
        bool ok = bep.mint(20e8);
        require(ok);

        bep.approve(address(0x123),15e8);
        vm.stopPrank();

        vm.startPrank(address(0x1113));
        bep.transferFrom(address(this),address(0xabc),17e8);

        console2.log(bep.balanceOf(address(0xabc)));

        assertEq(bep.balanceOf(address(this)),1000000000000000e18+3e8);
        assertEq(bep.balanceOf(address(0xabc)),17e8);

        vm.stopPrank();
    }

    /**
     * I was right! tokens can only be minted to owners
     * In standard implementation its not the same
     * see that it reverts when we try to mint to a different user
     * it can be argued as intended design but as compared to the standard its a pitfall 
     */
    function test_reverts_mint_notOwner() public {
        vm.prank(address(45));
        bool ok = bep.mint(10e8);
        require(ok);
    }
}