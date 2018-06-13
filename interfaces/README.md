# Wings ABI

Manual how to use Wings contracts ABI to create and manage your project.

## Introduction

In this manual we will be using `Node.js`, `web3` (^0.20.6) and `truffle-contract` to operate with contracts.

```js
const contract = require('truffle-contract')
const Web3 = require('web3')

const wingsArtifact = require('./abi/Wings.json')

const Wings = contract.at(wingsArtifact)

Wings.setProvider(new Web3.providers.HttpProvider(web3Provider))

const wingsAddress = '0x7ea8dc2b2b00b596d077b68f5c891e03797a5eb2'

const wings = Wings.at(wingsAddress)
```

# Step by step

### 1. Create DAO

```js
await wings.createDAO(name, tokenName, tokenSymbol, infoHash, customCrowdsale, { from: account })
```

**Parameters:**
 - `name` - string - name of your project
 - `tokenName` - string - name of project token
 - `tokenSymbol` - string - symbol of project token
 - `infoHash` - bytes32 - ipfs hash of project description
 - `customCrowdsale` - address - address of custom crowdsale (`"0"` in case of standard crowdsale)

### 2. Get DAO address

```js
const daoId = web3.sha3(name)

const daoAddress = (await wings.getDAOById.call(daoId)).toString()
```

**Parameters:**
 - `name` - string - name of your project

### 3. Create Rewards Model

```js
const dao = DAO.at(daoAddress)

await dao.createModel({ from: account })
```

### 4. Create Forecasting

```js
await dao.createForecasting(forecastingDurationInHours, ethRewardPart, tokenRewardPart, { from: account })
```

**Parameters:**
 - `forecastingDurationInHours` - uint256 - duration of forecasting in hours (from 120 to 360 hours)
 - `ethRewardPart` - uint256 - reward percent of total collected Ether
 - `tokenRewardPart` - uint256 - reward percent of total sold tokens

*NOTE: reward percent must be multiplied by 10000.*

*Example: reward is 1.5% the argument must be passed as 15000.*

### 5. Start Forecasting

```js
await dao.startForecasting(bucketMin, bucketMax, bucketStep, { from: account })
```

**Parameters:**
 - `bucketMin` - uint256 - minimal bucket
 - `bucketMax` - uint256 - maximal bucket
 - `bucketStep` - uint256 - bucket step

#### Calculate buckets

The following code demonstrates the algorithm of buckets calculation.

```js
const ONE_ETH = new BigNumber('1000000000000000000')
const STEPS_IN_GOAL = 100
const STEPS_IN_MAX_AMOUNT = 150

const weiGoal = new BigNumber(web3.toWei(goal, 'ether'))

let bucketMin, bucketStep, bucketMax

let ethGoal = Number(weiGoal.div(ONE_ETH).floor())

if (ethGoal < STEPS_IN_GOAL) {
  ethGoal = STEPS_IN_GOAL
}

if (ethGoal < STEPS_IN_GOAL*1.1) {
  bucketMin = ONE_ETH
  bucketStep = ONE_ETH
  bucketMax = ONE_ETH.mul(STEPS_IN_MAX_AMOUNT)
} else {
  let e = Math.floor((ethGoal / (STEPS_IN_GOAL + 1)));
  let p = Math.floor(Math.log10(e));
  let c = Math.floor(Math.pow(10, p));
  let d = Math.floor((e / c));


  if (d < 2) d = 2;
  else if (d < 5) d = 5;
  else d = 10;

  bucketStep = ONE_ETH.mul(d).mul(c)
  bucketMin = bucketStep
  bucketMax = bucketStep.mul(STEPS_IN_MAX_AMOUNT)
}
```

### 6. Finish Forecasting

```js
await dao.closeForecasting({ from: account })
```

### 7. Create token

```js
await dao.createToken(decimals, { from: account })
```

**Parameters:**
 - `decimals` - uint8 - project token decimals

### 8. Create Crowdsale

```js
await dao.createCrowdsale(minimalGoal, hardCap, prices1to4, prices5to8, { from: account })
```

**Parameters:**
 - `minimalGoal` - uint256 - soft cap of crowdsale (in Wei)
 - `hardCap` - uint256 - hard cap of crowdsale (in Wei)
 - `prices1to4` - uint256 -
 - `prices5to8` - uint256 -

### 9. Get address of CrowdsaleController

```js
const ccAddress = (await dao.crowdsaleController.call()).toString()
```

### 10. Start Crowdsale

```js
const cc = CC.at(ccAddress)

cc.start({ from: account })
```
