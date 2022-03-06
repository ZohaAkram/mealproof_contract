// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.20;

contract SupplyChain{
    address public owner;
    uint public creationTime;
    bytes32 a;
mapping(address => User) private usersdetail;
address[] private userindex;
uint count =userindex.length;

    constructor()  {
        owner=msg.sender;
        creationTime= block.timestamp;

    }
    function isUser(address _userAddress)public view  returns(bool isIndeed) {
            if(userindex.length == 0) return false;
            return (userindex[usersdetail[_userAddress].index] == _userAddress);
      }
         
    struct us_roles{
       uint us_role;
    }
mapping(address=>uint) us_role;

        struct User{
            uint role;
            string password;
            string us_name;
            address createdBy;
            uint creationTime;
            string location;
            uint index;
            string email;
            

        }
           event LogNewUser   (address indexed _userAddress, uint index,string  name, string password,  string email, uint userrole, bytes32 _hash);
        function setUser(address _userAddress, string memory us_name, string memory password, string memory email,string memory location, uint role) public returns(bytes32 _a,uint index) {
require(isUser(_userAddress)==false);
 usersdetail[_userAddress].createdBy = msg.sender;
            usersdetail[_userAddress].creationTime= block.timestamp;
            usersdetail[_userAddress].us_name=us_name;
            usersdetail[_userAddress].password=password;
            usersdetail[_userAddress].email=email;
            usersdetail[_userAddress].location=location;
            usersdetail[_userAddress].role=role;
            us_role[_userAddress]= role;
            userindex.push(_userAddress);
            usersdetail[_userAddress].index=userindex.length-1;
           a=sha256(abi.encodePacked(_userAddress,us_name,location,password,email,role));
        
             emit  LogNewUser(
            _userAddress,
            usersdetail[_userAddress].index,
            us_name,
            password,
            email,
            us_role[_userAddress],
            a
            );
           
             return (a,userindex.length-1);
        

        }}

