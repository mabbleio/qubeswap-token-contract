# Custom ERC20 Tokens Dev
Custom ERC20 Tokens with Security Features ....in Development

### 
1- custom-origin-tokens

2- custom-bridge-destination-token

## I - Custom Origin Tokens Contract:

### 1. Security & Best Practices

✅ Reentrancy Protection: Uses nonReentrant on state-changing functions.
✅ Timelock for Critical Changes: Trading status changes require a 24-hour delay.
✅ Role-Based Access: Only admins/recoverers can perform privileged actions.
✅ Safe Transfers: Uses safeTransfer for ERC-20 recovery.
✅ Permit Support: Enables gasless approvals (EIP-2612).
✅ Capped Supply: Prevents inflation beyond MAX_SUPPLY.



### 2. Why This Design?


Compliance: Capped supply + admin controls for regulatory friendliness.

Safety: Timelocks and pauses reduce admin risk (e.g., accidental disable).

Flexibility: Recovery system for user errors (e.g., sending tokens to the contract).

Efficiency: Optimized for gas without sacrificing security.



### 3: LiveTrading feature before/after official launch
#### 3.1: Behavior Summary

Scenario	liveTrading = true	liveTrading = false

User → User			 ✅ Allowed			❌ Blocked
User → Admin		 ✅ Allowed			✅ Allowed
Admin → User		 ✅ Allowed			✅ Allowed
Public Sale → Any	 ✅ Allowed			✅ Allowed (if contract whitelisted)
Pool → User (Buy)	 ✅ Allowed			✅ Allowed (if contract whitelisted)
User → Pool (Sell)	 ✅ Allowed			❌ Blocked


## Custom Bridge Destination Token Contract:

### 1. Security & Best Practices

✅ Reentrancy Protection: Uses nonReentrant on state-changing functions.
✅ Role-Based Access: Only Bridge can perform privileged actions.
✅ ECDSA Support: Uses ECDSA for bytes32.
✅ Permit Support: Enables gasless approvals (EIP-2612).

