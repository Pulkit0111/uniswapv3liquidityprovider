const hre = require("hardhat");

async function main() {
    // The address where your contract is deployed
    const TOKEN_ADDRESS = "0xE59f49C92043160Aa18525eA3C9Ac70bFd035608"; // Replace with your deployed address
    
    // Get the contract instance
    const TestToken = await hre.ethers.getContractAt("TestToken", TOKEN_ADDRESS);
    
    // Amount to mint (for example, 100 tokens with 18 decimals)
    const amount = hre.ethers.parseUnits("100", 18); // This will mint 100 tokens
    
    // Address to mint to
    const toAddress = "0x2B7eFcb732e6209Eb84BeED22AFE89F02D13634a"; // Replace with the address you want to mint to
    
    // Mint tokens
    const mintTx = await TestToken.mint(toAddress, amount);
    await mintTx.wait();
    
    console.log(`Minted ${amount} tokens to ${toAddress}`);
    
    // If you want to check the balance
    const balance = await TestToken.balanceOf(toAddress);
    console.log(`New balance: ${hre.ethers.formatUnits(balance, 18)} tokens`);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
