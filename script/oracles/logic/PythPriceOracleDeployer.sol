// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import { PythPriceOracle } from "src/extras/PythPriceOracle.sol";
import { Create2Deployer } from "src/base/Create2Deployer.sol";

abstract contract PythPriceOracleDeployer is Create2Deployer {
    /// @notice Deploy PythPriceOracle contract
    function deployPythOracle(address owner, address pythOracle, uint256 pythSalt) internal returns (address) {
        address pythImpl = deployWithCreate2(0, type(PythPriceOracle).creationCode);
        PythPriceOracle pythPriceOracle = PythPriceOracle(deployProxyWithCreate2(pythImpl, pythSalt));

        pythPriceOracle.initialize(owner, pythOracle);

        require(
            pythPriceOracle.hasRole(pythPriceOracle.DEFAULT_ADMIN_ROLE(), owner),
            "PythPriceOracle manager role not set correctly"
        );
        require(address(pythPriceOracle.pyth()) == pythOracle, "Pyth oracle address not set correctly");

        return address(pythPriceOracle);
    }
}
