// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "src/FundMe.sol";

contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 0.1 ether;
    // uint256 constant STARTING_BALANCE = 10 ether;
    // address funder = makeAddr("funder");


    // function getTestFunderAddress() external view returns (address) {
       // return funder;
    // }

    function fundFundMefunction(address latestDeployedAddress) public {
        FundMe fundMeContract = FundMe(payable(latestDeployedAddress));
        // vm.deal(funder, STARTING_BALANCE);
        // vm.prank(funder);
        fundMeContract.fund{value: SEND_VALUE}();
    }

    function run() external {
        address latestDeployedAddress = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );

        // the prank to send tx from the user can't be used with broadcast option
        vm.startBroadcast();
        fundFundMefunction(latestDeployedAddress);
        vm.stopBroadcast();
    }
}







contract WithdrawFundMe is Script {
    function withdrawFundMe(address latestDeployedAddress) public {
        vm.startBroadcast();
        FundMe(payable(latestDeployedAddress)).withdraw();
        vm.stopBroadcast();
    }

    function run() external {
        address latestDeployedAddress = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        // look to the latest deployed contract by name and grabs from the broadcast folder based on chainid)
        vm.startBroadcast();
        withdrawFundMe(latestDeployedAddress);
        vm.stopBroadcast();
    }
}
