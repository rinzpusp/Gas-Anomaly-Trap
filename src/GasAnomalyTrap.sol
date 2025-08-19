// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "drosera-contracts/interfaces/ITrap.sol";

contract GasAnomalyTrap is ITrap {
    
    struct GasData {
        uint256 totalGasUsed;
        uint256 transactionCount;
        uint256 lastGasPrice;
        uint256 averageGasPrice;
    }
    
    mapping(address => GasData) private walletGasData;
    uint256 private constant GAS_MULTIPLIER_THRESHOLD = 3;
    uint256 private constant MIN_TRANSACTIONS = 5;
    
    constructor() {}
    
    function collect() external view returns (bytes memory) {
        GasData memory data = walletGasData[tx.origin];
        
        return abi.encode(
            tx.origin,
            tx.gasprice,
            data.averageGasPrice,
            data.transactionCount,
            block.timestamp
        );
    }
    
    function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory) {
        if (data.length == 0) {
            return (false, abi.encode("No data provided"));
        }
        
        (
            address walletAddr,
            uint256 currentGasPrice,
            uint256 avgGasPrice,
            uint256 txCount,
            uint256 timestamp
        ) = abi.decode(data[0], (address, uint256, uint256, uint256, uint256));
        
        if (txCount < MIN_TRANSACTIONS) {
            return (false, abi.encode("Insufficient transaction history"));
        }
        
        if (avgGasPrice == 0) {
            return (false, abi.encode("No average gas price data"));
        }
        
        bool isAnomalous = currentGasPrice > (avgGasPrice * GAS_MULTIPLIER_THRESHOLD);
        
        if (isAnomalous) {
            bytes memory responseData = abi.encode(
                walletAddr,
                currentGasPrice,
                avgGasPrice,
                (currentGasPrice * 100) / avgGasPrice,
                timestamp,
                "ALERT: Gas price anomaly detected - possible wallet compromise"
            );
            
            return (true, responseData);
        }
        
        return (false, abi.encode("Gas usage within normal range"));
    }
}