require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

module.exports = {
    solidity: "0.8.24",
    defaultNetwork: "sepolia",
    networks: {
        sepolia: {
            url: process.env.SEPOLIA_RPC,
            accounts: [process.env.PRIVATE_KEY],
        },
    },
    etherscan: {
        apiKey: process.env.ETHERSCAN_API_KEY
    }
};