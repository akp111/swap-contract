pragma solidity >=0.4.24;

interface ERC20Interface {
    
    function totalsupply() external view returns(uint);
    function balanceOf (address tokenOwner) external view returns(uint balance);
    function transfer(address to, uint tokens) external returns(bool success);
    function allowance(address TokenOwner, address spender) external view returns(uint remaining);
    function approve(address spender, uint token) external returns(bool success);
    function transferFrom(address from, address to, uint token) external returns(bool success);
    
    event Transfer(address indexed from, address indexed to,uint tokens);
    event Approval(address indexed tokenOwner,address indexed spender,uint token);
}

contract TestToken is ERC20Interface {
  string public constant name = "Test Token";
  string public constant symbol = "TEST";
  uint public constant decimals = 8;
    uint public totalSupply;
  uint256 public constant INITIAL_SUPPLY = 10000 * (10 ** uint256(decimals));

  constructor() public {
    totalSupply = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
  }
  mapping(address=>uint) public balances;
  mapping(address=>mapping(address=>uint)) public allowed;
}
