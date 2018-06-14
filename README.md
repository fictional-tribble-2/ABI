# Wings ABI

Manual how to use Wings contracts ABI to create and manage your project.

## Introduction

In this manual we will be using `Node.js`, `web3` (^0.20.6) and `truffle-contract` to operate with contracts.

In order to use Wings contracts you need to have contracts ABI.  
In the `./abi` folder you can find the following contracts artifacts:
 - `Wings.json`
 - `DAO.json`
 - `CrowdsaleController.json`

Here is an example of how to initiate `Wings` contract:

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

First step in project creation process is creating a DAO. DAO is a main contract in your project hierarchy.

To create DAO perform the following actions:

```js
await wings.createDAO(name, tokenName, tokenSymbol, infoHash, customCrowdsale, { from: account })
```

**Parameters:**
 - `name` - string - name of your project
 - `tokenName` - string - name of project token
 - `tokenSymbol` - string - symbol of project token
 - `infoHash` - bytes32 - decoded ipfs hash of project description
 - `customCrowdsale` - address - address of custom crowdsale (`"0"` in case of standard crowdsale)

#### Generating infoHash

Ipfs hash is using the same Base58 encoding that Bitcoin uses.
To fit ipfs hash into `infoHash` we first will need to decode it.

**Example:**
```js
const bs58 = require('bs58')

const ipfsAddress = 'QmYwAPJzv5CZsnA625s3Xf2nemtYgPpHdWEz79ojWnPbdG'

let bytes = bs58.decode(ipfsAddress).toString('hex')

// As for now that's the only format that ipfs uses, so we can just cut the first two bytes

const infoHash = '0x' + bytes.substring(4)
```

### 2. Get DAO address

When DAO is created you can find it's address by calling Wings contract. As an argument you will have to pass keccak256 encrypted name of the project (same as the one you used during DAO creation).

```js
const daoId = web3.sha3(name)

const daoAddress = (await wings.getDAOById.call(daoId)).toString()
```

**Parameters:**
 - `name` - string - name of your project

### 3. Create Rewards Model

*Required stage: initial*

When you have DAO address, you can initiate a contract instance by address and create rewards model.

```js
const dao = DAO.at(daoAddress)

await dao.createModel({ from: account })
```

### 4. Create Forecasting

*Required stage: model created*

When rewards model is created you can create a forecasting.

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

*Required stage: forecasting created*

When the model and forecasting are created you can start forecasting.

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

*Required stage: forecasting started*

After forecasting period you can close forecasting. This will automatically check forecasting for spam.

```js
await dao.closeForecasting({ from: account })
```

## In case you are using Custom Crowdsale, skip step 7 and head to the step 8.1.

### 7. Create token

*Required stage: forecasting closed*

When forecasting is closed you can create your project token. It will have the `tokenName` and a `tokenSymbol` which you used during DAO creation process.

```js
await dao.createToken(decimals, { from: account })
```

**Parameters:**
 - `decimals` - uint8 - project token decimals

### 8. Create Crowdsale

*Required stage: token created*

When token is created you can start crowdsale.

```js
await dao.createCrowdsale(minimalGoal, hardCap, prices1to4, prices5to8, { from: account })
```

**Parameters:**
 - `minimalGoal` - uint256 - soft cap of crowdsale (in Wei)
 - `hardCap` - uint256 - hard cap of crowdsale (in Wei)
 - `prices1to4` - uint256 -
 - `prices5to8` - uint256 -

### 8.1. Create Custom Crowdsale

*Required stage: forecasting closed*

When forecasting is closed you need to call method `createCustomCrowdsale`.  
This step is required in order to finalise forecasting and reward wings community.

```js
await dao.createCustomCrowdsale({ from: account })
```

*NOTE: During this step the manager of the Crowdsale will be transferred to a newly created Crowdsale Controller.*

### 9. Get address of Crowdsale Controller

In order to start crowdsale you'll need to find the address of Crowdsale Controller, which is the contract, created during the previous step.

```js
const ccAddress = (await dao.crowdsaleController.call()).toString()
```

### 10. Start Crowdsale

When you have Crowdsale Controller address, initiate a contract instance and call the method `start`.

```js
const cc = CC.at(ccAddress)

cc.start({ from: account })
```

## Additional functions

### update

```js
await dao.update(infoHash, { from: account })
```

**Parameters:**
 -  infoHash - bytes32 - decoded ipfs hash of updated project description
