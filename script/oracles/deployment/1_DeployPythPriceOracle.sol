// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import { BaseScript } from "../../base/Base.s.sol";
import { PythPriceOracleDeployer } from "../logic/PythPriceOracleDeployer.sol";
import { PYTH_PRICE_ORACLE_ADDRESS } from "../OraclesAddresses.sol";
import { PYTH_PRICE_ORACLE_SALT } from "../OraclesSalts.sol";
import { PYTH_ORACLE } from "../../misc/Addresses.sol";

contract DeployPythPriceOracleScript is BaseScript, PythPriceOracleDeployer {
    function run() public broadcast {
        require(PYTH_ORACLE != address(0), "PythOracle address not set");
        address pythPriceOracle = deployPythOracle(msg.sender, PYTH_ORACLE, PYTH_PRICE_ORACLE_SALT);
        _checkDeploymentAddress("PythPriceOracle", pythPriceOracle, PYTH_PRICE_ORACLE_ADDRESS);
    }
}
