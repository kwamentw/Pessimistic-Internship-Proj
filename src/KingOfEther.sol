// SPDX-License-Identifier:MIT
pragma solidity 0.8.26;


/**
 * @title King Of Ether
 * @author Kwame 4b
 * @notice A game in which the winner takes all the ETH after the game is over
 */
contract KingOfEther{
    //----ERRORS----
    error GameNotFinished();
    error GameEndedAlready();
    error notEnough();

    //----EVENTS----
    event GameEnd(uint256 startTime, uint256 endtime);
    event Deposit(uint256 amount);
    event Withdrawed(uint256 amount);

    //-------------------------------------------------

    // winner of game
    address public winner;
    // balances of users / participants
    mapping(address user=>uint256 bal) public balances;

    // Whether Game has ended or not
    bool EndGame;

    // time Game starts
    uint256 public startTime;
    // total balance in the game 
    uint256 public bal;
    //-------------------------------------------------

    constructor() {
        EndGame = false;
        startTime = block.timestamp;
        bal = 1e18;
        winner = msg.sender;
    }

    /**
     * Called to end game 
     * Game wont end unless endtime = startTime + 30 days
     */
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

    /**
     * Call to Deposit eth to play the game
     * @param amount amount deposited
     */
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

        if(balances[msg.sender] > balances[winner]){
            winner = msg.sender;
        }

        emit Deposit(msg.value);
    }

    /**
     * Call to back out from playing the game 
     */
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