pragma solidity 0.5.8;

import "./StoreInterface.sol";

contract Selector {
  // 0x20965255
  function getValueSelector() external pure returns (bytes4) {
    StoreInterface i;
    return i.getValue.selector;
  }

  // 0x55241077
  function setValueSelector() external pure returns (bytes4) {
    StoreInterface i;
    return i.setValue.selector;
  }

  // 0x75b24222
  function calcStoreInterfaceId() external pure returns (bytes4) {
    StoreInterface i;
    return i.getValue.selector ^ i.setValue.selector;
  }
}
