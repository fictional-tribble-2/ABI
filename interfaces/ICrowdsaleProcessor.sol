pragma solidity ^0.4.23;


// Crowdsale contracts interface
contract ICrowdsaleProcessor {

  // Minimal acceptable hard cap
  function MIN_HARD_CAP() public view returns (uint256);

  // Minimal acceptable duration of crowdsale
  function MIN_CROWDSALE_TIME() public view returns (uint256);

  // Maximal acceptable duration of crowdsale
  function MAX_CROWDSALE_TIME() public view returns (uint256);

  // Becomes true when timeframe is assigned
  function started() public view returns (bool);

  // Becomes true if cancelled by owner
  function stopped() public view returns (bool);

  // Total collected Ethereum: must be updated every time tokens has been sold
  function totalCollected() public view returns (uint256);

  // Total amount of project's token sold: must be updated every time tokens has been sold
  function totalSold() public view returns (uint256);

  // Crowdsale minimal goal, must be greater or equal to Forecasting min amount
  function minimalGoal() public view returns (uint256);

  // Crowdsale hard cap, must be less or equal to Forecasting max amount
  function hardCap() public view returns (uint256);

  // Crowdsale duration in seconds.
  // Accepted range is MIN_CROWDSALE_TIME..MAX_CROWDSALE_TIME.
  function duration() public view returns (uint256);

  // Start timestamp of crowdsale, absolute UTC time
  function startTimestamp() public view returns (uint256);

  // End timestamp of crowdsale, absolute UTC time
  function endTimestamp() public view returns (uint256);

  // Allows to transfer some ETH into the contract without selling tokens
  function deposit() public payable;

  // Returns address of crowdsale token, must be ERC20 compilant
  function getToken() public view returns (address);

  // Is crowdsale failed (completed, but minimal goal wasn't reached)
  function isFailed() public view returns (bool);

  // Is crowdsale active (i.e. the token can be sold)
  function isActive() public view returns (bool);

  // Is crowdsale completed successfully
  function isSuccessful() public view returns (bool);
}
