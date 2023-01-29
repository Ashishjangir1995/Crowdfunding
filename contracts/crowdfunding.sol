// SPDX-License-Identifier: GPL-3.0
pragma solidity^ 0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract crowdfunding {
    address public token;
    address public owner;
    uint public goal;
    uint public currentFund;
    bool public Target;
    uint public startTime;
    uint public endTime;
    struct depositer{
        address depositerAddress;
        uint256 Amount;
        uint256 time;
    }
    mapping(address=> depositer) depositers;

constructor (address erc20){

    token = erc20;
    owner= msg.sender;
}
event crowdfund(address owner, uint starttime, uint endtime);

modifier onlyOwner(){
    require (msg.sender == owner, "Only owner can start crowd funding");
    _;
}
modifier fundingStarted(uint _startTime ){
    require(block.timestamp>= _startTime, "funding is not started");
    _;
}
modifier fundingEnded (uint _endTime) {
    require (block.timestamp <= _endTime, "funding ended");
    _;

}
function startCrowdFunding(uint amount, uint _startTime, uint _endTime) public onlyOwner{ 
    goal = amount;
    currentFund = 0;
    startTime = _startTime;
    endTime = _endTime;
    emit crowdfund(owner, startTime, endTime);
}

function deposite(address _depositer,uint _amount) public fundingStarted(block.timestamp) fundingEnded(block.timestamp){
   if (IERC20(token).balanceOf(address(this))< goal)
   { 
    depositers[_depositer].depositerAddress=_depositer;
    depositers[_depositer].Amount = _amount;
    depositers[_depositer].time= block.timestamp;
    IERC20(token).transferFrom(depositers[_depositer].depositerAddress, address(this), _amount);
   }
   else
   {
    Target= true;
   }
}
function withdraw(address withdrawer) public fundingEnded(block.timestamp){
require(Target ==false);
require(depositers[withdrawer].Amount>0,"No amount is locked for this user");
IERC20(token).transferFrom (address(this), withdrawer, depositers[withdrawer].Amount);

}




}