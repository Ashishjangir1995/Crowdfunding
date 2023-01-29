// SPDX-License-Identifier: MIT
pragma solidity^ 0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol"; //imported openzeppelin contracts

contract crowdfunding {  // smartcontract creation
    address public token;  // global variables are created according to datatype
    address public owner;
    uint public goal;
    bool public Target;
    uint public startTime;
    uint public endTime;

    struct depositer{   //structure of all the depositors to store multidatatype information
        address depositerAddress;
        uint256 Amount;
        uint256 time;
    }
    mapping(address=> depositer) depositers;  // depositer is mapped with their respective address

constructor (address erc20){  // while deploying this contract need an erc20 token address to pass

    token = erc20;
    owner= msg.sender;
}
event crowdfund(address owner, uint starttime, uint endtime); //events are created with respective functions 
event submit(address deposite, uint price);
event amountWithdrawl(address _withdrawer, uint _amount);

modifier onlyOwner(){   // modifier constains the restriction on an perticular function
    require (msg.sender == owner, "Only owner can start crowd funding");
    _;
}

function startCrowdFunding(uint amount, uint _startTime, uint _endTime) public onlyOwner{ // function to start the crowdfunding with time slabs
    goal = amount;
    startTime = _startTime;
    endTime = _endTime;
    emit crowdfund(owner, startTime, endTime);
}

function deposite(address _depositer,uint _amount) public {  // depositers will deposite money in this contract
require(block.timestamp>startTime && block.timestamp<endTime);  // to check weather the crowdfunding has started or not
   if (IERC20(token).balanceOf(address(this))< goal)   // to check the goal meet or not
   { 
    depositers[_depositer].depositerAddress=_depositer;
    depositers[_depositer].Amount = _amount;
    depositers[_depositer].time= block.timestamp;
    IERC20(token).transferFrom(depositers[_depositer].depositerAddress, address(this), _amount);
   }
   else
   {
    Target= true;  // once the goal is achived bool will be true and no more addition of amount 
   }
   emit submit( depositers[_depositer].depositerAddress,depositers[_depositer].Amount );
}
function withdraw(address withdrawer) public{
    require (block.timestamp> endTime, "funding time period is not ended");// no one can withdraw till the funding time is not over
require(Target ==false);
require(depositers[withdrawer].Amount>0,"No amount is locked for this user");
IERC20(token).transfer(withdrawer, depositers[withdrawer].Amount);
emit amountWithdrawl(withdrawer, depositers[withdrawer].Amount);

}
// getter functions*****************************************
function getDepositerDetails(address _depositer) public view returns(uint, uint){
    return(depositers[_depositer].Amount,depositers[_depositer].time);
}

function currentBalance()public view returns(uint){
uint balance = IERC20(token).balanceOf(address(this));
return(balance);
}

}