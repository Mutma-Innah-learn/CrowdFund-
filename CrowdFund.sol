// SPDX-License-Identifier: MIT
pragma solidity ^0.8.37;

contract CrowdFund {

    address public creator;

    string public title;
    string public description;
    string public imageURI;

    uint256 public goal;
    uint256 public deadline;

    uint256 public totalRaised;

    bool public withdrawn;

    mapping(address => uint256) public contributions;

    event Contribution(
        address indexed contributor,
        uint256 amount
    );

    event Withdraw(
        address indexed creator,
        uint256 amount
    );

    event Refund(
        address indexed contributor,
        uint256 amount
    );

    modifier onlyCreator() {
        require(msg.sender == creator, "Not creator");
        _;
    }

    constructor(
        address _creator,
        string memory _title,
        string memory _description,
        string memory _imageURI,
        uint256 _goal,
        uint256 _durationDays
    ) {
        require(_creator != address(0), "Invalid creator");
    require(_goal > 0, "Goal must be greater than 0");
    require(_durationDays > 0, "Duration must be greater than 0");
    
        creator = _creator;
        title = _title;
        description = _description;
        imageURI = _imageURI;
        goal = _goal;

        deadline = block.timestamp + (_durationDays * 1 days);
    }

    function contribute()
        external
        payable
    {
        require(
            block.timestamp < deadline,
            "Campaign ended"
        );

        require(
            msg.value > 0,
            "Send ETH"
        );

        contributions[msg.sender] += msg.value;

        totalRaised += msg.value;

        emit Contribution(
            msg.sender,
            msg.value
        );
    }

    function withdraw()
        external
        onlyCreator
    {
        require(
            block.timestamp >= deadline,
            "Campaign active"
        );

        require(
            totalRaised >= goal,
            "Goal not reached"
        );

        require(
            !withdrawn,
            "Already withdrawn"
        );

        withdrawn = true;

        uint256 amount =
            address(this).balance;

        (bool success,) =
            payable(creator).call{
                value: amount
            }("");

        require(success);

        emit Withdraw(
            creator,
            amount
        );
    }

    function refund()
        external
    {
        require(
            block.timestamp >= deadline,
            "Campaign active"
        );

        require(
            totalRaised < goal,
            "Goal reached"
        );

        uint256 amount =
            contributions[msg.sender];

        require(
            amount > 0,
            "No contribution"
        );

        contributions[msg.sender] = 0;

        (bool success,) =
            payable(msg.sender).call{
                value: amount
            }("");

        require(success);

        emit Refund(
            msg.sender,
            amount
        );
    }

    function getBalance()
        public
        view
        returns(uint256)
    {
        return address(this).balance;
    }
}
