//SPDX-License-Identifier:UNLICENSED
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
contract will {
    address immutable public owner=0x174D3d6d10ecCFd40e005553a36c59b6e4b91285;
    struct User {
        address father;
        address beneficiary;
        uint end;
        uint amount;
        uint ownerFee;
        uint duration;
        uint fatherCounter;
        uint beneficiaryCounter;
    }
    
    mapping (address => User) users;
    address[] public userAccts;
    
    function father(address _father) public{
        require(msg.sender==_father);
        User storage newuser = users[_father];
        newuser.father = _father;
        newuser.duration;
        newuser.end;
        newuser.amount;
        newuser.ownerFee;
    }
    function beneficiary(address _father,address _beneficiary) public{
        require(msg.sender==users[_father].father,"You are not the father");
        require(users[_father].beneficiaryCounter<1,"Beneficiary is already defined");
        
        users[_father].beneficiary=_beneficiary;
        users[_father].beneficiaryCounter=users[_father].beneficiaryCounter+1;
    }
    function setDuration(address _father,uint _duration) public{
        require(msg.sender==users[_father].father,"You are not the father");
        users[_father].duration=_duration;
        users[_father].end=block.timestamp+users[_father].duration;
    }
    function deposit(address _father) public payable{
        require(msg.sender==users[_father].father,"You are not the father");
        require(msg.value >=0.01 ether,"Minimum allowed amount = 0.01 ether");

        if (msg.value< 5 ether){
            users[_father].amount = SafeMath.add(users[_father].amount,SafeMath.mul(SafeMath.div(msg.value,40),39));
            users[_father].ownerFee =SafeMath.mul(SafeMath.div(msg.value,40),1);
        }
        else if (msg.value> 5 ether){
            users[_father].amount = SafeMath.add(users[_father].amount,SafeMath.mul(SafeMath.div(msg.value,50),49));
            users[_father].ownerFee =SafeMath.mul(SafeMath.div(msg.value,50),1);     
            
        }
        address payable to = payable(owner);
        to.transfer(users[_father].ownerFee);

    }
    function updateDelay(address _father) public{
        require(msg.sender==users[_father].father,"You are not the father");
        require(block.timestamp < users[_father].end, "Time is over");
        require(block.timestamp >= users[_father].end-(users[_father].duration/2) ,"Wait for half the duration");
        if(block.timestamp>=users[_father].end-(users[_father].duration/2)){
            users[_father].end=0;
            users[_father].end=block.timestamp+users[_father].duration;
        }
    }
    function FatherWithdraws(address _father) public{
        require(msg.sender==users[_father].father,"You are not the father");
        require(block.timestamp > users[_father].end, "There is still time left");
        address payable to = payable(users[_father].father);
        uint balanceUser = users[_father].amount;
        users[_father].end = 0; 
        users[_father].duration = 0;
        users[_father].amount = 0; 
        users[_father].ownerFee = 0; 
        to.transfer(balanceUser);
    }
    function BeneficiaryWithdraws(address _father) public{
        require(msg.sender==users[_father].beneficiary,"You are not the beneficiary");
        require(block.timestamp > users[_father].end, "There is still time left");
        address payable to = payable(users[_father].beneficiary);
        uint balanceUser = users[_father].amount;
        users[_father].end = 0; 
        users[_father].duration = 0;
        users[_father].amount = 0; 
        users[_father].ownerFee = 0; 
        to.transfer(balanceUser);
    }
    function QuickWithdraw(address _father) public{
        require(msg.sender==_father);
        require(_father==users[_father].father,"You are not the father");
        address payable tot = payable(users[_father].father);
        address payable fro = payable(owner);
        uint userWithdraw = SafeMath.mul(SafeMath.div(users[_father].amount,40),39);
        uint ownerWithdraw = SafeMath.mul(SafeMath.div(users[_father].amount,40),1);
        users[_father].end = 0; 
        users[_father].duration = 0;
        users[_father].amount = 0; 
        users[_father].ownerFee = 0; 
        tot.transfer(userWithdraw);
        fro.transfer(ownerWithdraw);
    }
    function getUser(address _father) view public returns (address,address,uint,uint,uint) {
        require(msg.sender==_father);
        return (
            users[_father].father,
            users[_father].beneficiary,
            users[_father].duration,
            users[_father].end,
            users[_father].amount
            );
    }
    function getBalance() view public returns(uint) {
        return address(this).balance;
    }
    

}
