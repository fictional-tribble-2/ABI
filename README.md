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

const Wings = contract(wingsArtifact)

Wings.setProvider(new Web3.providers.HttpProvider(web3Provider))

const wingsAddress = '0x7ea8dc2b2b00b596d077b68f5c891e03797a5eb2' // mainnet Wings contract address

const wings = Wings.at(wingsAddress)
```

# Step by step

### 1. Create DAO

First step in project creation process is creating a DAO. DAO is a main contract in your project hierarchy.

#### approve

First of all you have to have enough wings on your account for wings deposit (we will refer to your account as `creator` in this step by step tutorial).

When you have enough wings on your account balance, call method `approve` on wings `Token` contract to give the `Wings` contract ability to transfer deposit.

```js
const wingsTokenAddress = '0x667088b212ce3d06a1b553a7221E1fD19000d9aF' // mainnet wings Token contract address
// https://etherscan.io/token/0x667088b212ce3d06a1b553a7221E1fD19000d9aF

const wingsToken = Token.at(wingsTokenAddress)

await wingsToken.approve(wingsAddress, wingsDeposit, { from: creator })
```

**Parameters:**
 - `wingsAddress` - address of `Wings` contract (can be found above)
 - `wingsDeposit` - amount of wings to be locked in order to create project. Currently is 5000 Wings.

#### createDAO

After successful approval, call the method `createDAO` on `Wings` contract instance.

```js
await wings.createDAO(name, tokenName, tokenSymbol, infoHash, customCrowdsale, { from: creator })
```

**Parameters:**
 - `name` - string - name of your project
 - `tokenName` - string - name of project token
 - `tokenSymbol` - string - symbol of project token
 - `infoHash` - bytes32 - decoded ipfs hash of project description
 - `customCrowdsale` - address - address of custom crowdsale (`"0"` in case of standard crowdsale)

#### Uploading your project description and media to ipfs

Head to [Media file format](https://github.com/WingsDao/ABI#media-file-format) paragraph in the Appendix section.

---

**Warning:** Ipfs file can contain malicious code which means that everyone developing and using this data must sanitize it.

---

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

await dao.createModel({ from: creator })
```

### 4. Create Forecasting

*Required stage: model created*

When rewards model is created you can create a forecasting.

```js
await dao.createForecasting(forecastingDurationInHours, ethRewardPart, tokenRewardPart, { from: creator })
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
await dao.startForecasting(bucketMin, bucketMax, bucketStep, { from: creator })
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
await dao.closeForecasting({ from: creator })
```

## Note that after forecasting end you will have 45 days to start your crowdsale.

## In case you are using Custom Crowdsale, skip step 7 and head to the step 8.1.

### 7. Create token

*Required stage: forecasting closed*

When forecasting is closed you can create your project token. It will have the `tokenName` and a `tokenSymbol` which you used during DAO creation process.

```js
await dao.createToken(decimals, { from: creator })
```

**Parameters:**
 - `decimals` - uint8 - project token decimals

### 8. Create Crowdsale

*Required stage: token created*

When token is created you can create crowdsale.

```js
await dao.createCrowdsale(minimalGoal, hardCap, prices1to4, prices5to8, { from: creator })
```

**Parameters:**
 - `minimalGoal` - uint256 - soft cap of crowdsale (in Wei)
 - `hardCap` - uint256 - hard cap of crowdsale (in Wei)
 - `prices1to4` - uint256 -
 - `prices5to8` - uint256 -

### 8.1. Create Custom Crowdsale

*Required stage: forecasting closed*

When forecasting is closed you need to call method `createCustomCrowdsale`.  
This and following steps are required in order to finalise forecasting and reward wings community.

```js
await dao.createCustomCrowdsale({ from: creator })
```

*NOTE: During this step the manager of the Crowdsale will be transferred to a newly created Crowdsale Controller.*

### 9. Get address of Crowdsale Controller

In order to start crowdsale you'll need to find the address of Crowdsale Controller, which is the contract created during the previous step.

```js
const ccAddress = (await dao.crowdsaleController.call()).toString()
```

### 10. Start Crowdsale

When you have Crowdsale Controller address, initiate a contract instance and call the method `start`.

```js
const cc = CC.at(ccAddress)

await cc.start(startTimestamp, endTimestamp, fundingAddress, { from: creator })
```

**Parameters:**
 - `startTimestamp` - uint256 - unix timestamp of the start of crowdsale period
 - `endTimestamp` - uint256 - unix timestamp of the end of crowdsale period
 - `fundingAddress` - address - address of account, which will receive funds, collected during crowdsale period

## Additional functions

### update

This DAO method allows you to change project description during forecasting period.

```js
await dao.update(infoHash, { from: creator })
```

**Parameters:**
 - `infoHash` - bytes32 - decoded ipfs hash of updated project description

### stop

This DAO method stops the DAO in any state.

```js
await dao.stop({ from: creator })
```

In case of the stop the `wingsDeposit` will be returned only if forecasting hasn't started.

## Appendix

### Media file format

File that contains project media has to be in JSON format.

**Example:**
```json
{
  "version": "1.0.0",
  "shortBlurb": "My short project description",
  "story": "{\"ops\": [{\"insert\":\"test\"},{\"insert\":{\"video\":\"https://www.youtube.com/embed/CXo7i_gdNR0?showinfo=0\"}}]}",
  "category": 1,
  "gallery": [
    {
      "type": "logo",
      "content": {
        "contentType": "image/png",
        "hash": "QmWWQSuPMS6aXCbZKpEjPHPUZN2NjB3YrhJTHsV4X3vb2t"
      }
    },
    {
      "type": "video",
      "content": {
        "videoId": "CXo7i_gdNR0",
        "videoType": "youtube"
      }
    },
    {
      "type": "image",
      "content": {
        "contentType": "image/jpeg",
        "hash": "0x38134191b4b59736d5174cdd0846bb8bafdf01fbfe013ead08ca133f13e23e59"
      }
    },
    {
      "type": "terms",
      "content": {
        "hash": "QmWWQSuPMS6aXCbZKpEjPHPUZN2NjB3YrhJTHsV4X3vb2t"
      }
    }
  ]
}
```

**Schema:**
```js
{
  "$id": "http://example.com/example.json",
  "type": "object",
  "definitions": {},
  "$schema": "http://json-schema.org/draft-07/schema#",
  "properties": {
    "version": {
      "$id": "/properties/version",
      "type": "string"
    },
    "shortBlurb": {
      "$id": "/properties/shortBlurb",
      "type": "string"
    },
    "story": {
      "$id": "/properties/story",
      "type": "string"
    },
    "category": {
      "$id": "/properties/category",
      "type": "integer"
    },
    "gallery": {
      "$id": "/properties/gallery",
      "type": "array",
      "items": {
        "$id": "/properties/gallery/items",
        "type": "object",
        "properties": {
          "type": {
            "$id": "/properties/gallery/items/properties/type",
            "type": "string"
          },
          // "type:" "logo"
          "content": {
            "$id": "/properties/gallery/items/properties/content",
            "type": "object",
            "properties": {
              "contentType": {
                "$id": "/properties/gallery/items/properties/content/properties/contentType",
                "type": "string"
              },
              "hash": {
                "$id": "/properties/gallery/items/properties/content/properties/hash",
                "type": "string"
              }
            }
          }
          // "type:" "video"
          "content": {
            "$id": "/properties/gallery/items/properties/content",
            "type": "object",
            "properties": {
              "videoId": {
                "$id": "/properties/gallery/items/properties/content/properties/videoId",
                "type": "string"
              },
              "videoType": {
                "$id": "/properties/gallery/items/properties/content/properties/videoType",
                "type": "string"
              }
            }
          }
          // "type:" "image"
          "content": {
            "$id": "/properties/gallery/items/properties/content",
            "type": "object",
            "properties": {
              "contentType": {
                "$id": "/properties/gallery/items/properties/content/properties/contentType",
                "type": "string"
              },
              "hash": {
                "$id": "/properties/gallery/items/properties/content/properties/hash",
                "type": "string"
              }
            }
          }
          // "type:" "terms"
          "content": {
            "$id": "/properties/gallery/items/properties/content",
            "type": "object",
            "properties": {
              "hash": {
                "$id": "/properties/gallery/items/properties/content/properties/hash",
                "type": "string"
              }
            }
          }
        }
      }
    }
  }
}
```

To better understand parameters let's prepare full list:

- *version* - version of media file (means version of media file schema).
- *shortBlurb* - short description of project, string. Maximum 140 characters.
- *story* - description of project in [Delta](https://github.com/quilljs/delta) format (see the example below).
- *category* - id of category (see Categories below).
- *gallery* - gallery description of project.
- _gallery/*/contentType_ - type of content. Options: video, image, logo, terms.
- *gallery/video/content/videoId* -  id of video from video hosting.
- *gallery/video/content/videoType* - type of video hosting. Options: youtube, vimeo, youku.
- *gallery/image/content/hash* - ipfs hash of image uploaded to ipfs.
- *gallery/logo/content/contentType* - type of image format. Options: `image/png`, `image/jpg`.
- *gallery/logo/content/hash* - ipfs hash of logo uploaded to ipfs. Only jpg/png allowed; size < 1 mb.
- *gallery/terms/content/hash* - ipfs hash of terms uploaded to ipfs. Only pdf allowed; size < 1 mb.

#### How to use Delta module to generate story:

```js
const Delta = require('quill-delta')

const delta = new Delta([
  { insert: 'test' },
  { insert: { video: 'https://www.youtube.com/embed/fy2XDBbDrAs?showinfo=0' } }
])

console.log(JSON.stringify(JSON.stringify(delta)))
// "{\"ops\":[{\"insert\":\"test\"},{\"insert\":{\"video\":\"https://www.youtube.com/embed/fy2XDBbDrAs?showinfo=0\"}}]}"
```

#### Categories:

To get up-to-date list of categories use our [public API](https://apidocs.wings.ai/#/categories/get_dictionary_categories).
