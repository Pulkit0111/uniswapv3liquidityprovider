// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {RouterIntentEoaAdapterWithoutDataProvider} from "@routerprotocol/intents-core/contracts/RouterIntentEoaAdapter.sol";
import {Errors} from "@routerprotocol/intents-core/contracts/utils/Errors.sol";
import {IUniswapV3NonFungiblePositionManager} from "./Interfaces.sol";
import {UniswapV3Helpers} from "./UniswapV3Helpers.sol";

/// @title UniswapV3LiquidityProvisioning
/// @author Pulkit Tyagi
/// @notice Adapter for minting new positions on Uniswap V3
contract UniswapV3LiquidityProvisioning is 
    RouterIntentEoaAdapterWithoutDataProvider,
    UniswapV3Helpers 
{
    using SafeERC20 for IERC20;

    // Add events for important state changes
    event PositionMinted(
        address indexed token0,
        address indexed token1,
        uint256 tokenId,
        uint256 amount0,
        uint256 amount1
    );

    constructor(
        address __native,
        address __wnative,
        address __nonFungiblePositionManager
    ) 
        RouterIntentEoaAdapterWithoutDataProvider(__native, __wnative)
        UniswapV3Helpers(__nonFungiblePositionManager)
    {}

    function name() public pure override returns (string memory) {
        return "UniswapV3LiquidityProvisioning";
    }

    function execute(
        bytes calldata data
    ) external payable override returns (address[] memory tokens) {
        // Decode data to get liquidity parameters.
        IUniswapV3NonFungiblePositionManager.MintParams memory params = parseInputs(data);

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
    ) public pure returns (IUniswapV3NonFungiblePositionManager.MintParams memory) {
        return abi.decode(data, (IUniswapV3NonFungiblePositionManager.MintParams));
    }

    function _transferTokensToContract(IUniswapV3NonFungiblePositionManager.MintParams memory params)
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

    function _adjustAmounts(IUniswapV3NonFungiblePositionManager.MintParams memory params) internal view {
        if (params.amount0Desired == type(uint256).max) {
            params.amount0Desired = address(this).balance;
        }

        if (params.amount1Desired == type(uint256).max) {
            params.amount1Desired = address(this).balance;
        }
    }

    function _approveTokens(IUniswapV3NonFungiblePositionManager.MintParams memory params) internal {
        if (params.token0 != address(0)) {
            // ERC-20 approval for token0
            IERC20(params.token0).safeIncreaseAllowance(
                address(nonFungiblePositionManager),
                params.amount0Desired
            );
        }

        if (params.token1 != address(0)) {
            // ERC-20 approval for token1
            IERC20(params.token1).safeIncreaseAllowance(
                address(nonFungiblePositionManager),
                params.amount1Desired
            );
        }
    }

    function _mintPosition(IUniswapV3NonFungiblePositionManager.MintParams memory params)
        internal
        returns (address[] memory tokens, bytes memory logData)
    {
        (uint256 tokenId, , uint256 amount0, uint256 amount1) = 
            IUniswapV3NonFungiblePositionManager(nonFungiblePositionManager).mint(params);

        tokens = new address[](2);
        tokens[0] = params.token0;
        tokens[1] = params.token1;

        logData = abi.encode(params, tokenId);

        emit PositionMinted(
            params.token0,
            params.token1,
            tokenId,
            amount0,
            amount1
        );
    }

    receive() external payable {}
}