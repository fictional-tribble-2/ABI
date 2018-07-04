# Wings Forecaster ABI

Manual how to use Wings contracts ABI to make forecast.

## Introduction

In this manual we will be using `Node.js`, `web3` (^0.20.6) and `truffle-contract` to operate with contracts.

Here is an example how to initialise contract interface:

```js
const contract = require('truffle-contract')
const Web3 = require('web3')

const wingsArtifact = require('./abi/Wings.json')

const Wings = contract.at(wingsArtifact)

Wings.setProvider(new Web3.providers.HttpProvider(web3Provider))
```

Prepare contracts instances as follows:

```js
const token = Token.at('0x667088b212ce3d06a1b553a7221E1fD19000d9aF') // mainnet wings Token contract address
// https://etherscan.io/token/0x667088b212ce3d06a1b553a7221E1fD19000d9aF

const userStorage = UserStorage.at('0x94B2F026A75BE2556C78A6D1f573bD79Fdfb1962') // mainnet wings User Storage contract address
// https://etherscan.io/address/0x94b2f026a75be2556c78a6d1f573bd79fdfb1962

const wings = Wings.at('0x7ea8dc2b2b00b596d077b68f5c891e03797a5eb2') // mainnet Wings contract address
// https://etherscan.io/address/0x7ea8dc2b2b00b596d077b68f5c891e03797a5eb2

const dao = DAO.at('0xd6635f49a306b015c55bd1ff878e2c2c8413f247') // this is an example, not the real address
// To get DAO address head to the project on wings.ai which you would like to forecast and get the address from the url:
// https://www.wings.ai/project/0xd6635f49a306b015c55bd1ff878e2c2c8413f247
// 0xd6635f49a306b015c55bd1ff878e2c2c8413f247 <-- is DAO address

const forecastingAddress = (await dao.forecasting.call()).toString()

const forecasting = Forecasting.at(forecastingAddress)
```

# Step by step

This step by step tutorial will walk through from the beggining, assyming you already have wings tokens, but didn't reserve any of them.
We will refer to forecaster address as `forecaster`.

#### 1. Approve wings amount to reserve

In order to reserve wings give User Storage permission to transfer wings.

```js
await token.approve(userStorage.address, amount, {
  from: forecaster
})
```

**Parameters:**
 - `amount` - amount of wings tokens to reserve


#### 2. Reserve wings

After the approval, you can reserve wings. Reserved wings will become locked wings after you'll make a forecast.

```js
await userStorage.reserveWings(
  amount,
  {
    from: forecaster
  }
)
```

#### 3. Add account address to DAO

When making new forecast the first step is to add your account address to DAO.

```js
const daoId = (await dao.id.call()).toString()

await wings.addForecasterToDAO(daoId, {
  from: forecaster
})
```

#### 4. Place forecast

After your account address was added to DAO you can place your forecast.

```js
await forecasting.addForecast(
  forecast,
  messageHash,
  {
    from: forecaster
  }
)
```

**Parameters:**
 - `forecast` - forecasted amount
 - `messageHash` - ipfs hash of message (message is a buffered string)

---

# Additional methods

#### Change forecast

When your forecast is already placed you can change/update it.

```js
await forecasting.changeForecast(
  forecast,
  messageHash,
  {
    from: forecaster
  }
)
```

**Parameters:**
 - `forecast` - forecasted amount
 - `messageHash` - ipfs hash of message (message is a buffered string)

#### Close/Cancel forecast

Depending on the stage of the forecasting you can either close or cancel forecast.

You can **close** forecast in following scenarios:
 - project was stopped by owner;
 - project was rejected by community;
 - crowdsale deadline missed;
 - after crowdsale period;

You can **cancel** forecast from the beginning of the forecasting and to the end of crowdsale period.

*NOTE: `closeForecast` is capable of performing both actions, hence it will automatically identify which one to perform depending on the current state of forecasting*

```js
await forecasting.closeForecast({ from: forecaster })
```
