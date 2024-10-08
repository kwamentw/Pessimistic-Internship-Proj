// This code snippet is provided by Pessimistic company.
// To apply for the internship opportunity at Pessimistic company,
// please fill out the form by visiting the following link: https://forms.gle/SUTcGi8X86yNoFnG7

// Caution: This code is intended for educational purposes only
// and should not be used in production environments.

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.6;
pragma abicoder v2;

import {OracleLibrary} from "@uniswap/v3-periphery/contracts/libraries/OracleLibrary.sol";

contract PriceGetter {
    uint256 public number;

    address public immutable usdc;
    address public constant DAI_USDC_UNI_V3_POOL = 0xF0428617433652c9dc6D1093A42AdFbF30D29f74;
    address public constant DAI = 0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1;
    uint32 internal constant TWAP_SECONDS = 1800;

    constructor(address _usdc) {
        usdc = _usdc;
    }

    function daiToUsdc(uint256 daiAmount) public view returns (uint256) {
        (int24 meanTick, ) = OracleLibrary.consult(
            DAI_USDC_UNI_V3_POOL,
            TWAP_SECONDS
        );
        return
            OracleLibrary.getQuoteAtTick(
                meanTick,
                uint128(daiAmount),
                DAI,
                usdc
            );
    }
}

// solution 1 - add the results of running the test
// Ran 1 test for test/PriceGetter.t.sol:PriceGetterTest
// [FAIL. Reason: assertion failed: 1000297385383812647497258799903 >= 1100000] test_DaiToWant() (gas: 26731)
// Traces:
//   [26731] PriceGetterTest::test_DaiToWant()
//     ├─ [18007] PriceGetter::daiToUsdc(1000000000000000000 [1e18]) [staticcall]
//     │   ├─ [11359] 0xF0428617433652c9dc6D1093A42AdFbF30D29f74::observe([1800, 0]) [staticcall]
//     │   │   └─ ← [Return] [-12748987325343 [-1.274e13], -12749484713943 [-1.274e13]], [22118353849861569444970425776022384321672 [2.211e40], 22118353849861569446175201433529713119209 [2.211e40]]
//     │   └─ ← [Return] 1000297385383812647497258799903 [1e30]
//     ├─ [0] VM::assertGt(1000297385383812647497258799903 [1e30], 900000 [9e5]) [staticcall]
//     │   └─ ← [Return] 
//     ├─ [0] VM::assertLt(1000297385383812647497258799903 [1e30], 1100000 [1.1e6]) [staticcall]
//     │   └─ ← [Revert] assertion failed: 1000297385383812647497258799903 >= 1100000
//     └─ ← [Revert] assertion failed: 1000297385383812647497258799903 >= 1100000

// Suite result: FAILED. 0 passed; 1 failed; 0 skipped; finished in 4.67s (1.53s CPU time)

// Ran 1 test suite in 6.21s (4.67s CPU time): 0 tests passed, 1 failed, 0 skipped (1 total tests)

// Failing tests:
// Encountered 1 failing test in test/PriceGetter.t.sol:PriceGetterTest
// [FAIL. Reason: assertion failed: 1000297385383812647497258799903 >= 1100000] test_DaiToWant() (gas: 26731)

// Encountered a total of 1 failing tests, 0 tests succeeded

/**
 * solution 2 - why the test did not pass?
 * The test did not pass because the second assertLt statement failed
 * i.e this line `assertLt(price, 11 * 10 ** (usdcDecimals - 1));  // price < 1.1$`
 * it failed because the price returned was greater than `11 * 10 ** (usdcDecimals - 1)` instead of being less than
 * as you can see from the test results i.e [Revert] assertion failed: 1000297385383812647497258799903 >= 1100000
 */

/**
 * solution 3 - Find a specific line in the code where calculations occur that were not expected when the test was written.
 * line 31 i.e `return OracleLibrary.getQuoteAtTick(meanTick,uint128(daiAmount),DAI,usdc)`
 */