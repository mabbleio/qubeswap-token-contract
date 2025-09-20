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

contract QubeSwapToken is ERC20Capped, ERC20Permit, ReentrancyGuard, AccessControl {
    using Address for address;
    using Address for address payable;
    using SafeERC20 for IERC20;

    // --- Roles ---
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant RECOVERER_ROLE = keccak256("RECOVERER_ROLE");

    // --- Constants ---
    string private constant _NAME = "QubeSwapToken";
    string private constant _SYMBOL = "QST";
    uint8 private constant _DECIMALS = 18;
    uint256 public constant MAX_SUPPLY = 100_000_000 * 10**_DECIMALS;

    // --- Events ---
    event TradingStatusUpdated(bool indexed liveTrading);
    event TradingStatusQueued(bool indexed newStatus, uint256 timestamp);
    event RecoverableTokenUpdated(address indexed token, bool allowed);
    event TokenRecovered(address indexed token, address indexed recipient, uint256 amount);
    event NativeTokenRecovered(address indexed recipient, uint256 amount);
    event Mint(address indexed to, uint256 amount);
    event AdminGranted(address indexed account);

    // --- Storage ---
    struct QueuedStatusChange {
        bool newStatus;
        uint256 timestamp;
    }

    uint256 public constant TIMELOCK_DURATION = 1 hours; // trading toggle delay: 24-hour
    QueuedStatusChange private _tradeableStatusChange;
    mapping(address => bool) private _recoverableTokens;
    bool public liveTrading = true; // Default: trading enabled

    // --- Constructor ---
    constructor() ERC20(_NAME, _SYMBOL) ERC20Permit(_NAME) ERC20Capped(MAX_SUPPLY) {
        _grantRole(ADMIN_ROLE, msg.sender);
        _grantRole(RECOVERER_ROLE, msg.sender);
        _useNonce(msg.sender); // Initialize nonce for permit
        uint256 amount;
        // Fixed Cap Supply Mint
        uint256 capMint = MAX_SUPPLY;
        require(totalSupply() + amount <= cap(), "Exceeds cap");
        _mint(msg.sender, capMint);
        emit Mint(msg.sender, capMint);  // Optional: Custom event for clarity
    }

    // Override _update to resolve the conflict (forward to ERC20Capped)
    function _update(
        address from,
        address to,
        uint256 value
    ) internal virtual override(ERC20, ERC20Capped) {
        super._update(from, to, value);
    }

    // --- Trading Control ---
    /// @dev Admin can queue a change to trading status (enabled/disabled).
    /// @param _status Desired status (true = enabled, false = disabled).
    function setTradeable(bool _status) external onlyRole(ADMIN_ROLE) nonReentrant {
        require(_tradeableStatusChange.timestamp == 0, "Change already queued");
        _tradeableStatusChange = QueuedStatusChange({
            newStatus: _status,
            timestamp: block.timestamp + TIMELOCK_DURATION
        });
        emit TradingStatusQueued(_status, _tradeableStatusChange.timestamp);
    }

    /// @dev Checks and applies queued trading status changes.
    function _checkTradeableStatus() internal {
        uint256 currentTime = block.timestamp;  // Cache
        if (_tradeableStatusChange.timestamp != 0 && currentTime >= _tradeableStatusChange.timestamp) {
            bool newStatus = _tradeableStatusChange.newStatus;
            if (liveTrading != newStatus) {
                liveTrading = newStatus;
                emit TradingStatusUpdated(newStatus);
            }
            _tradeableStatusChange.timestamp = 0;
        }
    }

    function getTradeableStatusChange() public view returns (bool, uint256) {
        return (_tradeableStatusChange.newStatus, _tradeableStatusChange.timestamp);
    }

    function cancelTradeableStatusChange() external onlyRole(ADMIN_ROLE) nonReentrant {
        require(_tradeableStatusChange.timestamp != 0, "No change queued");
        _tradeableStatusChange.timestamp = 0;
        emit TradingStatusQueued(false, 0);  // Emit cancellation
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
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Transfer failed");
        require(recipient != address(0), "Cannot recover to zero address");
        emit NativeTokenRecovered(recipient, amount);
    }

    // --- Overrides ---
    /// @dev Hook for ERC20 transfers. Enforces trading status.
    function _beforeTokenTransfer(
        address from,
        address to
    ) internal virtual {
        _checkTradeableStatus();  // Apply queued changes
        require(
            liveTrading ||
            from == address(0) ||  // Allow minting
            to == address(0) ||    // Allow burning
            hasRole(ADMIN_ROLE, from) ||  // Allow admin sends
            hasRole(ADMIN_ROLE, to),       // Allow admin receives
            "Trading disabled"
        );
    }

    // Grant admin role (restricted to owner)
    function grantAdmin(address account) external onlyRole(ADMIN_ROLE) nonReentrant {
        _grantRole(ADMIN_ROLE, account);
        emit AdminGranted(account);
    }

    /// @dev Supports EIP-165 interface detection.
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return
            interfaceId == type(IERC165).interfaceId ||  // ERC-165
            interfaceId == type(IERC20).interfaceId ||   // ERC-20
            interfaceId == type(IERC20Metadata).interfaceId ||  // ERC-20 Metadata
            interfaceId == type(IERC20Permit).interfaceId ||  // ERC-20 Permit
            super.supportsInterface(interfaceId);  // AccessControl (ERC-165)
    }   
}