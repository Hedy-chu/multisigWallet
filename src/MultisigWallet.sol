// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;
import {Test, console} from "forge-std/Test.sol";

contract MultisigWallet {
    address[] public owners;
    mapping (address => bool) public isOwner;
    uint256 public numOfConfirmed;

    struct Transaction {
        address to; //调用的合约
        uint256 signCount;
        uint256 value;
        bool executed;
        bytes data;
    }

    Transaction[] public transactions;
    // 避免重复确认
    mapping(uint => mapping(address =>bool)) public isConfirm;

    constructor(address[] memory _owners, uint  _numOfConfirmed) {
        require(_owners.length >= _numOfConfirmed && _owners.length > 0, "param error");
        require(_numOfConfirmed > 0,"numOfConfirmed must bigger than zero");
        for (uint i = 0; i < _owners.length; i++) {
            require(_owners[i] != address(0),"owner can't be zero");
            require(!isOwner[_owners[i]],"owner not unique ");
            isOwner[_owners[i]] = true;
            owners.push(_owners[i]);
        }
        numOfConfirmed = _numOfConfirmed;
    }

    // onlyOwner
    modifier onlyOwner () {
        require(isOwner[msg.sender],"only owner can invoke");
        _;
    }

    // 是否存在
    modifier isExist (uint _transIndex){
        require(transactions.length > _transIndex,"tx not exist");
        _;
    }

    // 是否已经被执行
    modifier isExecuted(uint _transIndex){
        require(!transactions[_transIndex].executed,"tx already executed");
        _;
    }

    // 是否被confirm
    modifier isConfirmed(uint _transIndex){
        require(!isConfirm[_transIndex][msg.sender],"address already confirmed");
        _;
    }

    // creat transcation
    function creatTranscation(address _to, uint256 _value,bytes memory _data) public onlyOwner() returns (uint transIndex){
        transactions.push(
            Transaction({
                to:_to,
                signCount:1,
                value:_value,
                executed:false,
                data:_data
            }));
        return transactions.length;  
    }

    // confirm transcation
    function confirmTranscation(uint _transIndex) public onlyOwner() isConfirmed(_transIndex)
            isExist(_transIndex) isExecuted(_transIndex){

        transactions[_transIndex].signCount++;

        isConfirm[_transIndex][msg.sender] = true;
        
    }
    // excute transcation
    function excuteTranscation(uint _transIndex) public isExist(_transIndex) isExecuted(_transIndex) {
        Transaction storage transaction = transactions[_transIndex];
        require(transaction.signCount >= numOfConfirmed,"confirm not enough");
        transaction.executed = true;
        console.log(transaction.value);
        (bool success,) = transaction.to.call{value: transaction.value}(transaction.data);
        require(success,"transaction not success");
    }
    // 接收eth
    receive() external payable {

    } 
}