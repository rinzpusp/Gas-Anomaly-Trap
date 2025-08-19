# Gas Anomaly Trap

A Solidity smart contract trap designed to detect unusual gas price patterns that may indicate wallet compromise or suspicious activity.

## Overview

The `GasAnomalyTrap` contract implements the `ITrap` interface from the Drosera framework to monitor and detect gas price anomalies in wallet transactions. It tracks historical gas usage patterns and triggers alerts when current gas prices significantly exceed the wallet's average gas price usage.

## Use Cases

### 1. **Wallet Compromise Detection**
- **Scenario**: A malicious actor gains access to a wallet and performs transactions
- **Detection**: Attackers often use different gas price strategies than the original owner
- **Benefit**: Early detection of unauthorized access before significant damage occurs

### 2. **Bot Activity Identification**
- **Scenario**: Automated bots or scripts interacting with a wallet
- **Detection**: Bots typically use consistent, often higher gas prices for faster execution
- **Benefit**: Identify automated trading or arbitrage activities that may indicate account takeover

### 3. **Phishing Attack Prevention**
- **Scenario**: Users tricked into signing malicious transactions
- **Detection**: Phishing sites often use default high gas prices different from user's normal pattern
- **Benefit**: Alert users before they execute potentially malicious transactions

### 4. **MEV (Maximal Extractable Value) Protection**
- **Scenario**: Protection against sandwich attacks or front-running
- **Detection**: Unusual gas price spikes that may indicate MEV bot activity targeting the wallet
- **Benefit**: Early warning system for potential value extraction attempts

### 5. **Smart Contract Interaction Monitoring**
- **Scenario**: Monitoring interactions with new or potentially malicious contracts
- **Detection**: Different gas usage patterns when interacting with unfamiliar contracts
- **Benefit**: Additional security layer for DeFi protocol interactions

### 6. **Flash Loan Attack Detection**
- **Scenario**: Sophisticated attacks using flash loans for arbitrage or exploitation
- **Detection**: Flash loan transactions often require specific gas price strategies
- **Benefit**: Rapid identification of complex attack vectors

### 7. **Account Recovery Assistance**
- **Scenario**: Legitimate user regains access to compromised account
- **Detection**: Sudden change in gas price patterns may indicate account recovery
- **Benefit**: Helps distinguish between attacker activity and legitimate recovery efforts

### 8. **Compliance and Audit Trail**
- **Scenario**: Maintaining records for regulatory compliance or internal auditing
- **Detection**: Track all gas price anomalies for compliance reporting
- **Benefit**: Comprehensive audit trail of suspicious activities

### 9. **DeFi Protocol Security**
- **Scenario**: Protecting DeFi protocols from governance attacks or exploitation
- **Detection**: Unusual gas price patterns in governance voting or large transactions
- **Benefit**: Enhanced security for protocol governance and large value transfers

### 10. **Multi-Signature Wallet Monitoring**
- **Scenario**: Monitoring multi-sig wallets for unauthorized transaction attempts
- **Detection**: Different signers may have different gas price preferences
- **Benefit**: Detect when unauthorized parties attempt to initiate transactions

## How It Works

1. **Data Collection**: The `collect()` function gathers current transaction data including gas price and historical averages
2. **Pattern Analysis**: The contract maintains a history of gas usage patterns for each wallet
3. **Anomaly Detection**: Compares current gas price against historical average using a configurable threshold (3x multiplier)
4. **Alert Generation**: Triggers alerts when gas prices exceed normal patterns by the defined threshold

## Configuration

- **Gas Multiplier Threshold**: 3x (configurable)
- **Minimum Transactions**: 5 transactions required for pattern establishment
- **Data Tracked**: Total gas used, transaction count, last gas price, average gas price

## Integration

This trap can be integrated into:
- Wallet applications for real-time monitoring
- DeFi protocols for additional security layers
- Security monitoring systems
- Compliance and auditing tools
- Multi-signature wallet implementations

## Benefits

- **Proactive Security**: Detects threats before significant damage
- **Low False Positives**: Uses historical patterns to reduce noise
- **Customizable Thresholds**: Adaptable to different use cases
- **Gas Efficient**: Minimal overhead for monitoring operations
- **Real-time Detection**: Immediate alerts for suspicious activity

## License

MIT License