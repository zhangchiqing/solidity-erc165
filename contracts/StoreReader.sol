pragma solidity 0.5.8;

import "./StoreInterface.sol";

contract StoreReader is StoreInterfaceId {
  StoreInterface store;

  function setStore(address storeAddress) external {
    store = StoreInterface(storeAddress);
    require(store.supportInterface(INTERFACE_ID_STORE), "missing implementation");
  }

  function getStoreValue() external view returns (uint256) {
    require(store != StoreInterface(0), "empty store");
    return store.getValue();
  }
}
