pragma solidity ^0.4.23;


contract IDAO {

    // Information about the project
    function name() public view returns (string);
    function infoHash() public view returns (bytes32);
    function id() public view returns (bytes32);

    // Information about project token
    function tokenName() public view returns (string);
    function tokenSymbol() public view returns (string);

    // Contracts
    function forecasting() public view returns (address);
    function crowdsaleController() public view returns (address);
    function crowdsale() public view returns (address);
    function token() public view returns (address);

    // Ether (optional) and token reward parts
    // in millionths of collected value and tokens sold respectively
    function ethRewardPart() public view returns (uint256);
    function tokenRewardPart() public view returns (uint256);

    // Creates rewards model
    function createModel() public;

    // Creates Forecasting contract
    // Reward parts are ion millionths of appropriate amounts, _ethRewardPart may be 0
    function createForecasting(uint256 _forecastingDurationInHours, uint256 _ethRewardPart, uint256 _tokenRewardPart) public;

    // Creates buckets and starts forecasting
    function startForecasting(uint256 _bucketMin, uint256 _bucketMax, uint256 _bucketStep) public;

    // Closes forecasting after forecasting period. Calls Forecasting.checkForSpam(),
    // On success, transfers state to ForecastingClosed, if failed: to IsSpam
    function closeForecasting() public;

    // Should be called if crowdsale hasn't been created before deadline
    function crowdsaleTimeIsOver() public;

    // Create token
    function createToken(uint8 _decimals) public;

    // Creating crowdsale
    function createCrowdsale(uint256 _minimalGoal, uint256 _hardCap, uint256 _prices1to4, uint256 _prices5to8) public;

    // Creating custom crowdsale
    function createCustomCrowdsale() public;

    // Update project media asset
    function update(bytes32 _infoHash) public;

    // Stops the DAO
    function stop() public;
}
