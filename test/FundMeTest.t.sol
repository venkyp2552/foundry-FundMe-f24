//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;

import {console} from "lib/forge-std/src/Script.sol";
import {Test} from "lib/forge-std/src/Test.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundMeTest is Test{
        FundMe fundMe;

    function setUp() external{
        fundMe=new FundMe();
    }

    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5*10**18);
    }

    function testOwnerIsMsgSender() public {
        assertEq(fundMe.i_owner(), address(this));

    }
}