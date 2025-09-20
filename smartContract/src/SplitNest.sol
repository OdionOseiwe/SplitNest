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
        mapping(address => uint256) contributions;
        address[] contributors;   // NEW: list of contributors
        bool withdrawn;
    }

    struct Bill {
        string description;
        uint256 totalAmount;
        uint256 paidAmount;
        address creator;
        mapping(address => uint256) paidShares;   // how much each member has paid
        uint256 memberShare;                      // fixed share for each member
        address[] payers;
        bool reimbursed;
    }


    ////////////////////////////Events//////////////////////////////////

    event GroupCreated(uint256 indexed groupId, address indexed creator);
    event  Addmember(uint256 indexed groupId, address[] indexed member);
    event GoalCreated(uint256 indexed groupId, uint256 indexed goalId, uint256 indexed targetAmount);
    event ContributionMade(uint256 indexed groupId, uint256 indexed goalId, address indexed member, uint256 amount);
    event  BillCreated(uint256 indexed groupId, uint256 indexed billId, uint256 indexed totalAmount, address creator);
    event BillPaid(uint256 indexed groupId, uint256 indexed billId, uint256 indexed member, uint256 amount);
    event GoalDeadlineExtended(uint256 indexed groupId, uint256 indexed goalId, uint256 indexed newDeadline);
    event CreatorTransferred(uint256 indexed groupId, address indexed oldCreator, address indexed newCreator);


    /////////////////////////// function ////////////////////////////////

    // Create a new group
    function CreateGroup(string memory _name) external {
        groupCount += 1;
        uint256 groupId = groupCount;
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

    // Create a saving goal (only group creator)
    function CreateGoal(uint256 _groupId, string memory _name, uint256 _targetAmount, uint256 _deadline) external {
        Group storage group = groups[_groupId];

        address _creator = group.creator;
        require(msg.sender == _creator, "only creator can create goal");

        group.goalCount += 1;
        uint256 goalId = group.goalCount;

        Goal storage goal  = group.goals[goalId];

        goal.deadline = _deadline;
        goal.name = _name;
        goal.targetAmount = _targetAmount;
        goal.totalContributed = 0;
        goal.withdrawn = false;

        emit GoalCreated(_groupId, goalId, _targetAmount);
    }

    function Contribute(uint256 _groupId, uint256 _goalId) payable external {
        Group storage group = groups[_groupId];
        Goal storage goal  = group.goals[_goalId];

        require(goal.targetAmount > 0, "goal does not exist");
        require(block.timestamp < goal.deadline, "goal not in session");
        require(!goal.withdrawn, "goal already withdrawn");
        require(msg.value > 0, "enter valid amount");

        if (goal.contributions[msg.sender] == 0) {
            // First time contributor → track them
            goal.contributors.push(msg.sender);
        }

        goal.totalContributed += msg.value;
        goal.contributions[msg.sender] += msg.value;
    
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

    // Transfer creator
    function transferCreator(uint256 _groupId, address _newCreator) external {
        Group storage group = groups[_groupId];
        require(msg.sender == group.creator, "Only creator can transfer");
        require(_newCreator != address(0), "Invalid new creator");

        address old = group.creator;
        group.creator = _newCreator;

        emit CreatorTransferred(_groupId, old, _newCreator);
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
        require(group.members.length > 0, "No members in group");

        group.billCount++;
        uint256 billId = group.billCount;

        Bill storage bill = group.bills[billId];
        bill.totalAmount = _billAmount;
        bill.description = _description;
        bill.creator = msg.sender;

        // Divide equally
        bill.memberShare = _billAmount / group.members.length;

        emit BillCreated(_groupId, billId, _billAmount, msg.sender);
    }


    function payBillShare(uint256 _billCount, uint256 _groupId) payable external {
        Group storage group = groups[_groupId];
        Bill storage bill = group.bills[_billCount];

        // Checks
        require(msg.value > 0, "Must send ETH");
        require(bill.totalAmount > 0, "Bill does not exist");

        // Track if sender is a member (Yul loop)
        bool isMember = isMemberOf(_groupId,msg.sender);

        if(isMember){
            // Update paidShares mapping
            if (bill.paidShares[msg.sender] == 0) {
                // First time payer → track them
                bill.payers.push(msg.sender);
            }
            bill.paidShares[msg.sender] += msg.value;
        }

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


     // Check if an address (or msg.sender) is a member of a group using assembly loop
    function isMemberOf(uint256 _groupId, address _addr) internal view returns (bool) {
        bool isMember = false;
        assembly {
            mstore(0x0, _groupId)
            mstore(0x20, groups.slot)
            let groupSlot := keccak256(0x0, 0x40)

            // members is offset 2
            let membersSlot := add(groupSlot, 2)
            let len := sload(membersSlot)

            mstore(0x0, membersSlot)
            let dataSlot := keccak256(0x0, 0x20)

            for { let i := 0 } lt(i, len) { i := add(i, 1) } {
                let member := sload(add(dataSlot, i))
                if eq(member, _addr) {
                    isMember := 1
                    break
                }
            }
        }
        return isMember;
    }

    function getOutstandingAmount(uint256 _groupId, uint256 _billId, address _member) 
        external 
        view 
        returns (uint256 outstanding) 
    {
        Group storage group = groups[_groupId];
        Bill storage bill = group.bills[_billId];

        require(bill.totalAmount > 0, "Bill does not exist");
        require(isMemberOf(_groupId, _member), "Not a member");

        uint256 expected = bill.memberShare;
        uint256 paid = bill.paidShares[_member];

        if (paid >= expected) {
        return 0; // fully paid
        } else {
            return expected - paid;
        }
    }


    function getAllGoals(uint256 _groupId)
        external
        view
        returns (
            string[] memory names,
            uint256[] memory targetAmounts,
            uint256[] memory totalContributed,
            uint256[] memory deadlines,
            bool[] memory withdrawn
        )
    {
        Group storage group = groups[_groupId];
        uint256 count = group.goalCount;

        names = new string[](count);
        targetAmounts = new uint256[](count);
        totalContributed = new uint256[](count);
        deadlines = new uint256[](count);
        withdrawn = new bool[](count);

        // Use standard Solidity loop here because reading nested mapping fields is straightforward.
        // For membership loops we used inline assembly; here high-level code is safer and clearer.
        for (uint256 i = 0; i < count; i++) {
            uint256 id = i + 1;
            Goal storage g = group.goals[id];
            names[i] = g.name;
            targetAmounts[i] = g.targetAmount;
            totalContributed[i] = g.totalContributed;
            deadlines[i] = g.deadline;
            withdrawn[i] = g.withdrawn;
        }
    }

    function getAllBills(uint256 _groupId)
        external
        view
        returns (
            string[] memory descriptions,
            uint256[] memory totalAmounts,
            uint256[] memory paidAmounts,
            address[] memory creators,
            bool[] memory reimbursed
        )
    {
        Group storage group = groups[_groupId];
        uint256 count = group.billCount;

        descriptions = new string[](count);
        totalAmounts = new uint256[](count);
        paidAmounts = new uint256[](count);
        creators = new address[](count);
        reimbursed = new bool[](count);

        for (uint256 i = 0; i < count; i++) {
            uint256 id = i + 1;
            Bill storage b = group.bills[id];
            descriptions[i] = b.description;
            totalAmounts[i] = b.totalAmount;
            paidAmounts[i] = b.paidAmount;
            creators[i] = b.creator;
            reimbursed[i] = b.reimbursed;
        }
    }

    function getGoalContributors(uint256 _groupId, uint256 _goalId)
        external
        view
        returns (address[] memory, uint256[] memory)
    {
        Goal storage goal = groups[_groupId].goals[_goalId];
        uint256 len = goal.contributors.length;

        address[] memory addrs = new address[](len);
        uint256[] memory amounts = new uint256[](len);

        for (uint i = 0; i < len; i++) {
            address a = goal.contributors[i];
            addrs[i] = a;
            amounts[i] = goal.contributions[a];
        }

        return (addrs, amounts);
    }

    function getBillPayers(uint256 _groupId, uint256 _billId)
        external
        view
        returns (address[] memory, uint256[] memory)
    {
        Bill storage bill = groups[_groupId].bills[_billId];
        uint256 len = bill.payers.length;

        address[] memory addrs = new address[](len);
        uint256[] memory amounts = new uint256[](len);

        for (uint i = 0; i < len; i++) {
            address a = bill.payers[i];
            addrs[i] = a;
            amounts[i] = bill.paidShares[a];
        }

        return (addrs, amounts);
    }


    // Helper to get member list for a group (returns array of addresses)
    function getMembers(uint256 _groupId) external view returns (address[] memory) {
        return groups[_groupId].members;
    }

    // Helper: read how much an address contributed to a goal
    function getContribution(uint256 _groupId, uint256 _goalId, address _addr) external view returns (uint256) {
        Goal storage goal = groups[_groupId].goals[_goalId];
        return goal.contributions[_addr];
    }

    // Helper: read how much an address paid toward a bill
    function getPaidShare(uint256 _groupId, uint256 _billId, address _addr) external view returns (uint256) {
        Bill storage bill = groups[_groupId].bills[_billId];
        return bill.paidShares[_addr];
    }

}
