//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;

import {console} from "lib/forge-std/src/Script.sol";
import {Test} from "lib/forge-std/src/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test{
        FundMe fundMe;
        address USER =makeAddr('user');
        uint256 constant SEND_VALUE=0.1 ether;
        uint256 constant STARTING_BALANCE=10 ether;

    function setUp() external{
        // fundMe=new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe=new DeployFundMe();
        fundMe=deployFundMe.run();
        vm.deal(USER,STARTING_BALANCE);
    }

    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5*10**18);
    }

    function testOwnerIsMsgSender() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public view {
        uint256 version=fundMe.getVersion();
        // here for Main net version is 6 and sepolia test version is 4 for PriceFeedAdress
        assertEq(version,4);
    }

    function testFundFailsWithoutEnoughETH() public  {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER); //The next trnx will be snet by USER
        fundMe.fund{value:SEND_VALUE}();
        uint256 fundedAmount=fundMe.getAddressToAmountFounded(USER);
        assertEq(fundedAmount,SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value:SEND_VALUE}();
        address funder=fundMe.getFunder(0);
        assertEq(funder,USER);
    }
    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value:SEND_VALUE}();
        _;
    }
    function testOnlyOwnerCanWithdraw() public funded(){
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithDrawWithASingleFunder() public funded(){
        //Arrange
        uint256 startingOwnerBalance=fundMe.getOwner().balance;
        uint256 startingFundingBalance=address(fundMe).balance;
        //Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        //Assert
        uint256 endingOwnerBalance=fundMe.getOwner().balance;
        uint256 endingFundingBalance=address(fundMe).balance;
        assertEq(endingFundingBalance,0);
        assertEq(startingOwnerBalance+startingFundingBalance,endingOwnerBalance);
    }

    function testWithdrawFromMultipleFunders() public funded(){
        uint160 numberOfFunders=10;
        uint160 startingFundingIndex=1;
        for(uint160 i = startingFundingIndex;i<numberOfFunders;i++){
            //Now we want add some money to address instaed of using deal method we can use hoax method here it will alsowork same 
            hoax(address(i),SEND_VALUE);
            fundMe.fund{value:SEND_VALUE}();
        }
        uint256 startingOwnerBalance=fundMe.getOwner().balance;
        uint256 startingFundMeBalance=address(fundMe).balance;

        //Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        //assert
        assertEq(address(fundMe).balance,0);
        assertEq(startingOwnerBalance+startingFundMeBalance,fundMe.getOwner().balance);
        }
}