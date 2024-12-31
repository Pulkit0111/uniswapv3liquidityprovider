import { ethers } from "ethers";

interface MintParams {
    token0: string;
    token1: string;
    fee: number;
    tickLower: number;
    tickUpper: number;
    amount0Desired: string;
    amount1Desired: string;
    amount0Min: string;
    amount1Min: string;
    recipient: string;
    deadline: number;
}

async function prepareAddLiquidityData(params: MintParams) {
    // The adapter's address where it's deployed
    const adapterAddress = "0xFA6C0Cd59a326723bB4cd7dF536F1567F712722b";
    
    // Function selector for mint(address,address,uint24,int24,int24,uint256,uint256,uint256,uint256,address,uint256)
    const functionSelector = "0x88316456";
    
    // Encode the parameters for the adapter
    const abiCoder = ethers.utils.defaultAbiCoder;
    const encodedParams = abiCoder.encode(
        ["address", "address", "uint24", "int24", "int24", "uint256", "uint256", "uint256", "uint256", "address", "uint256"],
        [params.token0, params.token1, params.fee, params.tickLower, params.tickUpper,
         params.amount0Desired, params.amount1Desired, params.amount0Min, params.amount1Min,
         params.recipient, params.deadline]
    );

    // Combine function selector with encoded parameters
    const data = functionSelector + encodedParams.slice(2); // slice(2) removes the '0x' prefix

    return {
        to: adapterAddress,
        data: data,
        value: params.token0 === "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE" ? params.amount0Desired : 
              params.token1 === "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE" ? params.amount1Desired : "0"
    };
}

async function main() {
    const userAddress = "0x2B7eFcb732e6209Eb84BeED22AFE89F02D13634a";
    
    const params: MintParams = {
        token0: "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE", // ETH
        token1: "0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238", // USDC
        fee: 3000,
        tickLower: -887220,
        tickUpper: 887220,
        amount0Desired: ethers.utils.parseEther("1").toString(),
        amount1Desired: ethers.utils.parseUnits("1000000", 6).toString(),
        amount0Min: "0",
        amount1Min: "0",
        recipient: userAddress,
        deadline: Math.floor(Date.now() / 1000) + 3600
    };

    const txData = await prepareAddLiquidityData(params);
    return txData;
}

main()
    .then(console.log)
    .catch(console.error);
