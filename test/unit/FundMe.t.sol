// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    // declaring the fundMe instance which we will be testing

    address USER = makeAddr("user");
    // creating a test address for the thx sending and assigning it's value to the var
    uint256 constant SEND_VALUE = 0.1 ether;
    // decl const varin order to avoid magic number in the code
    uint256 constant STARTING_BALANCE = 100 ether;
    uint256 constant GAS_PRICE = 1;
    // setting the gas price for accurate simulation

    // balance of the test user that will be assigned;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        // creating an instance of the deploy script from which we will be deploying our contract
        fundMe = deployFundMe.run();
        // assigning the deployed instance to the var info to the local inited var
        // the .run() will return the contract with pricefeed based on the Network config file logic

        vm.deal(USER, STARTING_BALANCE);
        //  assign a newly created test user address a balance specified in the STARTING_BALANCE var
    }

    //                       ACTUALS TESTS
    // worth to mention that implementing the getters in the tested code provide very efficinet way to retrieve data and improve the test coverage of the code

    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.getMinimumUSDAmountValue(), 5e18);

        // asserting that min usd var is equal to 5e18
    }

    function testOwnerIsMsgSender() public view {
        assertEq(fundMe.getOwner(), msg.sender);
        // seeying the we as sender don't deploy the contract cause it deployed in the FundMeTest contract
        // address(this) point to the current contract address where the function in stored
    }

    function testVersionNumber() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
        // asserting that version = 4
    }

    function testFundFailsWithoutEnoughtETH() public {
        vm.expectRevert(); // expecting that next line shoud be reverted in order to test to pass
        // can be thought of as assert(this tnx fails/reverts)
        fundMe.fund();
        // will pass cause we didn't anything as should with {value: amount}
    }

    modifier funded() {
        vm.prank(USER); // specifing that the next tnx will be sent by USER
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testFundUpdatesFundedDataStructures() public funded {
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        // decl a var that is holding a value of the thx associated with passed address in the dict
        assertEq(amountFunded, SEND_VALUE);
        // asserting that amount that we retrived from the dics is equal to the amount we actually send
    }

    function testAddsFunderToArrayOfFunders() public funded {
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
        // due to the test flow every, at the end of each test function the setup()  will be executed (we will be reseting every signle time
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert(); // revert targets the next tnx, ignoring the vm keywords line (fyi)
        vm.prank(USER); // seems we have to use prank every time before each tnx we want to make from the test user
        fundMe.withdraw();
    }

    function testWithdrawByRealOwnerOneFunder() public funded {
        // arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        // snapshoting the balance value of the owner and the contract

        // act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        // second snapshot after performing the withdraw operation

        assertEq(endingFundMeBalance, 0);
        // making sure we withdraw all funds
        assertEq(startingOwnerBalance + startingFundMeBalance, endingOwnerBalance);
        // checksum to make sure the balances after tnx are correct
    }

    function testWithdrawByRealOwnerMultipleFunders() public funded {
        // arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        // in order to use ints with adresses type casting we need to use int160
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i));
            // simulate the thnx from the given address and eth amount as the balance as seconds argument
            // if no balance for hoax addr specified it will default to the 2^128 wei (huge amount of eth)
            fundMe.fund{value: SEND_VALUE}();
            // fund the contract from the address the loop iterating now on
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        // snapshoting balances

        // act
        uint256 gasStart = gasleft();
        // build in solidity func that showes how many gas left from the allocated portion for particular tx
        vm.txGasPrice(GAS_PRICE); // sets the gas price for the rest of the tx
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();
        // anything beetween the start and stop prank will be sent from the address specified from the startPrank

        uint256 gasEnd = gasleft();
        // checking how much gas left after tx was done

        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        // calculating the  gas price for the particular func
        console.log(gasUsed);

        // assert

        assert(address(fundMe).balance == 0);
        // making sure we withdraw all funds
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
        // logical checksum after withdraw operation


    }
}
