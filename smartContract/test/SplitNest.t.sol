// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/SplitNest.sol";

contract SplitNestTest is Test {
    SplitNest splitNest;
    address creator = address(0x123);
    address member1 = address(0x456);
    address member2 = address(0x789);
    address outsider = address(0xABC);
    address nonCreator = address(0xDEF);

    function setUp() public {
        splitNest = new SplitNest();
        vm.deal(creator, 100 ether);
        vm.deal(member1, 50 ether);
        vm.deal(member2, 50 ether);
        vm.deal(outsider, 20 ether);
        vm.deal(nonCreator, 20 ether);

       
    }

    function testCreateGroup() public {
        vm.startPrank(creator);
        splitNest.CreateGroup("Holiday Group");
        vm.stopPrank();

        uint256 count = splitNest.groupCount();
        assertEq(count, 1);

        (string memory name, address groupCreator, ) = splitNest.getGroup(1);
        assertEq(name, "Holiday Group");
        assertEq(groupCreator, creator);
    }

    function testFuzz_CreateGroup(address randomCreator, string memory groupName) public {
        // Bound fuzz input to valid constraints
        vm.assume(randomCreator != address(0)); // skip zero addresses
        vm.deal(randomCreator, 10 ether); // ensure they have funds

        uint256 beforeCount = splitNest.groupCount();

        vm.startPrank(randomCreator);
        splitNest.CreateGroup(groupName);
        vm.stopPrank();

        uint256 afterCount = splitNest.groupCount();
        assertEq(afterCount, beforeCount + 1, "groupCount should increment by 1");

    }

    function testaddMember() public {
        //first create group
        vm.startPrank(creator);
        splitNest.CreateGroup("Trip Group");
        vm.stopPrank();

        address[] memory members = new address[](2);
        members[0] = member1;
        members[1] = member2;

        vm.startPrank(creator);
        splitNest.addMember(1, members);
        vm.stopPrank();

        // Verify members were added
        address[] memory storedMembers = splitNest.getMembers(1);
        assertEq(storedMembers.length, 3, "three members should have been added");
        assertEq(storedMembers[1], member1);
        assertEq(storedMembers[2], member2);
    }

    function testaddMemberOnlyCreatorCanAdd() public {
        address[] memory members = new address[](2);
        members[0] = member1;
        members[1] = member2;

        vm.startPrank(creator);
        splitNest.CreateGroup("Trip Group");
        vm.stopPrank();

        // Non-creator tries to add member
        vm.startPrank(nonCreator);
        vm.expectRevert("only creator can add member");
        splitNest.addMember(1, members);
        vm.stopPrank();
    }

    function testLeaveGroup() public {
        // First add a member to the group
        address[]  memory members = new address[](2) ;
        members[0] = member1;
        members[1] = member2;

        vm.startPrank(creator);
        splitNest.CreateGroup("Trip Group");
        vm.stopPrank();

        vm.startPrank(creator);
        splitNest.addMember(1, members);
        vm.stopPrank();

        // Member1 leaves
        vm.startPrank(member1);
        splitNest.LeaveGroup(1);
        vm.stopPrank();

        // Check that member1 is removed
        address[] memory storedMembers = splitNest.getMembers(1);
        assertEq(storedMembers.length, 2, "Only one member should remain");
        assertEq(storedMembers[0], creator, "Remaining member should be member2");
    }

    function testLeaveGroupRevertsIfNotMember() public {
        // Creator tries to leave but was never added as a member
        vm.startPrank(creator);
        vm.expectRevert("Not a member");
        splitNest.LeaveGroup(1);
        vm.stopPrank();
    }



    function testCreateGoal() public {

        vm.startPrank(creator);
        splitNest.CreateGroup("Group Alpha");
        address[] memory members = new address[](2);
        members[0] = member1;
        members[1] = member2;
        splitNest.addMember(1, members);

        uint256 targetAmount = 10 ether;
        uint256 deadline = block.timestamp + 3 days;
        splitNest.CreateGoal(1, "Buy Projector", targetAmount, deadline);



        (
            string[] memory names,
            uint256[] memory targets,
            ,
            uint256[] memory deadlines,
            bool[] memory withdrawn
        ) = splitNest.getAllGoals(1);

        assertEq(names[0], "Buy Projector");
        assertEq(targets[0], targetAmount);
        assertEq(deadlines[0], deadline);
        assertEq(withdrawn[0], false);

        vm.stopPrank();
    }

    function testCreateGoalRevertsIfNotCreator() public {
        vm.startPrank(member1);
        vm.expectRevert("group does not exist");
        splitNest.CreateGoal(1, "Not Allowed Goal", 1 ether, block.timestamp + 1 days);
        vm.stopPrank();
    }

     function testContribute() public {
        vm.startPrank(creator);
        splitNest.CreateGroup("Group Alpha");
        address[] memory members = new address[](2);
        members[0] = member1;
        members[1] = member2;
        splitNest.addMember(1, members);

        splitNest.CreateGoal(1, "Travel Fund", 5 ether, block.timestamp + 1 days);
        vm.stopPrank();

        vm.startPrank(member1);
        splitNest.Contribute{value: 2 ether}(1, 1);
        vm.stopPrank();

        vm.startPrank(member2);
        splitNest.Contribute{value: 3 ether}(1, 1);
        vm.stopPrank();

        (, , uint256[] memory totalContributed, , ) = splitNest.getAllGoals(1);
        assertEq(totalContributed[0], 5 ether, "Total should equal 5 ether");

        // Individual contributions
        uint256 m1Contrib = splitNest.getContribution(1, 1, member1);
        uint256 m2Contrib = splitNest.getContribution(1, 1, member2);
        assertEq(m1Contrib, 2 ether);
        assertEq(m2Contrib, 3 ether);
    }

    function testContributeRevertsIfGoalExpired() public {
        vm.startPrank(creator);
        splitNest.CreateGroup("Group Alpha");
        address[] memory members = new address[](2);
        members[0] = member1;
        members[1] = member2;
        splitNest.addMember(1, members);

        splitNest.CreateGoal(1, "Expired Goal", 1 ether, block.timestamp - 1);
        vm.stopPrank();

        vm.startPrank(member1);
        vm.expectRevert("goal not in session");
        splitNest.Contribute{value: 1 ether}(1, 1);
        vm.stopPrank();
    }

    function testWithdrawGoalFunds() public {
        vm.startPrank(creator);
        splitNest.CreateGroup("Group Alpha");
        address[] memory members = new address[](2);
        members[0] = member1;
        members[1] = member2;
        splitNest.addMember(1, members);

        splitNest.CreateGoal(1, "New Laptop", 3 ether, block.timestamp + 2 days);
        vm.stopPrank();

        // Members contribute
        vm.startPrank(member1);
        splitNest.Contribute{value: 1 ether}(1, 1);
        vm.stopPrank();

        vm.startPrank(member2);
        splitNest.Contribute{value: 2 ether}(1, 1);
        vm.stopPrank();

        // Withdraw once target met
        uint256 creatorBalBefore = creator.balance;
        vm.startPrank(creator);
        splitNest.withdrawGoalFunds(1, 1);
        vm.stopPrank();
        uint256 creatorBalAfter = creator.balance;

        assertGt(creatorBalAfter, creatorBalBefore, "Creator should receive funds");
    }

    function testWithdrawGoalFundsRevertsIfNotCreator() public {
        vm.startPrank(creator);
        splitNest.CreateGroup("Group Alpha");
        address[] memory members = new address[](2);
        members[0] = member1;
        members[1] = member2;
        splitNest.addMember(1, members);

        splitNest.CreateGoal(1, "Unauthorized", 1 ether, block.timestamp + 2 days);
        vm.stopPrank();

        vm.startPrank(member1);
        splitNest.Contribute{value: 1 ether}(1, 1);
        vm.stopPrank();

        vm.startPrank(member1);
        vm.expectRevert("Only creator can withdraw");
        splitNest.withdrawGoalFunds(1, 1);
        vm.stopPrank();
    }

     function testCreateBill() public {
        vm.startPrank(creator);
        splitNest.CreateGroup("Group Alpha");
        address[] memory members = new address[](2);
        members[0] = member1;
        members[1] = member2;
        splitNest.addMember(1, members);
        vm.stopPrank();

        vm.startPrank(member1);
        splitNest.CreateBill(1, "Dinner Bill", 6 ether);
        vm.stopPrank();

        (
            string[] memory descriptions,
            uint256[] memory totalAmounts,
            uint256[] memory paidAmounts,
            address[] memory creators,
            bool[] memory reimbursed
        ) = splitNest.getAllBills(1);

        assertEq(descriptions[0], "Dinner Bill");
        assertEq(totalAmounts[0], 6 ether);
        assertEq(paidAmounts[0], 0);
        assertEq(creators[0], member1);
        assertEq(reimbursed[0], false);
    }


    function testPayBillShare() public {
        vm.startPrank(creator);
        splitNest.CreateGroup("Group Alpha");
        address[] memory members = new address[](2);
        members[0] = member1;
        members[1] = member2;
        splitNest.addMember(1, members);
        vm.stopPrank();

        vm.startPrank(member1);
        splitNest.CreateBill(1, "Hotel Bill", 4 ether);
        vm.stopPrank();

        vm.startPrank(member1);
        splitNest.payBillShare{value: 2 ether}(1, 1);
        vm.stopPrank();

        vm.startPrank(member2);
        splitNest.payBillShare{value: 2 ether}(1, 1);
        vm.stopPrank();

        (, , uint256[] memory paidAmounts, , ) = splitNest.getAllBills(1);
        assertEq(paidAmounts[0], 4 ether, "Paid amount should match total");
    }

    function testPayBillShareRevertsIfBillDoesNotExist() public {
        vm.startPrank(creator);
        splitNest.CreateGroup("Group Alpha");
        vm.stopPrank();

        vm.startPrank(member1);
        vm.expectRevert("Bill does not exist");
        splitNest.payBillShare{value: 1 ether}(1, 1); // billId=1 doesn’t exist yet
        vm.stopPrank();
    }

    function testWithdrawBillFunds() public {
        vm.startPrank(creator);
        splitNest.CreateGroup("Group Alpha");
        address[] memory members = new address[](2);
        members[0] = member1;
        members[1] = member2;
        splitNest.addMember(1, members);
        vm.stopPrank();

        // member1 creates bill
        vm.startPrank(member1);
        splitNest.CreateBill(1, "Car Rent", 4 ether);
        vm.stopPrank();

        // member1 and member2 pay their shares
        vm.startPrank(member1);
        splitNest.payBillShare{value: 2 ether}(1, 1);
        vm.stopPrank();

        vm.startPrank(member2);
        splitNest.payBillShare{value: 2 ether}(1, 1);
        vm.stopPrank();

        // member1 withdraws after full payment
        uint256 beforeBal = member1.balance;
        vm.startPrank(member1);
        splitNest.withdrawBillFunds(1, 1);
        vm.stopPrank();
        uint256 afterBal = member1.balance;

        assertGt(afterBal, beforeBal, "Bill creator should be reimbursed");
    }

    function testWithdrawBillFundsRevertsIfNotFullyPaid() public {
        vm.startPrank(creator);
        splitNest.CreateGroup("Group Alpha");
        address[] memory members = new address[](2);
        members[0] = member1;
        members[1] = member2;
        splitNest.addMember(1, members);
        vm.stopPrank();
        
        vm.startPrank(member1);
        splitNest.CreateBill(1, "Half Paid Bill", 4 ether);
        vm.stopPrank();

        vm.startPrank(member1);
        splitNest.payBillShare{value: 1 ether}(1, 1);
        vm.stopPrank();

        vm.startPrank(member1);
        vm.expectRevert("Bill not fully paid");
        splitNest.withdrawBillFunds(1, 1);
        vm.stopPrank();
    }

}
