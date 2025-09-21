# Custom ERC20 Tokens Dev
Custom ERC20 Tokens with Security Features ....in Development

### 
1- custom-origin-tokens

2- custom-bridge-destination-token

## I - Custom Origin Tokens Contract:

### 1. Security & Best Practices

✅ Reentrancy Protection: Uses nonReentrant on state-changing functions. <br>
✅ Timelock for Critical Changes: Trading status changes require a 24-hour delay. <br>
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

Scenario	liveTrading = true	liveTrading = false

User → User			 ✅ Allowed			❌ Blocked<br>
User → Admin		 ✅ Allowed			✅ Allowed<br>
Admin → User		 ✅ Allowed			✅ Allowed<br>
Public Sale → Any	 ✅ Allowed			✅ Allowed (if contract whitelisted)<br>
Pool → User (Buy)	 ✅ Allowed			✅ Allowed (if contract whitelisted)<br>
User → Pool (Sell)	 ✅ Allowed			❌ Blocked<br>


## Custom Bridge Destination Token Contract:

### 1. Security & Best Practices

✅ Reentrancy Protection: Uses nonReentrant on state-changing functions. <br>
✅ Role-Based Access: Only Bridge can perform privileged actions. <br>
✅ ECDSA Support: Uses ECDSA for bytes32. <br>
✅ Permit Support: Enables gasless approvals (EIP-2612). <br>

