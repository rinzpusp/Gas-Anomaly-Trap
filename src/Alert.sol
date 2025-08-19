// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Alert {
    
    struct AlertData {
        address walletAddress;
        uint256 suspiciousGasPrice;
        uint256 normalGasPrice;
        uint256 increasePercentage;
        uint256 alertTimestamp;
        string alertMessage;
        bool isActive;
    }
    
    mapping(address => AlertData) public alerts;
    address[] public alertedWallets;
    
    event GasAnomalyDetected(
        address indexed wallet,
        uint256 gasPrice,
        uint256 avgGasPrice,
        uint256 increasePercentage,
        uint256 timestamp
    );
    
    constructor() {}
    
    function receiveAlert(bytes memory responseData) external {
        (
            address walletAddr,
            uint256 currentGasPrice,
            uint256 avgGasPrice,
            uint256 percentage,
            uint256 timestamp,
            string memory message
        ) = abi.decode(responseData, (address, uint256, uint256, uint256, uint256, string));
        
        alerts[walletAddr] = AlertData({
            walletAddress: walletAddr,
            suspiciousGasPrice: currentGasPrice,
            normalGasPrice: avgGasPrice,
            increasePercentage: percentage,
            alertTimestamp: timestamp,
            alertMessage: message,
            isActive: true
        });
        
        bool exists = false;
        for (uint i = 0; i < alertedWallets.length; i++) {
            if (alertedWallets[i] == walletAddr) {
                exists = true;
                break;
            }
        }
        
        if (!exists) {
            alertedWallets.push(walletAddr);
        }
        
        emit GasAnomalyDetected(
            walletAddr,
            currentGasPrice,
            avgGasPrice,
            percentage,
            timestamp
        );
    }
    
    function getAlert(address wallet) external view returns (AlertData memory) {
        return alerts[wallet];
    }
    
    function getAllAlertedWallets() external view returns (address[] memory) {
        return alertedWallets;
    }
    
    function clearAlert(address wallet) external {
        require(alerts[wallet].isActive, "No active alert for this wallet");
        alerts[wallet].isActive = false;
    }
}