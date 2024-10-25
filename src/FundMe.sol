//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;

// import {AggregatorV3Interface} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

import {PriceConverter} from "./PriceConverter.sol";
error FoundMe__NotOwner();

contract FundMe{
        using PriceConverter for uint256;
        mapping(address=>uint256) public addressToAmountFounded;
        address[] public funders;
        address i_owner;
        uint256 public constant MINIMUM_USD=5*10**18;

        modifier onlyOwner{
            if(i_owner !=msg.sender)revert FoundMe__NotOwner();
            _;
        }

        constructor(){
            i_owner=msg.sender;
        }

        function fund() public payable {
            require(msg.value.getConversionRate() > MINIMUM_USD,"You Need to spend More Ethers");
            addressToAmountFounded[msg.sender]+=msg.value;
            funders.push(msg.sender);
        }
        function getVersion() public view returns(uint256){
            AggregatorV3Interface priceFeed=AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
            return priceFeed.version();
        }
        function withdraw() public onlyOwner{
            for(uint256 funderIndex=0;funderIndex < funders.length;funderIndex++){
                address funder=funders[funderIndex];
                addressToAmountFounded[funder]=0;
            }
            funders=new address[](0);
            (bool success,)=payable(msg.sender).call{value:address(this).balance}("");
            require(success,"Call Failed");
        }

        fallback() external payable{
            fund();
        }

        receive() external payable{
            fund();
        }


}