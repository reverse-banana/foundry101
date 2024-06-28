// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// Note: The AggregatorV3Interface might be at a different location than what was in the video!
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error FundMe__NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    mapping(address => uint256) private s_addressToAmountFunded;
    address[] private s_funders;

    // Could we make this constant?  /* hint: no! We should make it immutable! */
    address private immutable  i_owner;
    uint256 private constant MINIMUM_USD = 5e18;
    AggregatorV3Interface private s_priceFeed;
    // declaration of the interface instance struct variable as part of the refactoring process
    // the AggregatorV3Interface is used to specify that var will have access to the interface provided fucntions

    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    // creating a modular variable for contract interface address that should be specified during a deploy of contract  instead of hardcode
    // in order to reuse the values from the constructor we should pass them to the global vars

    }

    function fund() public payable {
        require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD, "You need to spend more ETH!");
        
        s_addressToAmountFunded[msg.sender] += msg.value;
        s_funders.push(msg.sender);
    }

    function getVersion() public view returns (uint256) {
        // AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        // return priceFeed.version();
        return s_priceFeed.version();
        // since we are created and init the instance of the interface in the constructor 
        // we can reuse the var in the interface related func instead of initing it every time
    }

    modifier onlyOwner() {
        // require(msg.sender == owner);
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        _;
    }

    function withdraw() public onlyOwner {
        uint256 fundersLength = s_funders.length;
        // creating a memory for gas saving purposes
        for (uint256 funderIndex = 0; funderIndex < fundersLength; funderIndex++) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        // transfer optiom
        // payable(msg.sender).transfer(address(this).balance);

        //  send option
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");

        // call
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }
   

    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }

    // functions view / pure (getters)

    function getAddressToAmountFunded(
        address fundingAddress
        ) external view returns (uint256) {
            return s_addressToAmountFunded[fundingAddress];
        }
        // creating a getter function to fetch the amount of fund based on the passed address

    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }
        // getter func to retrive the address of the funder based on passed index

    function getMinimumUSDAmountValue() external pure returns (uint256) {
        return MINIMUM_USD;
    }
    // getting the min usd amount due it's visibility type
    // seens that pure only works with static values only that are set before even the compile was done

    function getOwner() external view returns (address) {
        return i_owner;
    }    
    // fetching the owner address
}
