pragma solidity 0.5.8;

import "./StoreInterface.sol";
import "./ERC165/ERC165Query.sol";

contract StoreReader is StoreInterfaceId, ERC165Query {
  StoreInterface store;

  constructor (address storeAddress) public {
    require(doesContractImplementInterface(storeAddress, STORE_INTERFACE_ID), "Doesn't support StoreInterface");

    store = StoreInterface(storeAddress);
  }

  function readStoreValue() external view returns (uint256) {
    return store.getValue();
  }
}
