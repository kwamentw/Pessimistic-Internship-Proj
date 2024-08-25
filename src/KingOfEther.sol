// SPDX-License-Identifier:MIT
pragma solidity 0.8.26;


contract KingOfEther{
    error GameNotFinished();
    error GameEnded();
    error notEnough();

    event GameEnd(uint256 startTime, uint256 endtime);
    event Deposit(uint256 amount);
    event Withdrawed(uint256 amount);

    address winner;
    mapping(address user=>uint256 bal) public balances;
    bool EndGame;
    uint256 startTime;
    uint256 balance;

    constructor(){
        EndGame = false;
        startTime = block.timestamp;
        balance = 1e18;
        winner = msg.sender;
    }

    function gameFinished() external {
        if (startTime + 30 days != block.timestamp){
            revert GameNotFinished();
        }

        EndGame = true;

        emit GameEnd(startTime,block.timestamp);
    }

    function deposit() external payable {
        if(block.timestamp == startTime + 30 days){
            revert GameEnded();
        }
        if(msg.value == 0){
            revert notEnough();
        }
        balance += msg.value;
        balances[msg.sender] += msg.value;

        if(balances[msg.sender] > balances[winner]){
            winner = msg.sender;
        }

        emit Deposit(msg.value);
    }

    function withdraw() external {
        if(block.timestamp != startTime + 30 days){
            revert GameNotFinished();
        }
        if(balances[msg.sender] == 0){
            revert notEnough();
        }
        uint256 amount = balances[msg.sender];
        balance -= amount;
        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);

        emit Withdrawed(amount);
    }

}