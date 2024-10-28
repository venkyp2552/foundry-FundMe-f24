//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
// import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

import {PriceConverter} from "./PriceConverter.sol";
error FoundMe__NotOwner();

contract FundMe{
        using PriceConverter for uint256;
        mapping(address=>uint256) private s_addressToAmountFounded;
        address[] private s_funders;
        address private i_owner;
        uint256 public constant MINIMUM_USD=5*10**18;
        AggregatorV3Interface private s_priceFeed;
        modifier onlyOwner{
            if(i_owner !=msg.sender)revert FoundMe__NotOwner();
            _;
        }

        constructor(address priceFeed){
            i_owner=msg.sender;
            s_priceFeed=AggregatorV3Interface(priceFeed);
        }

        function fund() public payable {
            require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD, "You need to spend more ETH!");
            s_addressToAmountFounded[msg.sender] += msg.value;
            s_funders.push(msg.sender);
        }
        function getVersion() public view returns(uint256){
            // AggregatorV3Interface priceFeed=AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
            // return priceFeed.version();
            return s_priceFeed.version();
        }
        function withdraw() public onlyOwner{
            for(uint256 funderIndex=0;funderIndex < s_funders.length;funderIndex++){
                address funder=s_funders[funderIndex];
                s_addressToAmountFounded[funder]=0;
            }
            s_funders=new address[](0);
            (bool success,)=payable(msg.sender).call{value:address(this).balance}("");
            require(success,"Call Failed");
        }

        fallback() external payable{
            fund();
        }

        receive() external payable{
            fund();
        }

        // view / Pure Fucntion
        function getAddressToAmountFounded(address fundingAddress) external view returns (uint256){
            return s_addressToAmountFounded[fundingAddress];
        }

        function getFunder(uint256 index) external view returns(address){
            return s_funders[index];
        }

        function getOwner() external view returns(address){
            return i_owner;
        }

}