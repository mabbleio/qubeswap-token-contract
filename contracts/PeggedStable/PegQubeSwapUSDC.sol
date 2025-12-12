// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract PegQubeSwapUSDC is ERC20, ERC20Permit, AccessControl, ReentrancyGuard {
    using ECDSA for bytes32;

    address private _admin;

    // --- Custom Errors ---
    error PegQubeSwapUSDC__NotMinter();
    error PegQubeSwapUSDC__ZeroAddress();
    error PegQubeSwapUSDC__InsufficientBalance(uint256 balance, uint256 amount);

    // --- Roles ---
    bytes32 public constant BRIDGE_ROLE = keccak256("BRIDGE_ROLE");

    // --- Constants ---
    string private constant _NAME = "QubeSwapUSDC";
    string private constant _SYMBOL = "USDC";
    uint8 private immutable _DECIMALS = 6;

    // --- Events ---
    event Mint(address indexed to, uint256 amount);
    event Burn(address indexed from, uint256 amount);
    event BridgeRoleGranted(address indexed account);
    event BridgeRoleRevoked(address indexed account);

    // --- Constructor ---
    constructor() ERC20(_NAME, _SYMBOL) ERC20Permit(_NAME) {
        _admin = msg.sender; // Set deployer as admin
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(BRIDGE_ROLE, msg.sender); // Initially grant to deployer; bridge will be set later
    }

    // --- Bridge Functions ---
    /**
     * @dev Mints tokens to a recipient (called by the bridge).
     * @param to Recipient address.
     * @param amount Amount to mint.
     */
    function mint(address to, uint256 amount) external nonReentrant {
        if (!hasRole(BRIDGE_ROLE, msg.sender)) {
            revert PegQubeSwapUSDC__NotMinter();
        }
        if (to == address(0)) revert PegQubeSwapUSDC__ZeroAddress();
        _mint(to, amount);
        emit Mint(to, amount);
    }

    /**
     * @dev Burns tokens from a sender (called by the bridge).
     * @param from Address to burn from.
     * @param amount Amount to burn.
     */
    function burn(address from, uint256 amount) external nonReentrant {
        if (!hasRole(BRIDGE_ROLE, msg.sender)) {
            revert PegQubeSwapUSDC__NotMinter();
        }
        if (from == address(0)) revert PegQubeSwapUSDC__ZeroAddress();
        if (balanceOf(from) < amount) {
            revert PegQubeSwapUSDC__InsufficientBalance(balanceOf(from), amount);
        }
        _burn(from, amount);
        emit Burn(from, amount);
    }

    /**
     * @notice Returns the decimals of the token.
     */
    function decimals() public view virtual override returns (uint8) {
        return _DECIMALS;
    }

    // --- Bridge Role Management ---
    function grantBridgeRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(BRIDGE_ROLE, account);
        emit BridgeRoleGranted(account);
    }

    function revokeBridgeRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _revokeRole(BRIDGE_ROLE, account);
        emit BridgeRoleRevoked(account);
    }

    // --- Overrides for Safety ---
    function transfer(
        address to,
        uint256 amount
    ) public override returns (bool) {
        return super.transfer(to, amount);
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override returns (bool) {
        return super.transferFrom(from, to, amount);
    }

    /**
     * @notice Returns the owner address. Required by BEP20.
     */
    function getOwner() external view returns (address) {
        return _admin;
    }
}