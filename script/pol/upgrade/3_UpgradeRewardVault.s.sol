// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import { console2 } from "forge-std/Script.sol";
import { UpgradeableBeacon } from "solady/src/utils/UpgradeableBeacon.sol";

import { BaseScript } from "../../base/Base.s.sol";
import { Create2Deployer } from "src/base/Create2Deployer.sol";
import { RewardVault } from "src/pol/rewards/RewardVault.sol";
import { RewardVaultFactory } from "src/pol/rewards/RewardVaultFactory.sol";
import { REWARD_VAULT_FACTORY_ADDRESS } from "../POLAddresses.sol";

contract UpgradeRewardVaultFactoryScript is BaseScript, Create2Deployer {
    function run() public broadcast {
        address newRewardVaultImpl = deployWithCreate2(0, type(RewardVault).creationCode);
        address beacon = RewardVaultFactory(REWARD_VAULT_FACTORY_ADDRESS).beacon();
        UpgradeableBeacon(beacon).upgradeTo(newRewardVaultImpl);
        console2.log("Beacon rewardVault implementation upgraded successfully");
        console2.log("New rewardVault implementation address:", newRewardVaultImpl);
    }
}
