pragma solidity 0.5.8;

contract StoreInterfaceId {
  // StoreInterface.getValue.selector ^ StoreInterface.setValue.selector
  bytes4 internal constant INTERFACE_ID_STORE = 0x75b24222;
}

contract StoreInterface is StoreInterfaceId {
  function getValue() external view returns (uint256);
  function setValue(uint256 v) external;
  function supportMethod(bytes4 methodId) external view returns (bool);
  function supportInterface(bytes4 interfaceId) external view returns (bool);
}
