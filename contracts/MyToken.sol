// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "openzeppelin-contracts/contracts/utils/Pausable.sol";
import "openzeppelin-contracts/contracts/access/AccessControl.sol";

contract MyToken is ERC20Permit, Pausable, AccessControl {
    uint256 public immutable maxSupply;

    bytes32 public constant MINTER_ROLE   = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE   = keccak256("BURNER_ROLE");
    bytes32 public constant PAUSER_ROLE   = keccak256("PAUSER_ROLE");

    mapping(address => bool) public blacklist;
    mapping(address => bool) public whitelist;

    address[] private allWhitelisted;
    address[] private allBlacklisted;

    event Mint(address indexed to, uint256 amount);
    event Burn(address indexed from, uint256 amount);
    event Blacklisted(address indexed account);
    event Whitelisted(address indexed account);
    event RemovedFromBlacklist(address indexed account);
    event RemovedFromWhitelist(address indexed account);

    constructor(uint256 initialSupply, uint256 _maxSupply)
        ERC20("MyToken", "MTK")
        ERC20Permit("MyToken")
    {
        maxSupply = _maxSupply * 10 ** decimals();
        _mint(msg.sender, initialSupply * 10 ** decimals());

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(BURNER_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);

        // L’admin est whitelisted par défaut
        whitelist[msg.sender] = true;
        allWhitelisted.push(msg.sender);
    }

    // --- Fonctions principales ---
    function mint(address to, uint256 amount) external onlyRole(MINTER_ROLE) {
        require(totalSupply() + amount <= maxSupply, "Max supply exceeded");
        require(!blacklist[to], "Recipient blacklisted");
        require(whitelist[to], "Recipient not whitelisted");
        _mint(to, amount);
        emit Mint(to, amount);
    }

    function burn(uint256 amount) external onlyRole(BURNER_ROLE) {
        _burn(msg.sender, amount);
        emit Burn(msg.sender, amount);
    }

    function pause() external onlyRole(PAUSER_ROLE) { _pause(); }
    function unpause() external onlyRole(PAUSER_ROLE) { _unpause(); }

    // --- Gestion blacklist ---
    function addToBlacklist(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (!blacklist[account]) {
            blacklist[account] = true;
            allBlacklisted.push(account);
            emit Blacklisted(account);
        }
    }

    function removeFromBlacklist(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (blacklist[account]) {
            blacklist[account] = false;
            emit RemovedFromBlacklist(account);
        }
    }

    function addManyToBlacklist(address[] calldata accounts) external onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 len = accounts.length;
        for (uint256 i = 0; i < len; i++) {
            if (!blacklist[accounts[i]]) {
                blacklist[accounts[i]] = true;
                allBlacklisted.push(accounts[i]);
                emit Blacklisted(accounts[i]);
            }
        }
    }

    function removeManyFromBlacklist(address[] calldata accounts) external onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 len = accounts.length;
        for (uint256 i = 0; i < len; i++) {
            if (blacklist[accounts[i]]) {
                blacklist[accounts[i]] = false;
                emit RemovedFromBlacklist(accounts[i]);
            }
        }
    }

    // --- Gestion whitelist ---
    function addToWhitelist(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (!whitelist[account]) {
            whitelist[account] = true;
            allWhitelisted.push(account);
            emit Whitelisted(account);
        }
    }

    function removeFromWhitelist(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (whitelist[account]) {
            whitelist[account] = false;
            emit RemovedFromWhitelist(account);
        }
    }

    function addManyToWhitelist(address[] calldata accounts) external onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 len = accounts.length;
        for (uint256 i = 0; i < len; i++) {
            if (!whitelist[accounts[i]]) {
                whitelist[accounts[i]] = true;
                allWhitelisted.push(accounts[i]);
                emit Whitelisted(accounts[i]);
            }
        }
    }

    function removeManyFromWhitelist(address[] calldata accounts) external onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 len = accounts.length;
        for (uint256 i = 0; i < len; i++) {
            if (whitelist[accounts[i]]) {
                whitelist[accounts[i]] = false;
                emit RemovedFromWhitelist(accounts[i]);
            }
        }
    }

    // --- Exports filtrés ---
    function exportActiveWhitelisted() public view returns (address[] memory) {
        uint256 count;
        uint256 len = allWhitelisted.length;
        for (uint256 i = 0; i < len; i++) if (whitelist[allWhitelisted[i]]) count++;
        address[] memory result = new address[](count);
        uint256 index;
        for (uint256 i = 0; i < len; i++) if (whitelist[allWhitelisted[i]]) result[index++] = allWhitelisted[i];
        return result;
    }

    function exportActiveBlacklisted() public view returns (address[] memory) {
        uint256 count;
        uint256 len = allBlacklisted.length;
        for (uint256 i = 0; i < len; i++) if (blacklist[allBlacklisted[i]]) count++;
        address[] memory result = new address[](count);
        uint256 index;
        for (uint256 i = 0; i < len; i++) if (blacklist[allBlacklisted[i]]) result[index++] = allBlacklisted[i];
        return result;
    }

    // --- Exports paginés ---
    function exportActiveWhitelistedPaged(uint offset, uint limit) public view returns (address[] memory) {
        address[] memory active = exportActiveWhitelisted();
        require(offset < active.length, "Offset out of range");
        uint256 end = offset + limit > active.length ? active.length : offset + limit;
        address[] memory result = new address[](end - offset);
        for (uint256 i = offset; i < end; i++) result[i - offset] = active[i];
        return result;
    }

    function exportActiveBlacklistedPaged(uint offset, uint limit) public view returns (address[] memory) {
        address[] memory active = exportActiveBlacklisted();
        require(offset < active.length, "Offset out of range");
        uint256 end = offset + limit > active.length ? active.length : offset + limit;
        address[] memory result = new address[](end - offset);
        for (uint256 i = offset; i < end; i++) result[i - offset] = active[i];
        return result;
    }

    // --- Export combiné ---
    function exportActiveLists() external view returns (address[] memory, address[] memory) {
        return (exportActiveWhitelisted(), exportActiveBlacklisted());
    }

    function exportActiveListsPaged(uint offsetWhitelist, uint limitWhitelist, uint offsetBlacklist, uint limitBlacklist)
        external view returns (address[] memory, address[] memory)
    {
        return (
            exportActiveWhitelistedPaged(offsetWhitelist, limitWhitelist),
            exportActiveBlacklistedPaged(offsetBlacklist, limitBlacklist)
        );
    }

    // --- Hook OpenZeppelin ---
    function _update(address from, address to, uint256 amount)
        internal override whenNotPaused
    {
        require(!blacklist[from] && !blacklist[to], "Address blacklisted");
        require(whitelist[to], "Recipient not whitelisted");
        super._update(from, to, amount);
    }
}
