pragma solidity ^0.4.23;


contract IForecasting {
  function addForecast(uint256 _amount, bytes32 _message) public;
  function changeForecast(uint256 _amount, bytes32 _message) public;

  // Account closes its forecast and gets wings unlocked.
  // Depends on current stage:
  // 1) if stats are not ready then this is considered cancellation and the account gets negative dFR;
  // 2) if stats are made then the account gets dFR according to its accuracy
  // and then it take rewards as soon as they are available
  function closeForecast() public;
}
