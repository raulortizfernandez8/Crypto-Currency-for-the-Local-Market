// Licencia 
// SPDX-License-Identifier: GPL-3.0-or-later

// Version solidity

pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Contrato

contract COLOCOIN is ERC20, Ownable {
    uint256 public constant REWARD_PERCENT = 5; // The buyer will be rewarded with 5% of the total purchase

    uint256 public ExpirationDate;

    mapping(address => bool) public stores;

    constructor(uint256 _expirationDate) ERC20("Comercio Local Coin", "COLOCOIN") Ownable(msg.sender) {
        require(_expirationDate > block.timestamp, "The expiration date is not valid");
        ExpirationDate = _expirationDate;

        _mint(msg.sender, 1000 * 1e18); // Initial Mint 
    }

    // Funciones External

    function addStore(address _store) external onlyOwner {
        stores[_store] = true;
    }

    function removeStore(address _store) external onlyOwner {
        stores[_store] = false;
    }

    function buyInStore(address store, uint256 amount) external {
        require(!expired(), "COLOCOIN has expired");
        require(stores[store], "This store is not authorized");
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");

        uint256 reward = (amount * REWARD_PERCENT) / 100;

        _transfer(msg.sender, store, amount);
        _mint(msg.sender, reward);
    }

    /// Checks if it is expired
    function expired() public view returns (bool) {
        return block.timestamp >= ExpirationDate;
    }

    /// 🔥 Burns tokens after expiration
    function burnExpiredTokens(address account) external onlyOwner {
        require(expired(), "Not expired");
        uint256 balance = balanceOf(account);
        _burn(account, balance);
    }
}