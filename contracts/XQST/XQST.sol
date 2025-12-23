// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Wrapper.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract XQST is ERC20, ERC20Burnable, ERC20Wrapper {
    using SafeERC20 for IERC20;

    event Deposit(address indexed src, uint256 amount); // ✅ src = depositor
    event Withdrawal(address indexed dst, uint256 amount); // ✅ dst = withdrawer

    uint8 private constant _DECIMALS = 18;

    constructor(IERC20 addressQST)
        ERC20("Wrapped QST", "XQST")
        ERC20Wrapper(addressQST)
    {
        require(address(addressQST) != address(0), "Invalid underlying token");
    }

    function decimals() public view virtual override(ERC20, ERC20Wrapper) returns (uint8) {
        return _DECIMALS;
    }

    /// @notice Deposit underlying token (QST) to mint XQST.
    /// @dev Reverts if transfer fails (e.g., insufficient allowance).
    /// @param amount The amount of underlying tokens to deposit.
    function deposit(uint256 amount) external {
        require(amount > 0, "Amount must be > 0");
        IERC20 underlying = IERC20(underlying()); // ✅ Cached
        underlying.safeTransferFrom(msg.sender, address(this), amount);
        _mint(msg.sender, amount);
        emit Deposit(msg.sender, amount);
    }

    /// @notice Withdraw underlying token (QST) by burning XQST.
    /// @dev Reverts if transfer fails (e.g., insufficient balance).
    /// @param amount The amount of xQST to burn.
    function withdraw(uint256 amount) external {
        require(amount > 0, "Amount must be > 0");
        _burn(msg.sender, amount);
        IERC20 underlying = IERC20(underlying()); // ✅ Cached
        underlying.safeTransfer(msg.sender, amount);
        emit Withdrawal(msg.sender, amount);
    }
}