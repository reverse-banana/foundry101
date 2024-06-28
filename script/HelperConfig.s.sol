// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;
    // declaring the var which will store actual chain data that we are on

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;
    // declaring the func args as we vars for better code reading

    struct NetworkConfig {
        address priceFeed;
    }

    // describing the properties of the custom struct

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepolialoadEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getEthMainNetConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    // fetching priceFeed based on chainid value returned in as property of struct object by function

    function getSepolialoadEthConfig()
        public
        pure
        returns (NetworkConfig memory)
    {
        NetworkConfig memory sepConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        // explicitly assigning the priceFeed vpreperty value to the inited instance of the custom struct
        return sepConfig;
    }

    function getEthMainNetConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory ethMainnet = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return ethMainnet;
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
            // check if the priceFeed alredy have a value meaning the interface mock alredy been deployed
            // and if so, we just return it's value in order not to redeploy exisitng one every time to be resource efficient
            // adress(0) used to indicate that the default value aka null or that it's doesn't exist
        }
        

        // we can't use the pure with the vm.broadcast() function (to check why)
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        // creating a new pricefeed instance and passing specified in the mocks file args

        vm.stopBroadcast();
        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });
        // passing the address of the deployed aggregator to the priceFeed attribute
        return anvilConfig;
    }
}
