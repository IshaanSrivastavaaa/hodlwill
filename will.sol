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
    struct Hodl{
        address user;
        uint end;
        uint amount;
        uint ownerFee;
        uint duration;
    }
    
    mapping (address => User) users;
    address[] public userAccts;
    
    mapping (address => Hodl) hodlers;
    address[] public hodlAccts;
    
    function father(address _father) public{
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
        require(users[_father].beneficiaryCounter>=1,"Set your beneficiary first");
        require(users[_father].end==0,"The duration is already set");

        users[_father].duration=_duration;
        users[_father].end=block.timestamp+users[_father].duration;

    }
    function deposit(address _father) public payable{
        require(msg.sender==users[_father].father,"You are not the father");
        require(users[_father].beneficiaryCounter>=1,"Set your beneficiary first");
        require(msg.value >=0.01 ether,"Minimum allowed amount = 0.01 ether");

        if (msg.value< 5 ether){
            users[_father].amount = SafeMath.add(users[_father].amount,SafeMath.mul(SafeMath.div(msg.value,40),39));
            users[_father].ownerFee =SafeMath.mul(SafeMath.div(msg.value,40),1);
        }
        else if (msg.value>= 5 ether){
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
        require(msg.sender==users[_father].father,"You are not the father");
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
        require(msg.sender==users[_father].father,"You are not the father");
        return (
            users[_father].father,
            users[_father].beneficiary,
            users[_father].duration,
            users[_father].end,
            users[_father].amount
            );
    }
    
    function fatherHodl(address _user) public{
        Hodl storage newhodl = hodlers[_user];
        newhodl.user = _user;
        newhodl.duration;
        newhodl.end;
        newhodl.amount;
        newhodl.ownerFee;
    }
    function setHodlDuration(address _user,uint _duration) public{
        require(msg.sender==hodlers[_user].user,"You are not the owner");
        require(hodlers[_user].duration==0,"The duration is already set");
        hodlers[_user].duration=_duration;
        hodlers[_user].end=hodlers[_user].duration;
        
    }
    function depositHodl(address _user) public payable{
        require(msg.sender==hodlers[_user].user,"You are not the owner");
        require(msg.value >=0.01 ether,"Minimum allowed amount = 0.01 ether");
        require(hodlers[_user].duration>=0,"Set your duration");
        require(hodlers[_user].end>0,"Set the duration first");
        require(block.timestamp<hodlers[_user].end,"You have unclaimed ether in your account, withdraw them before making another deposit");
        hodlers[_user].amount = SafeMath.add(hodlers[_user].amount,SafeMath.mul(SafeMath.div(msg.value,20),19));
        hodlers[_user].ownerFee =SafeMath.mul(SafeMath.div(msg.value,20),1);

        address payable to = payable(owner);
        to.transfer(hodlers[_user].ownerFee);

    }
    function HodlWithdraw(address _user) public{
        require(msg.sender==hodlers[_user].user,"You are not the owner");
        require(block.timestamp > hodlers[_user].end, "There is still time left");
        address payable to = payable(hodlers[_user].user);
        uint balanceUser = hodlers[_user].amount;
        hodlers[_user].end = 0; 
        hodlers[_user].duration = 0;
        hodlers[_user].amount = 0; 
        hodlers[_user].ownerFee = 0; 
        to.transfer(balanceUser);
    }
    function getHodler(address _user) view public returns (address,uint,uint,uint,uint) {
        require(msg.sender==hodlers[_user].user,"You are not the father");

        return (
            hodlers[_user].user,
            hodlers[_user].duration,
            hodlers[_user].end,
            hodlers[_user].amount,
            hodlers[_user].ownerFee
            );
    }

    function getBalance() view public returns(uint) {
        return address(this).balance;
    }
    

}
