// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {IUniswapV3NonFungiblePositionManager} from "./Interfaces.sol";

contract UniswapV3Helpers {
    IUniswapV3NonFungiblePositionManager public immutable nonFungiblePositionManager;

    constructor(address __nonFungiblePositionManager) {
        nonFungiblePositionManager = IUniswapV3NonFungiblePositionManager(
            __nonFungiblePositionManager
        );
    }
}
