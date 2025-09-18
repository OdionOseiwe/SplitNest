// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract SplitNest {

    mapping(uint256 => Group) private groups;
    uint256 public groupCount;

    struct Group {
        string name;
        address creator;
        address[] members;
        mapping(uint256 => Goal) goals;  // id => Goal
        mapping(uint256 => Bill) bills;  // id => Bills 
        uint256 goalCount;
        uint256 billCount;
    }

    struct Goal {
        string name;
        uint256 targetAmount;
        uint256 totalContributed;
        uint256 deadline;
        mapping(address => uint256) contributions; // address of who contributed to amount
        bool withdrawn;
    }

    struct Bill {
        string description;
        uint256 totalAmount;
        uint256 paidAmount;
        address creator;
        mapping(address => uint256) paidShares;
        bool reimbursed;
    }

    ////////////////////////////Events//////////////////////////////////

    event GroupCreated(uint256 groupId, address creator);
    event  Addmember(uint256 groupId, address[] member);
    event GoalCreated(uint256 groupId, uint256 goalId, uint256 targetAmount);
    event ContributionMade(uint256 groupId, uint256 goalId, address member, uint256 amount);
    event  BillCreated(uint256 groupId, uint256 billId, uint256 totalAmount, address creator);
    event BillPaid(uint256 groupId, uint256 billId, uint256 member, uint256 amount);
    event GoalDeadlineExtended(uint256 groupId, uint256 goalId, uint256 newDeadline);
    event CreatorTransferred(uint256 groupId, address oldCreator, address newCreator);


    /////////////////////////// function ////////////////////////////////

    function CreateGroup(string memory _name) external {
        groupCount++;
        uint256 groupId = groupCount++;
        groups[groupId].name = _name;
        groups[groupId].creator = msg.sender;

        emit GroupCreated(groupId, msg.sender);
    }

    function AddMember(uint256 _groupId, address[] memory _member) external {
        address _creator = groups[_groupId].creator;
        require(msg.sender == _creator, "only creator can add member");
        for (uint i = 0; i < _member.length; i++) {
            groups[_groupId].members.push(_member[i]);
        }
        emit Addmember(_groupId ,_member);
    }

    function LeaveGroup(uint256 _groupId) external {
        bool found;
        assembly{
            // store the key of the mapping and slot number in memory 
            mstore(0x00, _groupId)
            mstore(0x20, groups.slot)

            //hash to get mapping slot
            let groupslot := keccak256(0x00, 0x40)

            // get members arrays slot and its stored in offset 2
            let membersSlot := add(groupslot,2)

            // get length of array
            let membersLength := sload(membersSlot)

            mstore(0x0, membersSlot)
            let membersData := keccak256(0x0, 0x20)
            for { let i := 0 } lt(i, membersLength) { i := add(i, 1) } {
                let currentSlot := add(membersData, i)
                let member := sload(currentSlot)

                if eq(member, caller()) {
                    // replace currentSlot with last member
                    let lastMember := sload(add(membersData, sub(membersLength, 1)))
                    sstore(currentSlot, lastMember)
                    
                    // replace last member with 0
                    sstore(add(membersData, sub(membersLength, 1)), 0)

                    // change the members length 
                    sstore(membersSlot, sub(membersLength, 1))
                    found := 1
                    break
                }
    
            }
        }
        if(!found){
            revert("Not a member");
        }
    }

    function CreateGoal(uint256 _groupId,string memory _name, uint256 _targetAmount, uint256 _deadline) external {
        Group storage group = groups[_groupId];

        group.goalCount++;
        uint256 goalId = group.goalCount;

        Goal storage goal  = group.goals[goalId];
        
        address _creator = group.creator;
        require(msg.sender == _creator, "only creator can add member");

        goal.deadline = _deadline;
        goal.name = _name;
        goal.targetAmount = _targetAmount;
        
        emit GoalCreated(_groupId, goalId, _targetAmount);

    }

    function Contribute(uint256 _groupId, uint256 _goalId) payable external{
        Group storage group = groups[_groupId];
        Goal storage goal  = group.goals[_goalId];

        require(goal.targetAmount > 0, "goal does not exist") ;
        require(goal.deadline < block.timestamp, "goal not in session");
        require(!goal.withdrawn, "goal already withdrawn");
        require(msg.value > 0, "enter valid amount");

        goal.totalContributed = goal.totalContributed + msg.value;
        goal.contributions[msg.sender] = goal.contributions[msg.sender] + msg.value;
        
        emit ContributionMade(_groupId, _goalId, msg.sender, msg.value);
    }

    function extendDeadline(uint256 _groupId, uint256 _goalId, uint256 _newDeadline) external {
        Group storage group = groups[_groupId];
        require(msg.sender == group.creator, "Only creator can extend deadline");

        Goal storage goal = group.goals[_goalId];
        require(goal.deadline > 0, "Goal does not exist");
        require(!goal.withdrawn, "Goal already withdrawn");
        require(_newDeadline > goal.deadline, "New deadline must be later");

        goal.deadline = _newDeadline;

        emit  GoalDeadlineExtended(_groupId, _goalId, _newDeadline);

    }


    function transferCreator(uint256 _groupId, address _newCreator) external {
        Group storage group = groups[_groupId];
        require(msg.sender == group.creator, "Only creator can transfer");
        require(_newCreator != address(0), "Invalid new creator");

        group.creator = _newCreator;

        emit CreatorTransferred(_groupId, msg.sender, _newCreator);
    }


    function withdrawGoalFunds(uint256 _groupId, uint256 _goalId) external {
        Goal storage goal = groups[_groupId].goals[_goalId];
        require(msg.sender == groups[_groupId].creator, "Only creator can withdraw");
        require(goal.totalContributed >= goal.targetAmount || goal.deadline < block.timestamp, "Target not met");
        require(!goal.withdrawn, "Already withdrawn");

        goal.withdrawn = true;

        uint256 transferAmount = goal.totalContributed;
        goal.totalContributed = 0;

        (bool success, ) = payable(msg.sender).call{value: transferAmount}("");
        require(success, "Transfer failed");
    }


    function CreateBill(uint256 _groupId, string memory _description, uint256 _billAmount) external {
        Group storage group = groups[_groupId];

        group.billCount++;
        uint256 billId = group.billCount;

        Bill storage bill = group.bills[billId];
        
        bill.totalAmount = _billAmount;
        bill.description = _description;
        bill.creator = msg.sender;

        emit BillCreated(_groupId, billId, _billAmount, msg.sender);
    }

    function payBillShare(uint256 _billCount, uint256 _groupId) payable external {
        Group storage group = groups[_groupId];
        Bill storage bill = group.bills[_billCount];

        // Checks
        require(msg.value > 0, "Must send ETH");
        require(bill.totalAmount > 0, "Bill does not exist");

        // Track if sender is a member (Yul loop)
        bool isMember = false;

        assembly {
            mstore(0x0, _groupId)
            mstore(0x20, groups.slot)
            let groupSlot := keccak256(0x0, 0x40)

            // members is the 3rd variable in Group struct => offset = 2
            let membersSlot := add(groupSlot, 2)

            // load length
            let len := sload(membersSlot)

            // compute start of data
            mstore(0x0, membersSlot)
            let dataSlot := keccak256(0x0, 0x20)

            for { let i := 0 } lt(i, len) { i := add(i, 1) } {
            let member := sload(add(dataSlot, i))
                if eq(member, caller()) {
                    isMember := 1
                    break
                }
            }
        }

        require(isMember, "You are not a member of this group");

        // Update paidShares mapping
        bill.paidShares[msg.sender] += msg.value;
        bill.paidAmount += msg.value;

        emit BillPaid(_groupId, _billCount, uint160(msg.sender), msg.value);
    }


    function withdrawBillFunds(uint256 _groupId, uint256 _billId) external {
        Bill storage bill = groups[_groupId].bills[_billId];

        require(!bill.reimbursed, "Already reimbursed");
        require(bill.paidAmount >= bill.totalAmount, "Bill not fully paid");
        require(bill.creator == msg.sender, "Only bill creator can withdraw");

        bill.reimbursed = true;

        uint256 amount = bill.paidAmount;
        bill.paidAmount = 0;

        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Withdraw failed");
    }


    function getGoal(uint256 _groupId, uint256 _goalId)
        external
        view
        returns (string memory name, uint256 targetAmount, uint256 totalContributed, uint256 deadline)
    {
        Goal storage goal = groups[_groupId].goals[_goalId];
        return (goal.name, goal.targetAmount, goal.totalContributed, goal.deadline);
    }

}
