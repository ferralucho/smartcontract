// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./simplecoin.sol";

contract Crowdsale {

    // Owner represents the address who deployed the contract.
    address public Owner;

    // IsFinalized indicates if the contract has been finalized.
    bool public IsFinalized;

    // IsRefundingAllowed indicates whether refunding is allowed.
    bool public IsRefundingAllowed;

    // StartTime represents the start of the crowdsale funding stage in UNIX epoch.
    uint256 public StartTime;

    // EndTime represents the end of the crowdsale funding stage in UNIX epoch.
    uint256 public EndTime;

    // WeiTokenPrice represents the price of the token being sold.
    uint256 public WeiTokenPrice;

    // WeiInvestmentObjective represents the investment objective, which defines if the crowdsale is successful.
    uint256 public WeiInvestmentObjective;


    // InvestmentAmountOf represents the amount of Ether received from each investor.
    mapping (address => uint256) public InvestmentAmountOf;

    // InvestmentReceived represents the total Ether received from the investors.
    uint256 public InvestmentReceived;

    // InvestmentRefunded represents the total Ether refunded to the investors.
    uint256 public InvestmentRefunded;


    // CrowdSaleToken represents the contract of the token being sold.
    ReleasableSimpleCoin public CrowdSaleToken;


    // EventLog provides support for external logging.
    event EventLog(string value);

    // EventInvestment is an event to indicate an investment was made.
    event EventInvestment(address indexed investor, uint256 value);

    // EventTokenAssignment is an event to indicate a token was assigned.
    event EventTokenAssignment(address indexed investor, uint256 numTokens);

    // EventRefund is an event to indicate a refund was provided.
    event EventRefund(address investor, uint256 value);


    // constructor is called when the contract is deployed.
    constructor(uint256 startTime, uint256 endTime, uint256 weiTokenPrice, uint256 etherInvestmentObjective) {
        require(startTime >= block.timestamp,  "start time must be greater than the current block timestamp");
        require(endTime >= startTime,          "end time must be greater than or equal to the startTime");
        require(weiTokenPrice != 0,            "wei token price must be greater than zero");
        require(etherInvestmentObjective != 0, "ether investment objective must be greater than zero");

        Owner                  = msg.sender;
        IsFinalized            = false;
        IsRefundingAllowed     = false;
        StartTime              = startTime;
        EndTime                = endTime;
        WeiTokenPrice          = weiTokenPrice;
        WeiInvestmentObjective = etherInvestmentObjective * 1000000000000000000;
        CrowdSaleToken         = new ReleasableSimpleCoin(0);
    }

    // Restricts functions to only be accessed by the owner.
    modifier onlyOwner {
        if (msg.sender != Owner) revert();
        _;
    }


    // Invest allows an investor to book crowdsale tokens. (No parameter is necessary
    // to specify the amount of Ether being invested because it’s being sent through
    // the msg.value property.
    function Invest() public payable {
        Error.Err memory err = validateInvestment(msg.value);
        if (err.isError) {
            revert(err.msg);
        }

        address investor   = msg.sender;
        uint256 investment = msg.value;

        InvestmentAmountOf[investor] += investment;
        InvestmentReceived           += investment;

        assignTokens(investor, investment);

        emit EventInvestment(investor, investment);
        emit EventLog(string.concat("investor ", Error.Addrtoa(investor), " received investment of ", Error.Itoa(investment)));
    }

    // Finalize allows the crowdsale organizer, who is the contract owner, to release
    // tokens to the investors, in case of successful completion, and grant a bonus
    // to the development team, if applicable.
    function Finalize() onlyOwner public {
        if (IsFinalized) {
            revert("crowdsale is already finalized");
        }
        
        // Check if the time has come to finalize the crowdsale.
        // if (block.timestamp < EndTime) {
        //     revert("too early to finalize crowdsale");
        // }

        // If the investment objective was met release the token, else
        // set the flag to refund the coins.
        if (InvestmentReceived >= WeiInvestmentObjective) {
            CrowdSaleToken.Release();
            emit EventLog("objective met, releasing funds");
        } else {
            IsRefundingAllowed = true;
            emit EventLog("objective not met, releasing refund");
        }

        // Mark this crowdsale as finalized.
        IsFinalized = true;
    }

    // Refund allows an investor to get a refund in case of unsuccessful completion.
    function Refund() public payable {
        if (!IsRefundingAllowed) {
            revert("refund is not allowed at this time");
        }

        address investor = msg.sender;
        uint256 investment = InvestmentAmountOf[investor];

        if (investment == 0) {
            revert("this investor has no money to refund");
        }

        InvestmentAmountOf[investor] = 0;
        InvestmentRefunded += investment;
        
        emit EventRefund(investor, investment);
        emit EventLog(string.concat("refund of ", Error.Itoa(investment), " provided to investor ", Error.Addrtoa(investor)));

        if (!payable(investor).send(investment)) {
            revert("unable to send investment to investor");
        }
    }


    // validateInvestment validates the specified investment.
    function validateInvestment(uint256 investment) internal pure returns (Error.Err memory) {

        // Checks if this is a meaningful investment.
        if (investment == 0) {
            return Error.New("investment must be greater than zero dollars");
        }

        // Check if this is taking place before the start date.
        // if (block.timestamp < StartTime) {
        //     return Error.New("crowdsale funding stage hasn't started");
        // }

        // Check if this is taking place after the end date.
        // if (block.timestamp > EndTime) {
        //     return Error.New("crowdsale funding stage ended");
        // }
        
        return Error.None();
    }

    // assignTokens performs the token management.
    function assignTokens(address beneficiary, uint256 investment) internal {

        // Calculates the number of tokens corresponding to the investment.
        uint256 numberOfTokens = calculateNumberOfTokens(investment);

        // Generates the tokens in the investor account.
        CrowdSaleToken.Mint(beneficiary, numberOfTokens);
    }

    // calculateNumberOfTokens uses the WeiTokenPrice to calculate the number of
    // tokens being pruchased by this investment.
    function calculateNumberOfTokens(uint256 investment) internal view returns (uint256) {
        return investment / WeiTokenPrice;
    }
}
