//We are using this once inteact with our Fund and Withdraw functions

//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;

import {Script} from "lib/forge-std/src/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";
import {console} from "lib/forge-std/src/Script.sol";

contract FundFundMe is Script {
    uint256 constant SEND_VALUE= 0.1 ether;

    function fundFundMe(address mostRecenltyDeployed) public {
         vm.startBroadcast();
        FundMe(payable(mostRecenltyDeployed)).fund{value:SEND_VALUE}();
         vm.stopBroadcast();
        console.log("Funded FundMe with %s",SEND_VALUE);
    }

    function run() external {
        address mostRecentlyDeployed=DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        fundFundMe(mostRecentlyDeployed);
       

    }
}

contract WithdrawFundMe is Script {
    function withdrawFundMe(address mostRecenltyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecenltyDeployed)).withdraw();
        vm.stopBroadcast();
        console.log("Withdraw FundMe balance!");
    }

    function run() external{
        address mostRecentlyDeployed=DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        withdrawFundMe(mostRecentlyDeployed);
    }
}