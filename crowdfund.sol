pragma solidity ^0.8.14;
contract crowdfund
{
    mapping(address=>uint) public contributers;
    address public manager;
    uint public mincontribution;
    uint public deadline;
    uint public target;
    uint public amount_raised;
    uint public noofcontibuters;
    uint request_id=0;
    struct request
    {
        string description;
        address payable receiptent;
        uint amount;
        bool issatisfied;
        uint noofvoters;
        mapping(address=>bool) voters;
    }
    mapping(uint=>request)requests;
    uint public noofreqs;
    constructor (uint t,uint d)
    {
        target=t;
        deadline=block.timestamp+d;
        mincontribution=100 wei;
        manager=msg.sender;
    }
    function send_ether() public payable 
    {require(block.timestamp<deadline);
        require(msg.value>=100 wei);
        
        if(contributers[msg.sender]==0)
        {
            noofcontibuters+=1;
        }
        amount_raised+=msg.value;
        contributers[msg.sender]+=msg.value;
    }
    function refund() public payable 
    {
        require(block.timestamp>deadline && amount_raised<target);
        require(contributers[msg.sender]>0);
        address payable ad=payable(msg.sender);
        ad.transfer(contributers[msg.sender]);
        contributers[msg.sender]=0;
    }
        modifier onlyman(address f)
        {
            require(f==manager);
            _;
        }
    function make_request(string memory des,address pd,uint a) public onlyman(msg.sender) {
        request_id+=1;
        requests[request_id].description=des;
        requests[request_id].receiptent=payable(pd);
        requests[request_id].amount=a;
        requests[request_id].issatisfied=false;
        requests[request_id].noofvoters=0;
    }
    function voteRequest(uint req_no) public 
    {
        require(contributers[msg.sender]>0);
        require(requests[req_no].voters[msg.sender]==false);
        requests[req_no].noofvoters+=1;
        requests[req_no].voters[msg.sender]=true;
    }
    function make_payment(uint reqno) public payable 
    {
        require(amount_raised>target);
        require(requests[reqno].issatisfied==false);
        require(requests[reqno].noofvoters>(noofcontibuters/2));
        requests[reqno].receiptent.transfer(requests[reqno].amount);
        requests[reqno].issatisfied=true;
    }
}
