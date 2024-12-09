require("@nomiclabs/hardhat-ethers");
require("dotenv").config();

module.exports = {
    solidity: "0.8.28",
    networks: {
        sepolia: {
            url: process.env.SPOLIA_RPC,
            accounts: [process.env.PRIVATE_KEY],
        },
    },
};