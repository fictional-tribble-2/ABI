pragma solidity ^0.4.23;


contract CrowdsaleController {

    // Is 3rd party contract
    function is3rdParty() public view returns (bool);

    // Detect if forecasting closed
    function forecastingClosed() public view returns (bool);

    // Ether (optional) and token reward parts
    // in millionths of collected value and tokens sold respectively
    function ethRewardPart() public view returns (uint256);
    function tokenRewardPart() public view returns (uint256);

    // Deadline timestamp to start crowdsale (end of forecasting period + 7 days)
    function crowdsaleStartDeadline() public view returns (uint256);

    // Max 7 days to start if it's not 3rd party contract (review time)
    function start(uint256 _startTimestamp, uint256 _endTimestamp, address _fundingAddress) public;

    // Close forecasting
    function closeForecasting() public;
}
