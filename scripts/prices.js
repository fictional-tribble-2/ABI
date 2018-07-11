const BigNumber = require('bignumber.js')

/*
  PriceBonus {
    price: number
    durationDays: string
    durationHours: string
    durationMinutes: string
    duration: any
    isEdit: boolean
    errorText: string,
    durationErrorText: string
  }
*/

// PriceBonus[]
const prices = [{
  price: '50',
  durationDays: '5',
  durationHours: '0',
  durationMinutes: '0',
  duration: '',
  isEdit: false,
  errorText: '',
  durationErrorText: ''
},
{
  price: '50',
  durationDays: '5',
  durationHours: '0',
  durationMinutes: '0',
  duration: '',
  isEdit: false,
  errorText: '',
  durationErrorText: ''
},
{
  price: '50',
  durationDays: '5',
  durationHours: '0',
  durationMinutes: '0',
  duration: '',
  isEdit: false,
  errorText: '',
  durationErrorText: ''
}]

// Amount of integer tokens per ETH
const tokenPrice = 100

const convertPrices = async (prices, tokenPrice) => {
  let result

  const priceChanges = [] // PriceChange[]
  for(const price of prices) {
    const value = new BigNumber(new BigNumber(price.price).mul(tokenPrice).div(100).plus(tokenPrice).toFixed(0))
    priceChanges.push({
      price: value,
      duration: bonusDurationToSeconds(price)
    })
  }

  const lastPrice = { // PriceChange
    price: new BigNumber(tokenPrice),
    duration: 1
  }

  priceChanges.push(lastPrice)

  result = await packPrices(priceChanges)
  return result
}

const bonusDurationToSeconds = (priceBonus) => {
  return parseInt(priceBonus.durationDays) * 86400 + parseInt(priceBonus.durationHours) * 3600 + parseInt(priceBonus.durationMinutes) * 60
}

/*
  Pack prices
*/
const packPrices = async (changes) => {
  const len = changes.length

  if (len > 8) {
    throw new Error('Price changes cant contain more then 8 items')
  }

  const results = [new BigNumber(0), new BigNumber(0)]
  let i

  if (len > 0) {
    for (i = 3; i >= 0; --i) {
      if (i >= len) continue
      results[0] = results[0].shift(14).add(packSingle(changes[i]))
    }
  }

  if (len > 4) {
    for (i = 7; i >= 4; --i) {
      if (i >= len) continue
      results[1] = results[1].shift(14).add(packSingle(changes[i]))
    }
  }

  return results
}

/*
  Pack price changes
*/
const packSingle = (change) => {
  const PACK_MAX = 10000000

  if (change.price.lessThanOrEqualTo(0) || change.price.greaterThanOrEqualTo(PACK_MAX)) {
    throw new Error(`Price out of range: ${change.price.toString(10)}`)
  }

  if (change.duration <= 0 || change.duration >= PACK_MAX) {
    throw new Error(`Duration out of range: ${change.duration}`)
  }

  return new BigNumber(change.duration).shift(7).add(change.price)
}

convertPrices(prices, tokenPrice).then((result) => {
  console.log(`Prices1to4: ${result[0].toString(10)}. Prices5to8: ${result[1].toString(10)}`)
})
