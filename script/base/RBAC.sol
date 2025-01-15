// SPDX-License-Identifier: MIT
pragma solidity >=0.8.10;

import { console2 } from "forge-std/Script.sol";
import { IAccessControl } from "@openzeppelin/contracts/access/IAccessControl.sol";

abstract contract RBAC {
    struct RoleDescription {
        string contractName;
        address contractAddr;
        string name;
        bytes32 role;
    }

    struct AccountDescription {
        string name;
        address addr;
    }

    /// @notice Grant a given role to an account
    function _grantRole(RoleDescription memory role, AccountDescription memory account) internal {
        IAccessControl target = IAccessControl(role.contractAddr);

        if (target.hasRole(role.role, account.addr)) {
            console2.log("INFO: %s already has %s role on %s", account.name, role.name, role.contractName);
            return;
        }

        // TBD: check that the msg.sender has the admin role
        // TBD: log the account address

        console2.log("INFO: Granting %s role on %s to %s", role.name, role.contractName, account.name);
        target.grantRole(role.role, account.addr);
        require(
            target.hasRole(role.role, account.addr),
            string.concat("ERROR: Failed to grant ", role.name, " role on ", role.contractName, " to ", account.name)
        );
        console2.log("NOTICE: Granted %s role on %s to %s", role.name, role.contractName, account.name);
    }

    /// @notice Revoke a given role from an account
    function _revokeRole(RoleDescription memory role, AccountDescription memory account) internal {
        IAccessControl target = IAccessControl(role.contractAddr);

        if (!target.hasRole(role.role, account.addr)) {
            console2.log("INFO: %s already miss %s role on %s", account.name, role.name, role.contractName);
            return;
        }

        // TBD: check that the msg.sender has the admin role
        // TBD: log the account address

        console2.log("INFO: Revoking %s role on %s from %s", role.name, role.contractName, account.name);
        target.revokeRole(role.role, account.addr);
        require(
            !target.hasRole(role.role, account.addr),
            string.concat(
                "ERROR: Failed to revoke ", role.name, " role on ", role.contractName, " from ", account.name
            )
        );
        console2.log("NOTICE: Revoked %s role on %s from %s", role.name, role.contractName, account.name);
    }
}
