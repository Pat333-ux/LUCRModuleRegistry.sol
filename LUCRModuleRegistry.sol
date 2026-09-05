// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract LUCRModuleRegistry {
    address public governance;

    enum ModuleType {
        MintEngine,
        BurnEngine,
        SalesEngine,
        PricingEngine,
        LedgerBridge,
        EventGateway,
        ComplianceLayer,
        WalletRouter,
        TokenCore,
        AccessController,
        TreasurySettlement,
        SecuritySeal,
        DeterministicOracle,
        StateChannel,
        StabilityEngine,
        GovernanceSwitch,
        SyncRelay,
        Custom
    }

    struct ModuleInfo {
        ModuleType moduleType;
        address moduleAddress;
        uint256 registeredBlock;
    }

    mapping(bytes32 => ModuleInfo) public modules;

    event ModuleRegistered(
        bytes32 indexed key,
        ModuleType moduleType,
        address moduleAddress,
        uint256 blockNum
    );

    event ModuleUpdated(
        bytes32 indexed key,
        ModuleType moduleType,
        address oldAddress,
        address newAddress,
        uint256 blockNum
    );

    modifier onlyGovernance() {
        require(msg.sender == governance, "Not governance");
        _;
    }

    constructor() {
        governance = msg.sender;
    }

    function registerModule(
        bytes32 key,
        ModuleType moduleType,
        address moduleAddress
    ) external onlyGovernance {
        require(moduleAddress != address(0), "Invalid address");
        require(modules[key].moduleAddress == address(0), "Already registered");

        modules[key] = ModuleInfo({
            moduleType: moduleType,
            moduleAddress: moduleAddress,
            registeredBlock: block.number
        });

        emit ModuleRegistered(key, moduleType, moduleAddress, block.number);
    }

    function updateModule(
        bytes32 key,
        address newAddress
    ) external onlyGovernance {
        require(newAddress != address(0), "Invalid address");
        require(modules[key].moduleAddress != address(0), "Not registered");

        address old = modules[key].moduleAddress;
        modules[key].moduleAddress = newAddress;

        emit ModuleUpdated(
            key,
            modules[key].moduleType,
            old,
            newAddress,
            block.number
        );
    }

    function getModule(bytes32 key) external view returns (ModuleInfo memory) {
        return modules[key];
    }
}
