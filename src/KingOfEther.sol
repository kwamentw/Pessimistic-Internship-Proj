// SPDX-License-Identifier:MIT
pragma solidity 0.8.26;


contract KingOfEther{
    error GameNotFinished();
    error GameEnded();
    error notEnough();

    event GameEnd(uint256 startTime, uint256 endtime);
    event Deposit(uint256 amount);
    event Withdrawed(uint256 amount);

    address public winner;
    mapping(address user=>uint256 bal) public balances;
    bool EndGame;
    uint256 public startTime;
    uint256 public balance;

    constructor() {
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

    function deposit(uint256 amount) external payable {
        require(msg.value == amount,"youCheat!");
        if(block.timestamp == startTime + 30 days){
            revert GameEnded();
        }
        if(amount == 0){
            revert notEnough();
        }
        balance += amount;
        balances[msg.sender] += amount;

        if(balances[msg.sender] > balances[winner]){
            winner = msg.sender;
        }

        emit Deposit(msg.value);
    }

    function withdraw() external {
        uint256 amountWdrwn;
        if(block.timestamp != startTime + 30 days){
            revert GameNotFinished();
        }
        if(!EndGame){revert GameNotFinished();}
        emit Withdrawed(balances[msg.sender]);
        uint256 amount = balances[msg.sender];
        payable(msg.sender).transfer(amount);
         amountWdrwn += amount;
        
        emit Withdrawed(amountWdrwn);
        if(balances[msg.sender] == 0){
            revert notEnough();
        }
        balance -= amountWdrwn;
        balances[msg.sender] -= amountWdrwn;
    }

}