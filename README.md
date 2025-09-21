# QubeSwap Token

Official QubeSwap Token [QST]

## Official QST Contract Addresses


### Origin-Contract
Qubetics Network:
0x------

### Destination-Contracts on
BSC Network:
0x------

### 1. Security & Best Practices

✅ Standard ERC20 (transfer, approve, etc.). <br>
✅ Recovery mechanisms for stuck ETH/ERC20. <br>
✅ Reentrancy Protection: Uses nonReentrant on state-changing functions. <br>
✅ Timelock for Critical Changes: Transfer/Trading status changes require <br>
a 24-hour delay with automatic execution after delay elapses. <br>
✅ Role-Based Access: Only admins/recoverers can perform privileged actions. <br>
✅ Safe Transfers: Uses safeTransfer for ERC-20 recovery. <br>
✅ Permit Support: Enables gasless approvals (EIP-2612). <br>
✅ Capped Supply: Prevents inflation beyond MAX_SUPPLY. <br>



### 2. Why This Design?


Compliance: Capped supply + admin controls for regulatory friendliness. <br>

Safety: Timelocks and pauses reduce admin risk (e.g., accidental disable). <br>

Flexibility: Recovery system for user errors (e.g., sending tokens to the contract). <br>

Efficiency: Optimized for gas without sacrificing security. <br>



### 3: LiveTrading feature before/after official launch
#### 3.1: Behavior Summary

Scenario	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;liveTrading = true	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;liveTrading = false

User → User			 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;✅ Allowed			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;❌ Blocked<br>
User → Admin		 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;✅ Allowed			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;✅ Allowed<br>
Admin → User		 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;✅ Allowed			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;✅ Allowed<br>
Public Sale → Any	 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;✅ Allowed			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;✅ Allowed (if contract whitelisted)<br>
Pool → User (Buy)	 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;✅ Allowed			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;✅ Allowed (if contract whitelisted)<br>
User → Pool (Sell)	 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;✅ Allowed			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;❌ Blocked<br>