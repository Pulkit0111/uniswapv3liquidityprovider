const { ethers } = require("hardhat");

async function main() {
    const UniswapV3LiquidityAdapter = await ethers.getContractFactory("UniswapV3LiquidityAdapter");

    // Replace these addresses with the actual ones for Sepolia or the desired network
    const nativeTokenAddress = "0x0000000000000000000000000000000000000000"; // Represents native ETH
    const wrappedNativeTokenAddress = "0xfff9976782d46cc05630d1f6ebab18b2324d6b14";
    const nonFungiblePositionManagerAddress = "0x1238536071E1c677A632429e3655c799b22cDA52";

    const adapter = await UniswapV3LiquidityAdapter.deploy(
        nativeTokenAddress,
        wrappedNativeTokenAddress,
        nonFungiblePositionManagerAddress
    );

    await adapter.deployed();
    console.log("UniswapV3LiquidityAdapter deployed to:", adapter.address);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});