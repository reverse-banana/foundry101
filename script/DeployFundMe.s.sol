// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
function run() external returns (FundMe) {

    HelperConfig helperConfig = new HelperConfig();
    // deploting it before vm broadcast flow in order to spend less gas
    address ethUsdPriceFeed = helperConfig.activeNetworkConfig();
    // if we had mutli properties inside Networkconfig we would have to specify them as:
    // (address ethUsdPriveFeed, arg2, arg3, ... and so on)


    vm.startBroadcast();
    FundMe fundMe = new FundMe(ethUsdPriceFeed);
    vm.stopBroadcast();
    console.log(address(fundMe));
    return fundMe;
}

}
