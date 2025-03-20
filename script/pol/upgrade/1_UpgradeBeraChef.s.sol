// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import { console2 } from "forge-std/Script.sol";
import { BaseScript } from "../../base/Base.s.sol";
import { Create2Deployer } from "src/base/Create2Deployer.sol";
import { BeraChef } from "src/pol/rewards/BeraChef.sol";

import { BERACHEF_ADDRESS } from "../POLAddresses.sol";

contract UpgradeBeraChefScript is BaseScript, Create2Deployer {
    // Equal to MAX_COMMISSION_CHANGE_DELAY
    uint64 constant COMMISSION_CHANGE_DELAY = 2 * 8191;

    function run() public broadcast {
        address newBeraChefImpl = deployWithCreate2(0, type(BeraChef).creationCode);
        BeraChef(BERACHEF_ADDRESS).upgradeToAndCall(
            newBeraChefImpl, abi.encodeCall(BeraChef.setCommissionChangeDelay, (COMMISSION_CHANGE_DELAY))
        );
        require(
            BeraChef(BERACHEF_ADDRESS).commissionChangeDelay() == COMMISSION_CHANGE_DELAY,
            "Commission change delay not set"
        );
        console2.log("BeraChef upgraded successfully");
        console2.log("New BeraChef implementation address:", newBeraChefImpl);
    }
}
