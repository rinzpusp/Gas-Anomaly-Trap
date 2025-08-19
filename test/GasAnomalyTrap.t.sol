// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {GasAnomalyTrap} from "../src/GasAnomalyTrap.sol";

contract GasAnomalyTrapTest is Test {
    GasAnomalyTrap public trap;
    
    address public user1 = makeAddr("user1");
    address public user2 = makeAddr("user2");
    
    function setUp() public {
        trap = new GasAnomalyTrap();
    }
    
    function test_Constructor() public view {
        assertTrue(address(trap) != address(0));
    }
    
    function test_Collect_NewWallet() public {
        vm.txGasPrice(20 gwei);
        
        vm.prank(user1, user1);
        
        bytes memory data = trap.collect();
        
        (
            address walletAddr,
            uint256 currentGasPrice,
            uint256 avgGasPrice,
            uint256 txCount,
            uint256 timestamp
        ) = abi.decode(data, (address, uint256, uint256, uint256, uint256));
        
        assertEq(walletAddr, user1);
        assertEq(currentGasPrice, 20 gwei);
        assertEq(avgGasPrice, 0);
        assertEq(txCount, 0);
        assertEq(timestamp, block.timestamp);
    }
    
    function test_ShouldRespond_NoData() public view {
        bytes[] memory emptyData = new bytes[](0);
        
        (bool shouldRespond, bytes memory response) = trap.shouldRespond(emptyData);
        
        assertFalse(shouldRespond);
        assertEq(abi.decode(response, (string)), "No data provided");
    }
    
    function test_ShouldRespond_InsufficientTransactions() public view {
        bytes memory collectData = abi.encode(
            user1,
            20 gwei,
            15 gwei,
            uint256(3),
            block.timestamp
        );
        
        bytes[] memory data = new bytes[](1);
        data[0] = collectData;
        
        (bool shouldRespond, bytes memory response) = trap.shouldRespond(data);
        
        assertFalse(shouldRespond);
        assertEq(abi.decode(response, (string)), "Insufficient transaction history");
    }
    
    function test_ShouldRespond_NoAverageGasPrice() public view {
        bytes memory collectData = abi.encode(
            user1,
            20 gwei,
            uint256(0),
            uint256(10),
            block.timestamp
        );
        
        bytes[] memory data = new bytes[](1);
        data[0] = collectData;
        
        (bool shouldRespond, bytes memory response) = trap.shouldRespond(data);
        
        assertFalse(shouldRespond);
        assertEq(abi.decode(response, (string)), "No average gas price data");
    }
    
    function test_ShouldRespond_NormalGasUsage() public view {
        bytes memory collectData = abi.encode(
            user1,
            20 gwei,
            15 gwei,
            uint256(10),
            block.timestamp
        );
        
        bytes[] memory data = new bytes[](1);
        data[0] = collectData;
        
        (bool shouldRespond, bytes memory response) = trap.shouldRespond(data);
        
        assertFalse(shouldRespond);
        assertEq(abi.decode(response, (string)), "Gas usage within normal range");
    }
    
    function test_ShouldRespond_GasAnomalyDetected() public view {
        uint256 avgGasPrice = 10 gwei;
        uint256 anomalousGasPrice = 35 gwei;
        
        bytes memory collectData = abi.encode(
            user1,
            anomalousGasPrice,
            avgGasPrice,
            uint256(10),
            block.timestamp
        );
        
        bytes[] memory data = new bytes[](1);
        data[0] = collectData;
        
        (bool shouldRespond, bytes memory response) = trap.shouldRespond(data);
        
        assertTrue(shouldRespond);
        
        (
            address walletAddr,
            uint256 currentGasPrice,
            uint256 avgGas,
            uint256 percentage,
            uint256 timestamp,
            string memory alertMessage
        ) = abi.decode(response, (address, uint256, uint256, uint256, uint256, string));
        
        assertEq(walletAddr, user1);
        assertEq(currentGasPrice, anomalousGasPrice);
        assertEq(avgGas, avgGasPrice);
        assertEq(percentage, (anomalousGasPrice * 100) / avgGasPrice);
        assertEq(timestamp, block.timestamp);
        assertEq(alertMessage, "ALERT: Gas price anomaly detected - possible wallet compromise");
    }
    
    function test_ShouldRespond_EdgeCase_ExactlyThreshold() public view {
        uint256 avgGasPrice = 10 gwei;
        uint256 thresholdGasPrice = 30 gwei;
        
        bytes memory collectData = abi.encode(
            user1,
            thresholdGasPrice,
            avgGasPrice,
            uint256(10),
            block.timestamp
        );
        
        bytes[] memory data = new bytes[](1);
        data[0] = collectData;
        
        (bool shouldRespond,) = trap.shouldRespond(data);
        
        assertFalse(shouldRespond);
    }
    
    function test_ShouldRespond_EdgeCase_JustAboveThreshold() public view {
        uint256 avgGasPrice = 10 gwei;
        uint256 slightlyAboveThreshold = 30 gwei + 1;
        
        bytes memory collectData = abi.encode(
            user1,
            slightlyAboveThreshold,
            avgGasPrice,
            uint256(10),
            block.timestamp
        );
        
        bytes[] memory data = new bytes[](1);
        data[0] = collectData;
        
        (bool shouldRespond,) = trap.shouldRespond(data);
        
        assertTrue(shouldRespond);
    }
    
    function testFuzz_ShouldRespond_VariousGasPrices(
        uint256 currentGas,
        uint256 avgGas,
        uint256 txCount
    ) public view {
        currentGas = bound(currentGas, 1 gwei, 1000 gwei);
        avgGas = bound(avgGas, 1 gwei, 100 gwei);
        txCount = bound(txCount, 5, 1000);
        
        bytes memory collectData = abi.encode(
            user1,
            currentGas,
            avgGas,
            txCount,
            block.timestamp
        );
        
        bytes[] memory data = new bytes[](1);
        data[0] = collectData;
        
        (bool shouldRespond,) = trap.shouldRespond(data);
        
        bool expectedResponse = currentGas > (avgGas * 3);
        assertEq(shouldRespond, expectedResponse);
    }
    
    function test_MultipleWallets() public {
        vm.txGasPrice(25 gwei);
        vm.prank(user1, user1);
        bytes memory data1 = trap.collect();
        
        vm.txGasPrice(50 gwei);
        vm.prank(user2, user2);
        bytes memory data2 = trap.collect();
        
        (address addr1,,,,) = abi.decode(data1, (address, uint256, uint256, uint256, uint256));
        (address addr2,,,,) = abi.decode(data2, (address, uint256, uint256, uint256, uint256));
        
        assertEq(addr1, user1);
        assertEq(addr2, user2);
        assertTrue(addr1 != addr2);
    }
}