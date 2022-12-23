// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;  //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;

  constructor(address exampleExternalContractAddress) {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  //events
  event Stake(address indexed sender, uint256 amount);

  mapping (address => uint256) public balances;
  uint256 public deadline = block.timestamp + 48 hours;
  uint256 public constant threshold = 1 ether;
  bool availableToWithdraw = false;

  modifier notComplete() {
    bool completed = exampleExternalContract.completed();
    require(!completed, "Staking process has already completed");
    _;
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  // ( Make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
  function stake() public payable {
    require(block.timestamp < deadline, 'Deadline has passed');
    uint256 _amount = msg.value;
    address _staker = msg.sender;
    balances[_staker] = _amount;
    emit Stake(_staker, _amount);
  }


  // After some `deadline` allow anyone to call an `execute()` function
  // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`
  function execute() public notComplete{
    if (address(this).balance >= threshold) {
      exampleExternalContract.complete{value: address(this).balance}();
    } else {
      availableToWithdraw = true;
    }
  }


  // If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance
  function withdraw() public notComplete{
    require(block.timestamp >= deadline, 'deadline has not passed');
    require(availableToWithdraw, 'threshold not met');
    payable(msg.sender).transfer(balances[msg.sender]);
    balances[msg.sender] = 0;
  }


  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() public view returns (uint256) {
    if (block.timestamp >= deadline) {
      return 0;
    }
    return deadline - block.timestamp;
  }


  // Add the `receive()` special function that receives eth and calls stake()
  receive() external payable {
    stake();
  }
}
