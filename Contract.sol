// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title CharityToken - A Token System for Donations
/// @dev ERC20-like implementation for charity contributions
contract CharityToken {
    string public name = "CharityToken";
    string public symbol = "CTK";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    
    address public owner;
    address public charityAddress;

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Donation(address indexed donor, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor(uint256 _initialSupply, address _charityAddress) {
        require(_charityAddress != address(0), "Invalid charity address");
        owner = msg.sender;
        charityAddress = _charityAddress;
        totalSupply = _initialSupply * (10 ** uint256(decimals));
        balances[owner] = totalSupply;

        emit Transfer(address(0), owner, totalSupply);
    }

    /// @notice Get the balance of an address
    function balanceOf(address _account) public view returns (uint256) {
        return balances[_account];
    }

    /// @notice Transfer tokens to another address
    function transfer(address _to, uint256 _amount) public returns (bool) {
        require(_to != address(0), "Cannot transfer to the zero address");
        require(balances[msg.sender] >= _amount, "Insufficient balance");

        balances[msg.sender] -= _amount;
        balances[_to] += _amount;
        emit Transfer(msg.sender, _to, _amount);
        return true;
    }

    /// @notice Approve an allowance for a spender
    function approve(address _spender, uint256 _amount) public returns (bool) {
        allowances[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    /// @notice Transfer tokens from one address to another
    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) public returns (bool) {
        require(_to != address(0), "Cannot transfer to the zero address");
        require(balances[_from] >= _amount, "Insufficient balance");
        require(allowances[_from][msg.sender] >= _amount, "Allowance exceeded");

        balances[_from] -= _amount;
        balances[_to] += _amount;
        allowances[_from][msg.sender] -= _amount;

        emit Transfer(_from, _to, _amount);
        return true;
    }

    /// @notice Donate tokens to the charity address
    function donate(uint256 _amount) public returns (bool) {
        require(balances[msg.sender] >= _amount, "Insufficient balance");

        balances[msg.sender] -= _amount;
        balances[charityAddress] += _amount;

        emit Donation(msg.sender, _amount);
        emit Transfer(msg.sender, charityAddress, _amount);
        return true;
    }

    /// @notice Update the charity address
    function updateCharityAddress(address _newCharityAddress) public onlyOwner {
        require(_newCharityAddress != address(0), "Invalid address");
        charityAddress = _newCharityAddress;
    }
}
