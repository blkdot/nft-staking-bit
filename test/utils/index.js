const { BigNumber } = require("ethers")

const BASE_TEN = 10

function getBigNumber(amount, decimals = 18) {
    return BigNumber.from(amount).mul(BigNumber.from(BASE_TEN).pow(decimals))
}

module.exports = {
    BASE_TEN,
    getBigNumber,
}