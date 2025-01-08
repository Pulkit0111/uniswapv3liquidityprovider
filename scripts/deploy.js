const { ethers, network } = require("hardhat");

async function main() {
    // Add these debug lines
    console.log("Network:", network.name);
    console.log("Network ID:", (await ethers.provider.getNetwork()).chainId);
    
    const UniswapV3LiquidityProvisioning = await ethers.getContractFactory("UniswapV3LiquidityProvisioning");

    // Replace these addresses with the actual ones for Sepolia or the desired network
    const nativeTokenAddress = "0x0000000000000000000000000000000000000000"; // Represents native ETH
    const wrappedNativeTokenAddress = "0xfff9976782d46cc05630d1f6ebab18b2324d6b14";
    const nonFungiblePositionManagerAddress = "0x1238536071E1c677A632429e3655c799b22cDA52";

    const adapter = await UniswapV3LiquidityProvisioning.deploy(
        nativeTokenAddress,
        wrappedNativeTokenAddress,
        nonFungiblePositionManagerAddress
    );

    await adapter.waitForDeployment();
    console.log("UniswapV3LiquidityProvisioning deployed to:", adapter.target);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});

// UniswapV3LiquidityProvisioning deployed to: 0x4F5b3902e5450898e8633e9ccBB70762Bc0dc9b5