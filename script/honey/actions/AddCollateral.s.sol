// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import { console2 } from "forge-std/Script.sol";
import { BaseScript } from "../../base/Base.s.sol";
import { HoneyFactory } from "src/honey/HoneyFactory.sol";
import { ERC4626 } from "solady/src/tokens/ERC4626.sol";
import { IERC20 } from "forge-std/interfaces/IERC20.sol";
import { USDT_ADDRESS, DAI_ADDRESS, USDC_ADDRESS } from "../../misc/Addresses.sol";
import { HONEY_FACTORY_ADDRESS } from "../HoneyAddresses.sol";
import { IPriceOracle } from "src/extras/IPriceOracle.sol";

/// @notice Creates a collateral vault for the given token.
contract AddCollateralVaultScript is BaseScript {
    // Placeholders. Change before run script.
    string constant COLLATERAL_NAME = "COLLATERAL_NAME"; // "USDT" "DAI" "USDC"
    address constant COLLATERAL_ADDRESS = address(0); // USDT_ADDRESS DAI_ADDRESS USDC_ADDRESS

    function run() public virtual broadcast {
        require(COLLATERAL_ADDRESS != address(0), "COLLATERAL_ADDRESS not set");

        _validateCode("HoneyFactory", HONEY_FACTORY_ADDRESS);
        _validateCode("COLLATERAL_NAME", COLLATERAL_ADDRESS);
        addCollateralVault(COLLATERAL_ADDRESS);
    }

    /// @dev requires MANAGER_ROLE to be granted to msg.sender
    function addCollateralVault(address collateral) internal {
        _validateCode("Collateral", collateral);
        HoneyFactory honeyFactory = HoneyFactory(HONEY_FACTORY_ADDRESS);

        console2.log("Adding collateral %s", IERC20(collateral).symbol());

        // NOTE: the price oracle must have freshly pushed data, otherwise
        // the honey factory will consider the asset as depegged.
        IPriceOracle priceOracle = IPriceOracle(honeyFactory.priceOracle());
        IPriceOracle.Data memory data = priceOracle.getPriceUnsafe(collateral);
        require(data.publishTime >= block.timestamp - honeyFactory.priceFeedMaxDelay(), "Price data too old");

        ERC4626 vault = honeyFactory.createVault(collateral);
        console2.log("Collateral Vault deployed at:", address(vault));
    }
}
