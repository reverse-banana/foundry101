// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user");
    uint256 constant STARTING_BALANCE = 100 ether;
    uint256 constant SEND_VALUE = 1 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deploy = new DeployFundMe();
        fundMe = deploy.run();
    }

    
    function testUserCanFundInteractions() public {
        FundFundMe fundFundMe = new FundFundMe();

        address fundingScriptAddress = address(fundFundMe);
        // direclty funding the script address in order to dodge the revert

        vm.deal(fundingScriptAddress, STARTING_BALANCE);

        fundFundMe.fundFundMefunction(address(fundMe));

        address funder = fundMe.getFunder(0);
        assertEq(funder, fundingScriptAddress);
        // since we a directly fundring the contract which will fund the FundMe we can use it's address for assertion
    
        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        assert(address(fundMe).balance == 0);

    }
}