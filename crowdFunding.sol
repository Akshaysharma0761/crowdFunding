//SPDX-License-Identifier-MIT
pragma solidity >=0.5.0 <0.9.0;

contract crowdFunding{
    mapping(address=>uint) public contributors;
    uint public minimumContribution;
    uint public target;
    uint public deadline;
    address public manager;
    uint public raiseAmount;
    uint public noOfContributors;
    
    struct Request{
        string description;
        address payable recipient;
        uint value;
        bool complete;
        uint noOfVoters;
        mapping(address=>bool)voters;
    }
    mapping(uint=>Request)public requests;
    uint public numRequest;
    constructor(uint _target , uint _deadline)public{
        target=_target;
        deadline=block.timestamp + _deadline;
        manager=msg.sender;
        minimumContribution=100;
    }
   function sendEth() public payable{
       require(msg.value>=minimumContribution,"Minimum contribution is not met");
       require(block.timestamp< deadline,"Deadline has passes");
       if(contributors[msg.sender]==0){
         noOfContributors++;
       }
       contributors[msg.sender]+=msg.value;
       raiseAmount+=msg.value;
   }
   function getContractBalance()public view returns(uint){
       return address(this).balance;
   }
   function refund()public {
      
       require(block.timestamp>deadline && raiseAmount< target,"you are not eligiable to get fund back");
       require(contributors[msg.sender]>0);
       address payable user=(msg.sender);
       user.transfer(contributors[msg.sender]);
       contributors[msg.sender]=0;

   }
   modifier onlyManager(){
       require(msg.sender==manager);
       _;
   }
   function createRequest(string memory _description,address payable _recipient,uint _value)public onlyManager{
        Request storage newRequest=requests[numRequest];
        numRequest++;
        newRequest.description=_description;
        newRequest.recipient= _recipient;
        newRequest.value=_value;
        newRequest.complete=false;
        newRequest.noOfVoters=0;
        
   }
   function voteRequest(uint _requestNo) public{
       require(contributors[msg.sender]>0,"firstly you may contribute");
       Request storage thisRequest=requests[_requestNo];
       require(thisRequest.voters[msg.sender]==false);
       thisRequest.voters[msg.sender]=true;
            thisRequest.noOfVoters++;
   }
   function makePayment(uint _requestNo) public onlyManager{
require(raiseAmount>target);
Request storage thisRequest= requests[_requestNo];
require(thisRequest.complete==false,"the req has been complete");
require(thisRequest.noOfVoters>noOfContributors/2,"majority does not support");
thisRequest.recipient.transfer(thisRequest.value);
thisRequest.complete=true;
   }
}