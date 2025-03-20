// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import { console2 } from "forge-std/Script.sol";
import { BaseScript } from "../../base/Base.s.sol";
import { Create2Deployer } from "src/base/Create2Deployer.sol";
import { RewardVaultFactory } from "src/pol/rewards/RewardVaultFactory.sol";

import { REWARD_VAULT_FACTORY_ADDRESS, BGT_INCENTIVE_DISTRIBUTOR_ADDRESS } from "../POLAddresses.sol";

contract UpgradeRewardVaultFactoryScript is BaseScript, Create2Deployer {
    function run() public broadcast {
        address newRewardVaultFactoryImpl = deployWithCreate2(0, type(RewardVaultFactory).creationCode);
        RewardVaultFactory(REWARD_VAULT_FACTORY_ADDRESS).upgradeToAndCall(
            newRewardVaultFactoryImpl,
            abi.encodeCall(RewardVaultFactory.setBGTIncentiveDistributor, (BGT_INCENTIVE_DISTRIBUTOR_ADDRESS))
        );
        require(
            RewardVaultFactory(REWARD_VAULT_FACTORY_ADDRESS).bgtIncentiveDistributor()
                == BGT_INCENTIVE_DISTRIBUTOR_ADDRESS,
            "BGT incentive distributor not set"
        );
        console2.log("RewardVaultFactory upgraded successfully");
        console2.log("New RewardVaultFactory implementation address:", newRewardVaultFactoryImpl);
    }
}
