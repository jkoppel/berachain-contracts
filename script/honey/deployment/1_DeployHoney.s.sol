// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import { console2 } from "forge-std/Script.sol";
import { HoneyDeployer } from "src/honey/HoneyDeployer.sol";
import { BaseScript } from "../../base/Base.s.sol";
import { HONEY_ADDRESS, HONEY_FACTORY_ADDRESS, HONEY_FACTORY_READER_ADDRESS } from "../HoneyAddresses.sol";
import { PYTH_PRICE_ORACLE_ADDRESS } from "../../oracles/OraclesAddresses.sol";
import { FEE_COLLECTOR_ADDRESS as POL_FEE_COLLECTOR_ADDRESS } from "../../pol/POLAddresses.sol";
import { HONEY_SALT, HONEY_FACTORY_SALT, HONEY_FACTORY_READER_SALT } from "../HoneySalts.sol";
import { Storage } from "../../base/Storage.sol";

contract DeployHoneyScript is BaseScript, Storage {
    // Placeholder. Change before deployment
    address internal constant FEE_RECEIVER = POL_FEE_COLLECTOR_ADDRESS;

    HoneyDeployer internal honeyDeployer;

    function run() public virtual broadcast {
        deployHoney();
    }

    function deployHoney() internal {
        console2.log("Deploying Honey and HoneyFactory...");
        _validateCode("POL FeeCollector", POL_FEE_COLLECTOR_ADDRESS);
        honeyDeployer = new HoneyDeployer(
            msg.sender,
            POL_FEE_COLLECTOR_ADDRESS,
            FEE_RECEIVER,
            HONEY_SALT,
            HONEY_FACTORY_SALT,
            HONEY_FACTORY_READER_SALT,
            PYTH_PRICE_ORACLE_ADDRESS
        );

        console2.log("HoneyDeployer deployed at:", address(honeyDeployer));

        honey = honeyDeployer.honey();
        _checkDeploymentAddress("Honey", address(honey), HONEY_ADDRESS);

        honeyFactory = honeyDeployer.honeyFactory();
        _checkDeploymentAddress("HoneyFactory", address(honeyFactory), HONEY_FACTORY_ADDRESS);

        honeyFactoryReader = honeyDeployer.honeyFactoryReader();
        _checkDeploymentAddress("HoneyFactoryReader", address(honeyFactoryReader), HONEY_FACTORY_READER_ADDRESS);

        require(honeyFactory.feeReceiver() == FEE_RECEIVER, "Fee receiver not set");
        console2.log("Fee receiver set to:", FEE_RECEIVER);

        require(honeyFactory.polFeeCollector() == POL_FEE_COLLECTOR_ADDRESS, "Pol fee collector not set");
        console2.log("Pol fee collector set to:", POL_FEE_COLLECTOR_ADDRESS);

        // check roles and grant manager role to msg.sender.
        require(
            honey.hasRole(honey.DEFAULT_ADMIN_ROLE(), msg.sender),
            "Honey's DEFAULT_ADMIN_ROLE not granted to msg.sender"
        );
        console2.log("Honey's DEFAULT_ADMIN_ROLE granted to:", msg.sender);

        require(
            honeyFactory.hasRole(honeyFactory.DEFAULT_ADMIN_ROLE(), msg.sender),
            "HoneyFactory's DEFAULT_ADMIN_ROLE not granted to msg.sender"
        );
        console2.log("HoneyFactory's DEFAULT_ADMIN_ROLE granted to:", msg.sender);

        // granting MANAGER_ROLE to msg.sender as we need to call
        // setMintRate and setRedeemRate while doing `addCollateral`
        honeyFactory.grantRole(honeyFactory.MANAGER_ROLE(), msg.sender);

        require(
            honeyFactory.hasRole(honeyFactory.MANAGER_ROLE(), msg.sender),
            "HoneyFactory's MANAGER_ROLE not granted to msg.sender"
        );
        console2.log("HoneyFactory's MANAGER_ROLE granted to:", msg.sender);

        // grant the PAUSER_ROLE to msg.sender
        honeyFactory.grantRole(honeyFactory.PAUSER_ROLE(), msg.sender);

        require(
            honeyFactory.hasRole(honeyFactory.PAUSER_ROLE(), msg.sender),
            "HoneyFactory's PAUSER_ROLE not granted to msg.sender"
        );
        console2.log("HoneyFactory's PAUSER_ROLE granted to:", msg.sender);
    }
}
