/*
Implements EIP20 token standard: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
.*/
pragma solidity ^0.5.0;                                                 // Solidity compiler version
import "./EIP20Interface.sol";
//import "./LendingBoard.sol"; //interface statt import

//interface LendingBoard{
//  funtion vote(uint256, bool) public returns(uint256);
//}

/// @notice library makes any address into a payable address
library address_make_payable {
    function make_payable(address x) internal pure returns (address payable) {
        return address(uint160(x));
    }
}

contract TrustToken is EIP20Interface {

    using address_make_payable for address;                             // use this library

    //address LendingBoard_add = 0x692a70D2e424a56D2C6C27aA97D1a86395877b3A;
    //LendingBoard LB = LendingBoard(LendingBoard_add);
    //mapping (address => bool) public isUserLocked;

    
    uint256 public totalSupply;                                         // total amount of tokens

    uint256 constant private MAX_UINT256 = 2**256 - 1;                  // biggest number, that is possible in datatype uint
    mapping (address => uint256) private tokenBalances;                 // token balances of all Trustees
    mapping (address => uint256) public etherBalances;                  // ether balances of all Trustees
    mapping (address => mapping (address => uint256)) public allowed;   // register of all permissions form one user to another
    address[] public participants;                                      // list of all Trustees
    mapping (address => bool) public isTrustee;                         // proof an adress is a Trustee

    string public name;                                                 // name: eg TrustToken
    uint8 public decimals;                                              // How many decimals to show
    string public symbol;                                               // An identifier: eg TT

    uint public goal = 10 ether;                                        // goal of ehter to reach
    uint public contractEtherBalance = 0 ether;                         // total ether balance of this contract
    bool public isIcoActive= true;                                      // checks if ICO is active or not

    uint storeDate; //test Var. Löschen für BA

    constructor(
        uint256 _initialAmount,
        string memory _tokenName,
        uint8 _decimalUnits,
        string memory _tokenSymbol
        
    ) public {
        name = _tokenName;                                              // Set the name of tokens for display purposes
        decimals = _decimalUnits;                                       // Amount of decimals for display purposes
        symbol = _tokenSymbol;                                          // Set the symbol for display purposes
        totalSupply = _initialAmount * (10 ** uint(decimals));          // Set total supply of tokens
    }

     //-------------------------------------------------
    function set(uint x) public {
        storeDate = x;
        
    }
    function get() public view returns (uint) {
        return storeDate;
    }
    
    //-------------------------------------------------
    
    /// @notice checks if token of '_user' are not locked
    /// @param _user The address of an user
   /* modifier userIsNotLocked(address _user) {
        require(isUserLocked[_user]==false);
        _;
    }
    /// @notice checks if '_user' is a Trustee
    /// @param _user The address of an user
    modifier isTrusteeMod(address _user) {
        require(isTrustee[_user] == true);
        _;
    }
    /// @notice checkss if '_add' is the address of ProposalManagement
    /// @param _add The address that should be checked
    modifier calledByLB(address _add)
    {
         require(_add == LendingBoard_add);
        _;
    }

    /// @notice vote for a proposal at '_proposalAddress' with '_stance'
    /// @param _stance true if you want to cast a positive vote, false otherwise
    /// @param _proposalAddress the address of the proposal you want to vote for
    /// @dev isTrusteeMod only callable by Trustess 
    /// @dev userIsNotLocked only callable by user whos token are not locked
    /// @msg.sender The Address who called this function
    function vote(bool _stance, address _proposalAddress) public userIsNotLocked(msg.sender) isTrusteeMod(msg.sender)
    {
        lockUser(msg.sender);
        LB.vote(_stance,_proposalAddress,msg.sender);
    }

    /// @notice locks the token of '_user'
    /// @param _user Address of user to lock
    function lockUser(address _user) private
    {
        isUserLocked[_user]= true;
    }

    /// @notice unlocks token of a user
    /// @param _user Address of user to unlock
    function unlockUser(address _user) private
    {
         isUserLocked[_user]= false;
    }

    /// @notice unlocks token of a list of users
    /// @param _users List of users to unlock
    /// @dev calledByLB only callable by Trustess 
    function unlockUsers(address [] memory _users) public calledByLB(msg.sender)
    {
        for(uint i; i < _users.length; i++)
        {
            unlockUser(_users[i]);
        }

    }
    
    */

    /// @notice send '_value' token to '_to' from 'msg.sender'
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(tokenBalances[msg.sender] >= _value); //requires token balance of 'msg.sender' to be equal or greater than '_value' to execute following code
        tokenBalances[msg.sender] -= _value; // subtract '_value' from token balance of 'msg.sender'
        tokenBalances[_to] += _value; // add '_value' to token balance of '_to'
        emit Transfer(msg.sender, _to, _value); //display transaction between 'msg.sender' and '_to'
        return true;
    }

    /// @notice send '_value' token to '_to' from '_from' on the condition it is approved by '_from'
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) public //user_is_not_locked(_from)
    returns (bool success)
    {
        uint256 allowance = allowed[_from][msg.sender]; // save value of 'allowed' on the position of '_from' and 'msg.sender'
        require(tokenBalances[_from] >= _value && allowance >= _value); // requires token balance of '_from' to be equal or greater than 'value'
                                                                        // also 'allowance' has to be equal or greater than '_value' to execute the following code
        tokenBalances[_to] += _value;                                   
        tokenBalances[_from] -= _value;
        if (allowance < MAX_UINT256) {                                  // allowance cant be creater than 'MAX_UINT256'
            allowed[_from][msg.sender] -= _value;
        }
        emit Transfer(_from, _to, _value); //display transaction between '_from' and '_to'
        return true;
    }

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return tokenBalances[_owner];
    }
    
    /// @notice 'msg.sender' approves '_spender' to spend '_value' tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value); //display approval between 'msg.sender' and '_spender'
        return true;
    }

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    
    /// @notice invest Ether to become a Trustee and get token when ICO is not active anymore
    function participate () external payable{
        
        if(isIcoActive)
        {
            uint allowedToAdd = msg.value; // the value of 'allowedToAdd' will be added to the balance ot the contract
                                            // @msg.value is the amount of Ether which 'msg.sender' sended along 
            if( (contractEtherBalance + msg.value) > goal) // if ether balance of contract added with 'msg.value' exceeds contract ehter goal
            {
                allowedToAdd = goal - contractEtherBalance; // 'allowedToAdd' is equal to the amount of Ether which can be added to reach the 'goal'
                address add1= msg.sender; // 'add1' is a helping variable
                address payable addr2 = add1.make_payable();    // 'add2' is a helping variable and can reveive Ether
                addr2.transfer(contractEtherBalance + msg.value - goal);  // transfer the Ether which exceeded the goal back to 'msg.sender'

            }

            etherBalances[msg.sender] += allowedToAdd; //add to senders ether_balance
            contractEtherBalance += allowedToAdd; // add to contract_balance
            
            if( isTrustee[msg.sender] == false ) // checks if 'msg.sender' is a Trustee
            {
                participants.push(msg.sender); //msg.sender to be Trustee
                isTrustee[msg.sender] = true; //msg.sender is Trustee
            }
            
            /* bad code
            for(uint i = 0; i < participants.length; i++) // go trough all participants
            {
                if(participants[i] == msg.sender){ //break the for-loop if 'msg.sender' already participant
                    break;
                }
            
                if(i == participants.length-1 ){ // if msg.sender made it to the last participant he will be put into array
                    participants.push(msg.sender); //msg.sender to be Trustee
                    isTrustee[msg.sender] = true; //msg.sender is Trustee
                }
            }
            
            if( participants.length==0) //the very first participant will be add to the participants array
            {
                participants.push(msg.sender);
                isTrustee[msg.sender] = true; //msg.sender is Trustee

            }
            */
        }
        
        
        if(contractEtherBalance >= goal && isIcoActive) // if goal was reached and ico is still active, then distrube token to all Trustees
        {    
            distributeToken(); //distribute all tokens to all Trustees
            isIcoActive = false; //ICO is not active anymore
        }
        

    }


    /// @notice distribute tokenSupply between all Trustees
    function distributeToken() private 
    {
        for(uint i = 0; i < participants.length; i++)  // go trough all Trustees
        {
            tokenBalances[ participants[i] ] =(  (etherBalances[ participants[i] ]) * totalSupply ) / contractEtherBalance;//Token = (Ether/contractEtherBalance) * totalSupply
            emit Transfer( 0x0000000000000000000000000000000000000000, participants[i], tokenBalances[ participants[i] ]);
        }
        

    }
    /// @return Amount of all Trustees
    function getParticipantsCount() public view returns(uint)
    {
        return(participants.length);
    }

    function payFees () external payable
    {
        contractEtherBalance += msg.value;
    } 

    /// @return ether balance of 'msg.sender'
    function getEtherBalances() public view returns(uint)
    {
        return (etherBalances[msg.sender]);
    }
   

   // Display transactions and approvals
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}



