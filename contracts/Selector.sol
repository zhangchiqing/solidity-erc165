pragma solidity 0.5.8;

import "./StoreInterface.sol";

contract Selector {
  function genInterfaceId() external pure returns (bytes4) {
    StoreInterface i;
    return i.getValue.selector ^ i.setValue.selector;
  }
}

