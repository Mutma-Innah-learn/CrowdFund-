// SPDX-License-Identifier: MIT
pragma solidity ^0.8.37;

import "forge-std/Test.sol";

import "../src/CrowdFund.sol";
import "../src/CrowdFundFactory.sol";

contract CrowdFundFactoryTest is Test {
    CrowdFundFactory factory;

    address creator = address(1);
    address contributor = address(2);

    function setUp() public {
        factory = new CrowdFundFactory();
    }

    function testFactoryDeployment() public {
        assertEq(factory.getCampaigns().length, 0);
    }

    function testCreateCampaign() public {
        vm.prank(creator);

        factory.createCampaign(
            "Save The World",
            "Test Description",
            "image.png",
            1 ether,
            30
        );

        address[] memory campaigns = factory.getCampaigns();

        assertEq(campaigns.length, 1);

        CrowdFund campaign = CrowdFund(campaigns[0]);

        assertEq(campaign.creator(), creator);
        assertEq(campaign.goal(), 1 ether);
    }

    function testContribution() public {
        vm.prank(creator);

        factory.createCampaign(
            "Test",
            "Desc",
            "img",
            1 ether,
            30
        );

        CrowdFund campaign =
            CrowdFund(factory.getCampaigns()[0]);

        vm.deal(contributor, 2 ether);

        vm.prank(contributor);

        campaign.contribute{value: 1 ether}();

        assertEq(
            campaign.contributions(contributor),
            1 ether
        );

        assertEq(
            campaign.totalRaised(),
            1 ether
        );
    }

    function testRefund() public {
        vm.prank(creator);

        factory.createCampaign(
            "Test",
            "Desc",
            "img",
            5 ether,
            30
        );

        CrowdFund campaign =
            CrowdFund(factory.getCampaigns()[0]);

        vm.deal(contributor, 1 ether);

        vm.prank(contributor);
        campaign.contribute{value: 1 ether}();

        vm.warp(block.timestamp + 31 days);

        vm.prank(contributor);
        campaign.refund();

        assertEq(
            campaign.contributions(contributor),
            0
        );
    }

    function testWithdrawSuccess() public {
        vm.prank(creator);

        factory.createCampaign(
            "Test",
            "Desc",
            "img",
            1 ether,
            30
        );

        CrowdFund campaign =
            CrowdFund(factory.getCampaigns()[0]);

        vm.deal(contributor, 2 ether);

        vm.prank(contributor);
        campaign.contribute{value: 1 ether}();

        vm.warp(block.timestamp + 31 days);

        uint256 creatorBalanceBefore =
            creator.balance;

        vm.prank(creator);
        campaign.withdraw();

        uint256 creatorBalanceAfter =
            creator.balance;

        assertGt(
            creatorBalanceAfter,
            creatorBalanceBefore
        );
    }

    function testCannotCreateCampaignWithZeroGoal() public {
        vm.expectRevert(
            bytes("Goal must be greater than 0")
        );

        new CrowdFund(
            creator,
            "title",
            "description",
            "image",
            0,
            30
        );
    }

    function testCannotCreateCampaignWithZeroDuration() public {
        vm.expectRevert(
            bytes("Duration must be greater than 0")
        );

        new CrowdFund(
            creator,
            "title",
            "description",
            "image",
            1 ether,
            0
        );
    }
}
