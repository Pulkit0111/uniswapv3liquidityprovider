const { ethers, network } = require("hardhat");

async function main() {
    // Add these debug lines
    console.log("Network:", network.name);
    console.log("Network ID:", (await ethers.provider.getNetwork()).chainId);
    
    // Get the contract factory
    const TestToken = await ethers.getContractFactory("TestToken");

    // Deploy the contract with name "Validator" and symbol "VAL"
    const testToken = await TestToken.deploy("Validator", "VAL");
    await testToken.waitForDeployment();

    console.log("TestToken deployed to:", await testToken.getAddress());
}

// Execute deployment
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
