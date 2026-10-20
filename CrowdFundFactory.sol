// SPDX-License-Identifier: MIT
pragma solidity ^0.8.37;
            
import "./CrowdFund.sol";

contract CrowdFundFactory {

    address[] public campaigns;

    event CampaignCreated(
        address campaignAddress,
        address creator,
        string title
    );
    

    function createCampaign(
        string memory _title,
        string memory _description,
        string memory _imageURI,
        uint256 _goal,
        uint256 _durationDays
    ) external {

        CrowdFund campaign =
            new CrowdFund(
                msg.sender,
                _title,
                _description,
                _imageURI,
                _goal,
                _durationDays
            );

        campaigns.push(
            address(campaign)
        );

        emit CampaignCreated(
            address(campaign),
            msg.sender,
            _title
        );
    }

    function getCampaigns()
        external
        view
        returns(address[] memory)
    {
        return campaigns;
    }
}
