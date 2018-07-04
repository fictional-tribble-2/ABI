pragma solidity ^0.4.23;


contract Wings {

    // Creates new DAO
    function createDAO(string _name, string _tokenName, string _tokenSymbol, bytes32 _infoHash, address _customCrowdsale) public;

    // Get DAO by Id
    function getDAOById(bytes32 _daoId) public view returns (address);

    // Add forecaster to DAO by dao id
    function addForecasterToDAO(bytes32 _daoId) public;
}
