pragma solidity 0.5.8;

import "./StoreInterface.sol";

contract Store is StoreInterface {
  uint256 internal value;

  function setValue(uint256 v) external {
    value = v;
  }

  function getValue() external view returns (uint256) {
    return value;
  }

  function supportMethod(bytes4 methodId) external view returns (bool) {
    StoreInterface i;
    return methodId == i.getValue.selector || methodId == i.setValue.selector;
  }

  function supportInterface(bytes4 interfaceId) external view returns (bool) {
    return interfaceId == INTERFACE_ID_STORE;
  }
}
