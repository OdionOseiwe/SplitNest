// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ReentrancyGuard} from "openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";

/**
 * @title SplitNest
 * @notice Group savings and bill-splitting contract.
 * @dev Uses OpenZeppelin's ReentrancyGuard for security on fund withdrawals.
 * Each group has a creator who can manage goals and members.
 * Members can contribute to goals and pay their shares of bills.
 * Goals have deadlines and target amounts; funds can be withdrawn by the creator
 * once the target is met or the deadline has passed. Bills can be created by any member,
 * and members pay their equal shares. Bill creators can withdraw funds once fully paid.
 */


contract SplitNest is ReentrancyGuard {
    struct Goal {
        string name;
        uint256 targetAmount;
        uint256 totalContributed;
        uint256 deadline;
        mapping(address => uint256) contributions;
        address[] contributors;
        bool withdrawn;
    }

    struct Bill {
        string description;
        uint256 totalAmount;
        uint256 paidAmount;
        address creator;
        mapping(address => uint256) paidShares;
        uint256 memberShare;
        uint256 remainder;
        address[] payers;
        bool reimbursed;
    }

    struct Group {
        string name;
        address creator;
        address[] members;
        mapping(address => bool) isMember;
        mapping(uint256 => Goal) goals; // id => Goal
        mapping(uint256 => Bill) bills; // id => Bill
        uint256 goalCount;
        uint256 billCount;
    }

    // groups mapping
    mapping(uint256 => Group) private groups;
    uint256 public groupCount;

    //////////////////////////// Events //////////////////////////////////
    event GroupCreated(uint256 indexed groupId, address indexed creator);
    event AddMember(uint256 indexed groupId, address indexed member);
    event GoalCreated(uint256 indexed groupId, uint256 indexed goalId, uint256 indexed targetAmount);
    event ContributionMade(uint256 indexed groupId, uint256 indexed goalId, address indexed member, uint256 amount);
    event BillCreated(uint256 indexed groupId, uint256 indexed billId, uint256 indexed totalAmount, address creator);
    event BillPaid(uint256 indexed groupId, uint256 indexed billId, address indexed payer, uint256 amount);
    event GoalDeadlineExtended(uint256 indexed groupId, uint256 indexed goalId, uint256 indexed newDeadline);
    event CreatorTransferred(uint256 indexed groupId, address indexed oldCreator, address indexed newCreator);

    /////////////////////////// Functions ////////////////////////////////

    /// @notice Create a new group; caller becomes creator and initial member
    function CreateGroup(string memory _name) external {
        groupCount += 1;
        uint256 groupId = groupCount;

        Group storage g = groups[groupId];
        g.name = _name;
        g.creator = msg.sender;
        g.members.push(msg.sender);
        g.isMember[msg.sender] = true;

        emit GroupCreated(groupId, msg.sender);
    }

    /// @notice Add members to a group (only group creator)
    function addMember(uint256 _groupId, address[] memory _members) external {
        Group storage g = groups[_groupId];
        require(g.creator != address(0), "group does not exist");
        require(msg.sender == g.creator, "only creator can add member");

        for (uint i = 0; i < _members.length; i++) {
            address m = _members[i];
            require(m != address(0), "invalid member");
            if (!g.isMember[m]) {
                g.members.push(m);
                g.isMember[m] = true;
                emit AddMember(_groupId, m);
            }
        }
    }

    /// @notice Leave a group; caller is removed from member list
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
    /// @notice Create a saving goal (only group creator)
    function CreateGoal(uint256 _groupId, string memory _name, uint256 _targetAmount, uint256 _deadline) external {
        Group storage g = groups[_groupId];
        require(g.creator != address(0), "group does not exist");
        require(msg.sender == g.creator, "only creator can create goal");

        g.goalCount += 1;
        uint256 goalId = g.goalCount;

        Goal storage goal = g.goals[goalId];
        goal.deadline = _deadline;
        goal.name = _name;
        goal.targetAmount = _targetAmount;
        goal.totalContributed = 0;
        goal.withdrawn = false;

        emit GoalCreated(_groupId, goalId, _targetAmount);
    }

    /// @notice Contribute to a goal
    function Contribute(uint256 _groupId, uint256 _goalId) payable external {
        Group storage g = groups[_groupId];
        require(g.creator != address(0), "group does not exist");

        Goal storage goal  = g.goals[_goalId];
        require(goal.targetAmount > 0, "goal does not exist");
        require(block.timestamp < goal.deadline, "goal not in session");
        require(!goal.withdrawn, "goal already withdrawn");
        require(msg.value > 0, "enter valid amount");
        require(g.isMember[msg.sender], "only group members can contribute");

        if (goal.contributions[msg.sender] == 0) {
            // First time contributor → track them
            goal.contributors.push(msg.sender);
        }

        goal.totalContributed += msg.value;
        goal.contributions[msg.sender] += msg.value;

        emit ContributionMade(_groupId, _goalId, msg.sender, msg.value);
    }

    /// @notice Extend a goal deadline (only creator)
    function extendDeadline(uint256 _groupId, uint256 _goalId, uint256 _newDeadline) external {
        Group storage g = groups[_groupId];
        require(g.creator != address(0), "group does not exist");
        require(msg.sender == g.creator, "Only creator can extend deadline");

        Goal storage goal = g.goals[_goalId];
        require(goal.deadline > 0, "Goal does not exist");
        require(!goal.withdrawn, "Goal already withdrawn");
        require(_newDeadline > goal.deadline, "New deadline must be later");

        goal.deadline = _newDeadline;

        emit GoalDeadlineExtended(_groupId, _goalId, _newDeadline);
    }

    /// @notice Transfer creator role to another address
    function transferCreator(uint256 _groupId, address _newCreator) external {
        Group storage g = groups[_groupId];
        require(g.creator != address(0), "group does not exist");
        require(msg.sender == g.creator, "Only creator can transfer");
        require(_newCreator != address(0), "Invalid new creator");
        require(g.isMember[_newCreator], "new creator must be a member");

        address old = g.creator;
        g.creator = _newCreator;

        emit CreatorTransferred(_groupId, old, _newCreator);
    }

    /// @notice Withdraw goal funds (only creator). Uses nonReentrant.
    /// @dev Creator can withdraw if target met OR deadline passed. Consider refund logic if target not met.
    function withdrawGoalFunds(uint256 _groupId, uint256 _goalId) external nonReentrant {
        Group storage g = groups[_groupId];
        require(g.creator != address(0), "group does not exist");
        require(msg.sender == g.creator, "Only creator can withdraw");

        Goal storage goal = g.goals[_goalId];
        require(goal.targetAmount > 0, "goal does not exist");
        require(goal.totalContributed > 0, "no funds to withdraw");
        require(!goal.withdrawn, "Already withdrawn");
        require(goal.totalContributed >= goal.targetAmount || goal.deadline < block.timestamp, "Target not met and deadline not passed");

        goal.withdrawn = true;

        uint256 transferAmount = goal.totalContributed;
        goal.totalContributed = 0;

        (bool success, ) = payable(msg.sender).call{value: transferAmount}("");
        require(success, "Transfer failed");
    }

    /// @notice Create a bill for the group (any member can create)
    function CreateBill(uint256 _groupId, string memory _description, uint256 _billAmount) external {
        Group storage g = groups[_groupId];
        require(g.creator != address(0), "group does not exist");
        require(g.isMember[msg.sender], "only members can create bills");
        require(g.members.length > 0, "No members in group");
        require(_billAmount > 0, "Invalid bill amount");

        g.billCount++;
        uint256 billId = g.billCount;

        Bill storage bill = g.bills[billId];
        bill.totalAmount = _billAmount;
        bill.description = _description;
        bill.creator = msg.sender;

        // Divide equally
        bill.memberShare = _billAmount / g.members.length;
        bill.remainder = _billAmount % g.members.length;

        emit BillCreated(_groupId, billId, _billAmount, msg.sender);
    }

    /// @notice Pay toward a bill share. Caller must not be a member and sends ETH
    function payBillShare(uint256 _billId, uint256 _groupId) payable external {
        Group storage g = groups[_groupId];
        require(g.creator != address(0), "group does not exist");
        Bill storage bill = g.bills[_billId];
        require(bill.totalAmount > 0, "Bill does not exist");
        require(msg.value > 0, "Must send ETH");

        // Update paidShares mapping
        if (bill.paidShares[msg.sender] == 0) {
            // First time payer → track them
            bill.payers.push(msg.sender);
        }
        bill.paidShares[msg.sender] += msg.value;
        bill.paidAmount += msg.value;

        emit BillPaid(_groupId, _billId, msg.sender, msg.value);
    }

    /// @notice Withdraw collected bill funds (only bill creator) once fully paid
    function withdrawBillFunds(uint256 _groupId, uint256 _billId) external nonReentrant {
        Group storage g = groups[_groupId];
        require(g.creator != address(0), "group does not exist");

        Bill storage bill = g.bills[_billId];
        require(bill.totalAmount > 0, "Bill does not exist");
        require(!bill.reimbursed, "Already reimbursed");
        require(bill.paidAmount >= bill.totalAmount, "Bill not fully paid");
        require(bill.creator == msg.sender, "Only bill creator can withdraw");

        bill.reimbursed = true;

        uint256 amount = bill.paidAmount;
        bill.paidAmount = 0;

        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Withdraw failed");
    }

    /// @notice Check if an address is a member of a group
    function isMemberOf(uint256 _groupId, address _addr) public view returns (bool) {
        return groups[_groupId].isMember[_addr];
    }

    /// @notice Get outstanding amount for a group member on a bill
    function getOutstandingAmount(uint256 _groupId, uint256 _billId, address _member)
        external
        view
        returns (uint256 outstanding)
    {
        Group storage group = groups[_groupId];
        Bill storage bill = group.bills[_billId];

        require(bill.totalAmount > 0, "Bill does not exist");
        require(group.isMember[_member], "Not a member");

        uint256 expected = bill.memberShare;
        uint256 paid = bill.paidShares[_member];

        if (paid >= expected) {
            return 0; // fully paid
        } else {
            return expected - paid;
        }
    }

    /// @notice Return basic info about all goals in a group
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

    /// @notice Return basic info about all bills in a group
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

    /// @notice Get contributors and their amounts for a goal
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

    /// @notice Get bill payers and their paid amounts
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

    /// @notice Get members of a group
    function getMembers(uint256 _groupId) external view returns (address[] memory) {
        return groups[_groupId].members;
    }

    /// @notice Read how much an address contributed to a goal
    function getContribution(uint256 _groupId, uint256 _goalId, address _addr) external view returns (uint256) {
        Goal storage goal = groups[_groupId].goals[_goalId];
        return goal.contributions[_addr];
    }

    /// @notice Read how much an address paid toward a bill
    function getPaidShare(uint256 _groupId, uint256 _billId, address _addr) external view returns (uint256) {
        Bill storage bill = groups[_groupId].bills[_billId];
        return bill.paidShares[_addr];
    }

    /// @notice Get basic group info (name, creator, members)
    function getGroup(uint256 _groupId) external view returns (string memory, address, address[] memory) {
        Group storage g = groups[_groupId];
        return (g.name, g.creator, g.members);
    }
}
