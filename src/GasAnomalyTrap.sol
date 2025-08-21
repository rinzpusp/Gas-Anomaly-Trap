// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "drosera-contracts/interfaces/ITrap.sol";

contract GasAnomalyTrap is ITrap {
    uint256 private constant GAS_MULTIPLIER_THRESHOLD = 3;

    constructor() {}

    function collect() external view returns (bytes memory) {
        return abi.encode(
            tx.origin,
            tx.gasprice,
            block.timestamp
        );
    }

    function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory) {
        if (data.length < 5) {
            return (false, abi.encode("Not enough samples"));
        }

        address wallet;
        uint256 currentGas;
        uint256 totalGas = 0;

        for (uint256 i = 0; i < data.length; i++) {
            (address w, uint256 g, ) = abi.decode(data[i], (address, uint256, uint256));
            if (i == 0) {
                wallet = w;
                currentGas = g;
            } else {
                totalGas += g;
            }
        }

        uint256 avgGas = totalGas / (data.length - 1);

        if (avgGas == 0) {
            return (false, abi.encode("Average gas is zero"));
        }

        if (currentGas > avgGas * GAS_MULTIPLIER_THRESHOLD) {
            return (
                true,
                abi.encode(
                    wallet,
                    currentGas,
                    avgGas,
                    (currentGas * 100) / avgGas,
                    block.timestamp,
                    "ALERT: Gas anomaly detected"
                )
            );
        }

        return (false, abi.encode("Gas usage within normal range"));
    }
}