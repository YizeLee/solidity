//SPDX-License-Identifier:MIT
pragma solidity ^0.8.17;
interface IERC20{
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns(uint256);
    function balanceOf(address amount) external view returns(uint256);
    function transfer(address to, uint256 value) external returns(bool);
    function allowance(address owner, address spender) external view returns(uint256);
    function approve(address spender, uint256 value) external returns(bool);
    function transferFrom(address from, address to, uint256 value) external returns(bool);

    function name() external returns(string memory);
    function symbol() external returns(string memory);
    function decimals()external returns(uint8);

    function mint(address account, uint256 value) external;
    function burn(address account, uint256 value) external;
}
contract ERC20 is IERC20{
    uint256 _totalSupply;
    mapping(address => uint256) _balance;
    mapping(address=>mapping(address=>uint256))_allowance;
    string _name;
    string _symbol;
    address _owner;
    constructor(string memory name_, string memory symbol_){
        _totalSupply = 10000;
        _balance[msg.sender] = 10000;
        _name = name_;
        _symbol = symbol_;
        _owner = msg.sender;
    }
    modifier checkOwner(){
        require(_owner == msg.sender, unicode"不是合約持有者");
        _;
    }
    function name() public view returns(string memory){
        return _name;
    }
    function symbol() public view returns(string memory){
        return _symbol;
    }
    function decimals() public pure returns(uint8){
        return 18;
    }

    function mint(address account, uint256 value) public checkOwner{
        require(account!= address(0),unicode"不能為0x0");
        _totalSupply += value;
        _balance[account] += value;
        emit Transfer(address(0), account, value);
    }
    function burn(address account, uint256 value) public checkOwner{
        uint256 accountBalance = _balance[account];
        require(account!= address(0),unicode"不能為0x0");
        require(accountBalance >= value, unicode"餘額不足，無法燒毀");
        _balance[account] -= value;
        _totalSupply -= value;
        emit Transfer(account, address(0), value);
    }

    function totalSupply() public view returns(uint256){
        return _totalSupply;
    }
    function balanceOf(address amount) public view returns(uint256){
        return _balance[amount];
    }
    function _transfer(address from, address to, uint256 value) internal{
        uint myBalance = _balance[from];
        require(to != address(0), unicode"不能是0x0");
        require(myBalance >= value, unicode"餘額不足");
        _balance[from] = myBalance - value;
        _balance[to] = _balance[to] + value;
        emit Transfer(from, to, value);
    }
    function transfer(address to, uint256 value) public returns(bool){
        _transfer(msg.sender, to, value);
        return true; 
    }
    function allowance(address owner, address spender) public view returns(uint256){
        return _allowance[owner][spender];
    }
    function _approve(address owner, address spender, uint256 value) internal{
        _allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }
    function approve(address spender, uint256 value) public returns(bool){
        _approve(msg.sender, spender, value);
        return true;
    }
    function transferFrom(address from, address to, uint256 value) public returns(bool){
        uint256 myAllowance = _allowance[from][msg.sender];
        require(myAllowance >= value, unicode"超過額度");
        _approve(from, msg.sender, myAllowance-value);
        _transfer(from, to, value);
        return true;
    }

}
