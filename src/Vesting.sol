// This code snippet is provided by Pessimistic company.
// To apply for the internship opportunity at Pessimistic company,
// please fill out the form by visiting the following link: https://forms.gle/SUTcGi8X86yNoFnG7

// Caution: This code is intended for educational purposes only
// and should not be used in production environments.

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Vesting {
    // emits an event when the tokens are released after cliff period 
    event TokenReleased(
        address indexed account,
        address indexed token,
        uint256 amount
    );

    // the amount of locked funds and released funds
    struct Info {
        uint256 locked;
        uint256 released;
    }

    address public immutable token; // token distributed
    uint256 public immutable startTimestamp;// timestamp at which cliff starts
    uint256 internal cliffDuration; // cliff duration 
    uint256 internal vestingDuration;// vesting duration 

    // holds information of the amount of released token and locked token
    mapping(address => Info) internal _vesting;

    uint256 public checkVar;

    /**
     * @notice constructor
     * @param token_ - token address
     * @param cliffMonthDuration - cliff duration in months
     * @param vestingMonthDuration - vesting duration in months
     * @param accounts - vesting accounts
     * @param amounts - vesting amounts of accounts
     **/
    constructor(
        address token_,
        uint256 cliffMonthDuration,
        uint256 vestingMonthDuration,
        address[] memory accounts,
        uint256[] memory amounts
    ) {
        // require(cliffMonthDuration < vestingMonthDuration,"Cliff period can't be longer than vesting");
        // timestamp is initialised to the time protocol starts
        startTimestamp = uint64(block.timestamp);
        token = token_;
        // cliff duration in weeks
        cliffDuration = cliffMonthDuration * 4 weeks;
        // vesting period in weeks
        vestingDuration = vestingMonthDuration * 4 weeks;
        // loading accounts
        for (uint256 i = 0; i < accounts.length; i++) {
            _vesting[accounts[i]] = Info({locked: amounts[i], released: 0});
        }
    }

    function release() external {
        //add history by block
        address sender = msg.sender;
        //check to make sure cliff period has ended 
        require(
            block.timestamp > startTimestamp + cliffDuration,
            "cliff period has not ended yet."
        );
        // gets amount locked into vesting by user
        Info storage vestingInfo = _vesting[sender];
        // calculates amount to be taken every month till vesting is over
        uint256 amountByMonth = vestingInfo.locked*1e18 /
            (vestingDuration + cliffDuration);

        // amount of money to be released     
        uint256 releaseAmount = ((block.timestamp - startTimestamp) / 4 weeks) *
            amountByMonth -
            vestingInfo.released;
            
        releaseAmount /= 1e18;

        require(releaseAmount > 0, "not enough release amount.");

        // tracks the amount of money released/sent
        vestingInfo.released += releaseAmount;
        require(vestingInfo.locked > vestingInfo.released,"Mf why do you want to take more than you deserve");
        // sends money to user
        SafeERC20.safeTransfer(IERC20(token), sender, releaseAmount);

         checkVar = vestingInfo.released;
         emit TokenReleased(sender,token,releaseAmount);
    }
}
//@audit no emit
//@audit small amounts will revert
//@audit check whether cliff > vesting
//@audit protocol can be drained because there is no check on= whether user has claimed all his tokens 
