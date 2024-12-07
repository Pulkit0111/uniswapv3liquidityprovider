// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {RouterIntentEoaAdapterWithoutDataProvider} from "@routerprotocol/intents-core/contracts/RouterIntentEoaAdapter.sol";
import {Errors} from "@routerprotocol/intents-core/contracts/utils/Errors.sol";
import {IUniswapV3Mint} from "./Interfaces.sol"; // Create a custom interface for UniswapV3 functions.

contract UniswapV3LiquidityAdapter is RouterIntentEoaAdapterWithoutDataProvider {
    using SafeERC20 for IERC20;

    address public immutable nonFungiblePositionManager;

    constructor(
        address __native,
        address __wnative,
        address __nonFungiblePositionManager
    ) RouterIntentEoaAdapterWithoutDataProvider(__native, __wnative) {
        nonFungiblePositionManager = __nonFungiblePositionManager;
    }

    function name() public pure override returns (string memory) {
        return "UniswapV3LiquidityAdapter";
    }

    function execute(
        bytes calldata data
    ) external payable override returns (address[] memory tokens) {
        // Decode data to get liquidity parameters.
        IUniswapV3Mint.MintParams memory params = parseInputs(data);

        // If called via call (not delegatecall), transfer tokens to the adapter.
        if (address(this) == self()) {
            _transferTokensToContract(params);
        } else {
            _adjustAmounts(params);
        }

        // Approve tokens for the Uniswap V3 manager.
        _approveTokens(params);

        // Call the mint function on Uniswap V3.
        bytes memory logData;
        (tokens, logData) = _mintPosition(params);

        // Emit execution event.
        emit ExecutionEvent(name(), logData);
        return tokens;
    }

    function parseInputs(
        bytes memory data
    ) public pure returns (IUniswapV3Mint.MintParams memory) {
        return abi.decode(data, (IUniswapV3Mint.MintParams));
    }

    function _transferTokensToContract(IUniswapV3Mint.MintParams memory params)
        internal
    {
        if (params.token0 != native()) {
            IERC20(params.token0).safeTransferFrom(msg.sender, self(), params.amount0Desired);
        } else {
            require(msg.value == params.amount0Desired, Errors.INSUFFICIENT_NATIVE_FUNDS_PASSED);
        }

        if (params.token1 != native()) {
            IERC20(params.token1).safeTransferFrom(msg.sender, self(), params.amount1Desired);
        } else {
            require(msg.value == params.amount1Desired, Errors.INSUFFICIENT_NATIVE_FUNDS_PASSED);
        }
    }

    function _adjustAmounts(IUniswapV3Mint.MintParams memory params) internal view{
        if (params.amount0Desired == type(uint256).max) {
            params.amount0Desired = address(this).balance;
        }

        if (params.amount1Desired == type(uint256).max) {
            params.amount1Desired = address(this).balance;
        }
    }

    function _approveTokens(IUniswapV3Mint.MintParams memory params) internal {
        if (params.token0 != native()) {
            IERC20(params.token0).safeIncreaseAllowance(
                nonFungiblePositionManager,
                params.amount0Desired
            );
        }

        if (params.token1 != native()) {
            IERC20(params.token1).safeIncreaseAllowance(
                nonFungiblePositionManager,
                params.amount1Desired
            );
        }
    }

    function _mintPosition(IUniswapV3Mint.MintParams memory params)
        internal
        returns (address[] memory tokens, bytes memory logData)
    {
        (uint256 tokenId, , , ) = IUniswapV3Mint(nonFungiblePositionManager).mint(params);

        tokens = new address[](2);
        tokens[0] = params.token0;
        tokens[1] = params.token1;

        logData = abi.encode(params, tokenId);
    }

    receive() external payable {}
}