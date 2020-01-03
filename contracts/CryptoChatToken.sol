pragma solidity >= 0.5.0;

// ----------------------------------------------------------------------------
// Mint token contract
//
// Deployed to : 0x083aCf10a49390EDd3220EC1396609657Ceb4617
// Symbol      : Mint
// Name        : Mint Token
// Total supply: 1000000000
// Decimals    : 18
//
// Enjoy.
//
// (c) by Moritz Neto with BokkyPooBah / Bok Consulting Pty Ltd Au 2017. The MIT Licence.
// ----------------------------------------------------------------------------


// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------
contract SafeMath {
    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function safeMul(uint a, uint b) public pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function safeDiv(uint a, uint b) public pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}


// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
// ----------------------------------------------------------------------------
contract ERC20Interface {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


// ----------------------------------------------------------------------------
// Contract function to receive approval and execute function in one call
//
// Borrowed from MiniMeToken
// ----------------------------------------------------------------------------
contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public;
}


// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
/*
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}*/



// ----------------------------------------------------------------------------
// User contract
// ----------------------------------------------------------------------------
contract CryptoChatUsers{

    // Declare mapping to hold validUsers
    mapping(address => bool) internal validUsers;

    // Mapping of users avaiable token info. 
    mapping(address => User) internal Users;

    // The struct to hold the number of tokens the user can give and when the token count was last updated.
    struct User
    {
        uint availableTokens;
        uint blockNumber;
        uint blockTime;
        string username;
    }

    mapping(string => bool) internal userTaken;

    uint internal dailyTokenAmount;

    // mapping to hold the possible refund of the potential user
    mapping(address => uint) internal userDepositRefund;

    // Declare variable to hold the price of a user account in ETH.
    uint internal userPrice;

    // Events
    //event LogNewOraclizeQuery(string description);                       // Called when an oricalize query is made.
    event LogUpdate(address indexed _owner, uint indexed _balance);        // Called when the user object is made.
    //event LogPriceUpdate(string price);                                  // Called when the the ETHUSD string is set.
    event LogUserPrice(uint uPrice);                                       // Called when the userPrice is calculated.
    event LogDisplay(string message);                                      // Used to log a message.
    event LogValidUser(bool valid);                                        // Called to sell if the sender is a valid user.
    event LogBlock(uint block);
    
    // Constructor
    constructor() payable public {

        emit LogUpdate(address(this), address(this).balance);

        userPrice = 4000000000000000;

        dailyTokenAmount = 21;
    }
 

    // Function to validate an address as a new user.
    function addUser(string memory username) public payable{
        // Condition to test if address is already valid.
        require(validUsers[msg.sender] == false, "You're already a valid user.");

        require(userTaken[username] == false, "Username already taken.");
        
        if(userPrice > msg.value){
            emit LogDisplay("Not enough ether given.");
            revert("");
        }

        if(bytes(username).length > 25 || bytes(username).length < 4){
            emit LogDisplay("Invalid username length.");
            revert("");
        }

        validUsers[msg.sender] = true;
        userTaken[username] = true;
        Users[msg.sender] = User(dailyTokenAmount, block.number, now, username);

        userDepositRefund[msg.sender] = (msg.value - userPrice);
        emit LogDisplay("User created!! =D");
        emit LogValidUser(userTaken[username]);
        emit LogDisplay(username);

    }

    // Function to validate if the caller is a valid user.
    function isUser() public view returns(bool){
        return validUsers[msg.sender];
    }

    function usernameTaken(string memory username) public view returns(bool){
        return userTaken[username];
    }

    function getUsername() public onlyUsers view returns(string memory) {
        return Users[msg.sender].username;
    }


    modifier onlyUsers{
        require(validUsers[msg.sender],"Only valid users can do this.");
        _;
    }

    // Function to withdaw extra ether sent that was not used to create a valid address.
    function withdrawFunds() public{
       // Set the amount to be withdrawn.
        uint amount = userDepositRefund[msg.sender];

        // Set the users deposit to be refunded to 0.
        userDepositRefund[msg.sender] = 0;

        // Send the user the refund.
        msg.sender.transfer(amount);

        emit LogUserPrice(amount);

        emit LogDisplay("Ether was refunded.");
    }


}

// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals and assisted
// token transfers
// ----------------------------------------------------------------------------
contract CryptoChatToken is ERC20Interface, SafeMath, CryptoChatUsers {
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    uint internal mintedAmount;

    uint internal messageID;

    event LogMessage(address sender, string username, string message, uint messageID); // Event to emit a message sent by a user.

    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor() payable public{
        symbol = "CCT";
        name = "Crypto Chat Token";
        decimals = 18;
        _totalSupply = 1000000000000000000;
        balances[msg.sender] = _totalSupply;
        mintedAmount = 1000000000000000000;
        messageID = 0;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    // ------------------------------------------------------------------------
    // Total supply
    // ------------------------------------------------------------------------
    function totalSupply() public view returns (uint) {
        return _totalSupply - balances[address(0)];
    }


    // ------------------------------------------------------------------------
    // Get the token balance for account tokenOwner
    // ------------------------------------------------------------------------
    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }

    function availableTokens(address tokenOwner)public view returns(uint avaiableTokens){
        return Users[tokenOwner].availableTokens;
    }


    // ------------------------------------------------------------------------
    // Mint a new token
    function mintToken(address target) public onlyUsers{

        require(validUsers[target] && (msg.sender != target), "Only valid valid users can mint and recieve tokens.");

        if(block.number >= Users[msg.sender].blockNumber + 5760){
            Users[msg.sender].blockNumber = block.number;
            Users[msg.sender].availableTokens = dailyTokenAmount;
        }

        if(Users[msg.sender].availableTokens == 0)
        {
            emit LogDisplay("No avaiable tokens to give.");
            return;
        }

        Users[msg.sender].availableTokens--;
        balances[target] += mintedAmount;
        _totalSupply += mintedAmount;
        emit Transfer(msg.sender, target, mintedAmount);

    }

    function mintMessage(string memory message) public onlyUsers{

        if(block.number >= Users[msg.sender].blockNumber + 5760){
            Users[msg.sender].blockNumber = block.number;
            Users[msg.sender].availableTokens = dailyTokenAmount;
        }

        if(Users[msg.sender].availableTokens == 0)
        {
            emit LogDisplay("No avaiable tokens to give.");
            return;
        }

        Users[msg.sender].availableTokens--;
        messageID++;
        emit LogMessage(msg.sender, Users[msg.sender].username, message, messageID);
    }



    // ------------------------------------------------------------------------
    // Transfer the balance from token owner's account to to account
    // - Owner's account must have sufficient balance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transfer(address to, uint tokens) public onlyUsers returns (bool success){
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Token owner can approve for spender to transferFrom(...) tokens
    // from the token owner's account
    //
    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
    // recommends that there are no checks for the approval double-spend attack
    // as this should be implemented in user interfaces 
    // ------------------------------------------------------------------------
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Transfer tokens from the from account to the to account
    // 
    // The calling account must already have sufficient tokens approve(...)-d
    // for spending from the from account and
    // - From account must have sufficient balance to transfer
    // - Spender must have sufficient allowance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    // ------------------------------------------------------------------------
    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }


    // ------------------------------------------------------------------------
    // Token owner can approve for spender to transferFrom(...) tokens
    // from the token owner's account. The spender contract function
    // receiveApproval(...) is then executed
    // ------------------------------------------------------------------------
    function approveAndCall(address spender, uint tokens, bytes memory data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);
        return true;
    }


    // ------------------------------------------------------------------------
    // Don't accept ETH
    // ------------------------------------------------------------------------
    function () external payable {
        revert("");
    }


    // ------------------------------------------------------------------------
    // Owner can transfer out any accidentally sent ERC20 tokens
    // ------------------------------------------------------------------------
    /*
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }*/
}