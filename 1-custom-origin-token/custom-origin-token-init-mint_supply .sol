// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract CappedERC20WithPermit is ERC20Capped, ERC20Permit, ReentrancyGuard, AccessControl {
    using Address for address;
    using Address for address payable;
    using SafeERC20 for IERC20;

    // --- Roles ---
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant RECOVERER_ROLE = keccak256("RECOVERER_ROLE");

    // --- Constants ---
    string private constant _NAME = "MyToken";
    string private constant _SYMBOL = "MTK";
    uint8 private constant _DECIMALS = 18;
    uint256 public constant MAX_SUPPLY = 100_000_000 * 10**_DECIMALS;
    uint256 private constant TIMELOCK_DURATION = 24 hours; // 24-hour delay for trading toggle

    // --- Events ---
    event TradingStatusUpdated(bool indexed liveTrading);
    event TradingStatusQueued(bool indexed newStatus, uint256 timestamp);
    event RecoverableTokenUpdated(address indexed token, bool allowed);
    event TokenRecovered(address indexed token, address indexed recipient, uint256 amount);
    event NativeTokenRecovered(address indexed recipient, uint256 amount);

    // --- Storage ---
    struct QueuedStatusChange {
        bool newStatus;
        uint256 timestamp;
    }

    QueuedStatusChange private _tradeableStatusChange;
    mapping(address => bool) private _recoverableTokens;
    bool public liveTrading = true; // Default: trading enabled

    // --- Constructor ---
    constructor() ERC20(_NAME, _SYMBOL) ERC20Permit(_NAME) ERC20Capped(MAX_SUPPLY) {
        _grantRole(ADMIN_ROLE, msg.sender);
        _grantRole(RECOVERER_ROLE, msg.sender);
        _useNonce(msg.sender); // Initialize nonce for permit (instead of _nonces[msg.sender] = 1)

        // Initial mint (e.g., 1M tokens to deployer)
        uint256 initialMint = 1_000_000 * 10**_DECIMALS;
        require(initialMint <= MAX_SUPPLY, "Initial mint exceeds cap");
        _mint(msg.sender, initialMint);
    }

    // Override _update to resolve the conflict (forward to ERC20Capped)
    function _update(
        address from,
        address to,
        uint256 value
    ) internal virtual override(ERC20, ERC20Capped) {
        super._update(from, to, value);
    }

    function safeMint(address to, uint256 amount) external onlyRole(ADMIN_ROLE) nonReentrant {
        _mint(to, amount);
    }

    // --- Trading Control ---
    /// @dev Admin can queue a change to trading status (enabled/disabled).
    /// @param newStatus Desired status (true = enabled, false = disabled).
    function setTradeable(bool newStatus) external onlyRole(ADMIN_ROLE) nonReentrant {
        require(_tradeableStatusChange.timestamp == 0, "Change already queued");
        _tradeableStatusChange = QueuedStatusChange({
            newStatus: newStatus,
            timestamp: block.timestamp + TIMELOCK_DURATION
        });
        emit TradingStatusQueued(newStatus, _tradeableStatusChange.timestamp);
    }

    /// @dev Checks and applies queued trading status changes.
    function _checkTradeableStatus() private {
        if (_tradeableStatusChange.timestamp != 0 && block.timestamp >= _tradeableStatusChange.timestamp) {
            liveTrading = _tradeableStatusChange.newStatus;
            emit TradingStatusUpdated(_tradeableStatusChange.newStatus);
            delete _tradeableStatusChange; // Resets to {newStatus: false, timestamp: 0}
        }
    }

    // --- Token Recovery ---
    /// @dev Admin/Recoverer can whitelist tokens for recovery.
    function setRecoverableToken(address token, bool allowed) external onlyRole(ADMIN_ROLE) {
        _recoverableTokens[token] = allowed;
        emit RecoverableTokenUpdated(token, allowed);
    }

    /// @dev Recoverer can rescue stuck ERC20 tokens.
    function recoverToken(
        address token,
        address recipient,
        uint256 amount
    ) external onlyRole(RECOVERER_ROLE) nonReentrant {
        require(_recoverableTokens[token], "Token not recoverable");
        IERC20(token).safeTransfer(recipient, amount); // Safe transfer with revert on failure
        emit TokenRecovered(token, recipient, amount);
    }

    /// @dev Recoverer can rescue stuck native tokens (e.g., ETH).
    function recoverNativeToken(address payable recipient, uint256 amount) external onlyRole(RECOVERER_ROLE) nonReentrant {
        recipient.sendValue(amount);
        emit NativeTokenRecovered(recipient, amount);
    }

    // --- Overrides ---
    /// @dev Hook for ERC20 transfers. Enforces trading status.
    function _beforeTokenTransfer(
        address from,
        address to
        //uint256 amount
    ) internal {
        _checkTradeableStatus(); // Keep your custom logic
        require(liveTrading || from == address(0) || to == address(0), "Trading disabled");
    }

    /// @dev Supports EIP-165 interface detection.
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return
            //ERC20.supportsInterface(interfaceId) ||
            //ERC20Permit.supportsInterface(interfaceId) ||
            AccessControl.supportsInterface(interfaceId);
    }
}