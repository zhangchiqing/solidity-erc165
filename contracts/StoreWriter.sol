pragma solidity 0.5.8;

import "./StoreInterface.sol";
import "./ERC165/ERC165Query.sol";

contract StoreWriter is StoreInterfaceId, ERC165Query {
  StoreInterface store;

  constructor (address storeAddress) public {
    require(doesContractImplementInterface(storeAddress, STORE_INTERFACE_ID), "Doesn't support StoreInterface");

    store = StoreInterface(storeAddress);
  }

  function writeStoreValue(uint256 v) external {
    return store.setValue(v);
  }
}
