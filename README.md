# Custom ERC20 Tokens Dev
Custom ERC20 Tokens with Security Features ...


##
1- Custom-Origin-Tokens <br>
	*Option A:* A CapFixed Supply Token Contract<br>
	*Option B:* An InitialMint Supply Token Contract<br>

2- Custom-Bridge-Destination-token <br>
	*Bridge Destination Contract*



## I - Custom Origin Tokens Contract:

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



## II - Custom Bridge Destination Token Contract:

### 1. Security & Best Practices

✅ Reentrancy Protection: Uses nonReentrant on state-changing functions. <br>
✅ Role-Based Access: Only Bridge can perform privileged actions. <br>
✅ ECDSA Support: Uses ECDSA for bytes32. <br>
✅ Permit Support: Enables gasless approvals (EIP-2612). <br>
✅ Capped Supply: Prevents inflation beyond MAX_SUPPLY. <br>

