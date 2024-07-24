// SPDX-License-Identifier:MIT
pragma solidity ^0.8.14;

import {Test} from "forge-std/Test.sol";
import {console2}from "forge-std/console2.sol";
import {Vesting} from "../src/Vesting.sol";
import {tokenMock} from "../src/token.sol";

contract vestTest is Test{
    Vesting vest;
    tokenMock token;

    address deployer;
    address bene=address(0x123);
    address bene1=address(0x456);
    uint256 timeDeployed;
    function setUp() public {
        deployer = address(this);
        token = new tokenMock();

        uint256 cliffMnthDuration = 2;
        uint256 vestMnthDuration = 4;
        

        address[] memory accounts = new address[](2);
        accounts[0]=bene;
        accounts[1]=bene1;

        uint256[] memory amounts = new uint256[](2);
        amounts[0]=10000e7;
        amounts[1] = 2000e18;

        timeDeployed = block.timestamp;
        vest = new Vesting(address(token),cliffMnthDuration,vestMnthDuration,accounts,amounts);

        token.mint(address(vest),10000e18);
    }

    /**
     * This test proves due to rounding error the protocol always reverts on releasing already locked small amounts
     */
    function testRelease() public{
        vm.startPrank(bene);
        uint64 warptime =4 * 4 weeks;

        vm.warp(warptime);
        vest.release();
        vm.stopPrank();
    }
    /**
     * user can redeem more than he has locked
     */
    function test_userCanRedeemMore() public {
        vm.startPrank(bene);
        uint64 warptime = 1000000007 * 4 weeks;

        vm.warp(warptime+timeDeployed);
        vest.release();
        console2.log(vest.checkVar());
        vm.stopPrank();
    }
}