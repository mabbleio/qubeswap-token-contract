# QubeSwapToken Bridge Destination Token Contract:
	*Bridge Destination Contract*

PegQubeSwapToken is the Bridge Destination Contract 
of QST on a New Chain.

QST is a multi-chain token



## 1. Security & Best Practices

✅ Reentrancy Protection: Uses nonReentrant on state-changing functions. <br>
✅ Role-Based Access: Only Bridge can perform privileged actions. <br>
✅ ECDSA Support: Uses ECDSA for bytes32. <br>
✅ Permit Support: Enables gasless approvals (EIP-2612). <br>
✅ Capped Supply: Prevents inflation beyond MAX_SUPPLY. <br>




## 2. Key Features

Mint/Burn Mechanism: The bridge will mint tokens on the destination chain when deposits occur on the source chain (and burn when withdrawing).<br>

Role-Based Access Control: Only the bridge contract (or a designated "minter" role) should be able to mint/burn. <br>

Initial Supply: The MAX_SUPPLY should be enforced, but minting should be allowed up to this cap. <br>

Security: Ensure no reentrancy or unauthorized minting. <br>

Compatibility: Align with common bridge patterns (e.g., LayerZero, Axelar, or custom bridge logic). <br>




## 3. Bridge Integration Notes

Deploy the Token:

Deploy PegQubeSwapToken on the destination chain.

Call grantBridgeRole(bridgeAddress) to authorize the bridge contract.




## 4. Bridge Contract Logic:

The bridge should call mint(to, amount) on deposits (source → destination).

The bridge should call burn(from, amount) on withdrawals (destination → source).




## 5. Security Considerations:

Only the bridge should have BRIDGE_ROLE (or MINTER_ROLE).

Use nonReentrant to prevent reentrancy in mint/burn.

Validate MAX_SUPPLY to prevent inflation.

