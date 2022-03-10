// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.20;

contract admin_manufacture
{
    address public owner;
    uint public creationTime;
    bytes32 a;
    // uint role;
    // mapping(address=>uint) role_Id;
    mapping(address => User) private usersdetail;
    address[] private userarray; // array of address of all users
    uint count =userarray.length;

    constructor()  {
        owner=msg.sender;
        creationTime= block.timestamp;

    }
    function isUser(address _userAddress)public view  returns(bool isIndeed) {
            if(userarray.length == 0) return false;
            return (userarray[usersdetail[_userAddress].index] == _userAddress);
      }
         
    // struct user_roles{
    //    uint user_role;
    // }
mapping(address=>uint) user_role;

        struct User{
            uint role;
            string password;
            string userName;
            address createdBy;
            uint creationTime;
            string location;
            uint index;
            string email;
            

        } event LogUpdateUser(address indexed _userAddress, uint index,  string email, string location, string password);
          event LogNewUser   (address indexed _userAddress, uint index,string  name, string password,  string email, uint userrole, bytes32 _hash);
        
        
        function setUser(address _userAddress, string memory userName, string memory password, string memory email,string memory location, uint _role) public returns(bytes32 _a,uint index) {
                require(isUser(_userAddress)==false);
                 usersdetail[_userAddress].createdBy = msg.sender;
                 usersdetail[_userAddress].creationTime= block.timestamp;
                 usersdetail[_userAddress].location=location;
                 usersdetail[_userAddress].role=_role;
                 user_role[_userAddress]= _role;
                 userarray.push(_userAddress);
                 usersdetail[_userAddress].index=userarray.length-1;
                 a=sha256(abi.encodePacked(_userAddress,userName,location,password,email,_role));
        
                 emit  LogNewUser(
                  _userAddress,
                  usersdetail[_userAddress].index,
                  userName,
                  password,
                  email,
                  user_role[_userAddress],
                  a
                  );
                
             return (a,userarray.length-1);
        

        }
        function updateUser(address _userAddress, string memory email, string memory location, string memory password) public returns(bool success) {
           
            require(isUser(_userAddress)==true) ;
            usersdetail[_userAddress].email = email;
            usersdetail[_userAddress].location = location;
            usersdetail[_userAddress].password = password;

            emit LogUpdateUser(
            _userAddress,
            usersdetail[_userAddress].index,
            email,
            location,
            password
            );
            return true;
        }  }
