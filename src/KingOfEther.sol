// SPDX-License-Identifier:MIT
pragma solidity 0.8.26;


contract KingOfEther{
    error GameNotFinished();
    error GameEndedAlready();
    error notEnough();

    event GameEnd(uint256 startTime, uint256 endtime);
    event Deposit(uint256 amount);
    event Withdrawed(uint256 amount);

    address public winner;
    mapping(address user=>uint256 bal) public balances;
    bool EndGame;
    uint256 public startTime;
    uint256 public bal;

    constructor() {
        EndGame = false;
        startTime = block.timestamp;
        bal = 1e18;
        winner = msg.sender;
    }

    function gameFinished() external {
        if (startTime + 30 days != block.timestamp){
            revert GameNotFinished();
        }
        if(EndGame){revert GameEndedAlready();}

        EndGame = true;
        payable(winner).transfer(address(this).balance);

        emit GameEnd(startTime,block.timestamp);
        emit Withdrawed(address(this).balance);
        emit Withdrawed(address(winner).balance);
    }

    function deposit(uint256 amount) external payable {
        require(msg.value == amount,"youCheat!");
        if(block.timestamp == startTime + 30 days){
            revert GameEndedAlready();
        }
        if(amount == 0){
            revert notEnough();
        }
        bal += msg.value;
        balances[msg.sender] += msg.value;

        // if(balances[msg.sender] > balances[winner]){
        //     winner = msg.sender;
        // }

        // emit Deposit(msg.value);
    }

    function withdraw() external {
        if(balances[msg.sender] == 0){
            revert notEnough();
        }

        uint256 amount = balances[msg.sender];
        (bool ok,)=msg.sender.call{value:amount}("");
        require(ok);

        bal = 0;
        balances[msg.sender] = 0;

        emit Withdrawed(balances[msg.sender]);
    }

}