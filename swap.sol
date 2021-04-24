pragma solidity >=0.4.17;


// How to use
// 1. call `create` to begin the swap
// 2. the seller approves the TokenSwap contract to spend the amount of tokens
// 3. the buyer transfers the required amount of ETH to release the tokens

contract SToken {
  function allowance(address _owner, address _spender) constant public returns (uint256 remaining);
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
}

contract TokenSwap {
  address owner;

  modifier owneronly {
    require (msg.sender == owner);
    _;
  }

  function setOwner(address _owner) public owneronly {
    owner = _owner;
  }

  constructor() public {
    owner = msg.sender;
  }

  struct Swap {
    address token;           // Address of the token contract
    uint tokenAmount;        // Number of tokens 
    uint price;              // Price to be paid by buyer
    address seller;          // Seller's address (holder of tokens)
    address recipient;       // Address to receive the tokens
  }

  mapping (address => Swap) public Swaps;

  function create(address token, uint tokenAmount, uint price, address seller, address buyer, address recipient) public {
    Swap storage swap = Swaps[buyer];
    require(swap.token == 0);
    Swaps[buyer] = Swap(token, tokenAmount, price, seller, recipient);
  }


  function conclude() public payable {

    Swap storage swap = Swaps[msg.sender];
    require(swap.token != 0);

    SToken token = SToken(swap.token);
    uint tokenAllowance = token.allowance(swap.seller, this);
    require(tokenAllowance >= swap.tokenAmount);
    require(msg.value >= swap.price);
    token.transferFrom(swap.seller, swap.recipient, swap.tokenAmount);
    swap.seller.transfer(swap.price);

    // Refund seller
    if (tokenAllowance > swap.tokenAmount) {
      token.transferFrom(swap.seller, swap.seller, tokenAllowance - swap.tokenAmount);
    }

    // Refund buyer
    if (msg.value > swap.price) {
      msg.sender.transfer(msg.value - swap.price);
    }

    delete Swaps[msg.sender];
  }

  function cancel(address buyer) public {
      //to cancel if the swap is initiated
    Swap storage swap = Swaps[buyer];
    require(swap.token != 0);

    require(
      msg.sender == buyer ||
      msg.sender == swap.seller ||
      msg.sender == swap.recipient ||
      msg.sender == owner);

    SToken token = SToken(swap.token);
    uint tokenAllowance = token.allowance(swap.seller, this);
    if (tokenAllowance > 0) {
      token.transferFrom(swap.seller, swap.seller, tokenAllowance);
    }
    delete Swaps[buyer];
  }

}
