// Since pool is VAL/WETH, price = 1/1000
const price = 1/1000
const sqrtPrice = Math.sqrt(price)
const sqrtPriceX96 = sqrtPrice * (2n ** 96n)

console.log(sqrtPriceX96)