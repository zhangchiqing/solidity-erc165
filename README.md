# solidity-erc165

Let's say we have a simple Store contract that stores a uint256 value which can be queried or updated:

```solidity
// Store.sol

contract Store {
  uint256 internal value;

  function setValue(uint256 v) external {
    value = v;
  }

  function getValue() external view returns (uint256) {
    return value;
  }
}
```

And this Store contract is deployed and has an address. Now if we have a `StoreReader` contract, how to query the current value of the Store contract with its address?

```
// StoreReader.sol

contract StoreReader {
  function getStoreValue(address store) external view returns (uint256) {
    // ?
  }
}
```

Well, we can define a contract interface and import it to `StoreReader`, which provides the definition of the functions that `Store` contract exposes:

```
// StoreInterface.sol
interface StoreInterface {
  function getValue() external view returns (uint256);
}
```

With the contract interface, `StoreReader` is able to cast an address into the interface, and knows how to send calls to the `Store` contract:

```
// StoreReader.sol
import "./StoreInterface.sol";

contract StoreReader {
  function readStoreValue(address store) external view returns (uint256) {
    return StoreInterface(store).getValue();
  }
}
```

(The following test case should pass)

To be a bit more strict, we could also specify in the `Store` contract to be a `StoreInterface`, so that if we made a mistake that we changed the definition of the `getValue` function in `Store` but forgot to update `StoreReader`, then the code won't compile.

```
// Store.sol
import "./StoreInterface.sol";

contract Store is StoreInterface {
  uint256 internal value;

  function setValue(uint256 v) external {
    value = v;
  }

  function getValue() external view returns (uint256) {
    return value;
  }
}
```

## StoreWriter

And now let's say we also want a `StoreWriter` which only calls `Store`'s `setValue` function to update the value. In order to do that, we could extend the `StoreInterface` to include the `setValue` function, and let `StoreWriter` depend on that:

```
// StoreInterface.sol
interface StoreInterface {
  function getValue() external view returns (uint256);
  function setValue() external ;
}
```

```
// StoreWriter.sol
import "./StoreInterface.sol";

contract StoreWriter {
  function writeStoreValue(address store, uint256 value) {
    return StoreInterface(store).setStore(value);
  }
}
```

## Problem
But what if the input address is not a Store contract, but a contract that doesn't have a getValue function? In which case, the transaction will revert.

So we need a way for our `StoreReader` to know if the given address is a contract that provides the `getValue` function, so that  ... getValue is not provided.

But how to tell if a deployed contract has implemented certain function before actually making a call to that function?

Moreover, how to tell if a deployed contract has implemented a group of certain functions before actually making any call to any of those functions?

That is what the ERC165 standard is for.

## ERC165

The idea behind ERC165 is that, if a contract would like to expose a group functions for other contract to interact with, then it needs to explicitly say it supports the interface that includes all supported functions.

In our case, if a `Store` contract would like other contract like `StoreReader` to call its `getValue` function, then `Store` contract needs to explicitly say it supports the `StoreInterface` which includes the definition of the `getValue` function.

And `StoreInterface` might include multiple functions other than the `getValue`, if `Store` explicitly says it supports the `StoreInterface`, then it's equivalent of saying it supports all functions included by that interface.

"""And our contract can "trust" it and continue by making a call to a function that the supported interface includes.

"""You might wonder, what if the contract "lies" about what interface it supports? We will discuss this problem later. For now, let's first see how the happy path works :)

[ERC165 defines an interface](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-165.md#how-a-contract-will-publish-the-interfaces-it-implements):

```
interface ERC165 {
    /// @notice Query if a contract implements an interface
    /// @param interfaceID The interface identifier, as specified in ERC-165
    /// @dev Interface identification is specified in ERC-165. This function
    ///  uses less than 30,000 gas.
    /// @return `true` if the contract implements `interfaceID` and
    ///  `interfaceID` is not 0xffffffff, `false` otherwise
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}
```

This interface defines a `supportsInterface` for a contract to answer if it supports certain interface. In our example, `Store` contract needs to implement this ERC165 interface and provides implementation for the `supportsInterface` to return `true` when it's called with the `interfaceID` of `StoreInterface`.

Wait, What is the `interfaceID` of the `StoreInterface`? That's another standard that ERC165 defines - a way to specify the ID of an interface.

OK, but why the `interfaceID` is a `bytes4` value, why not using something like a string instead? Well, because string like would take way more than 4 bytes to store. And the 4 bytes of `bytes4` value would be a good balance to use just enough space to distinguish interfaces.

So ERC165 defines that the `interfaceID` is the XOR of all function selectors in the interface.

For example, If our interface `StoreInterface` defines two functions: `getValue` and `setValue`, then the ID is the XOR of the function selector of the two functions.

Ethereum defines that a function selector is the first 4 bytes of the Keccak-256 hash of the function’s prototype. So the function selector of the `getValue` function is the first 4 bytes of `keccak("getValue() external returns (uint256)")`

To actually calculate the function selector, we can use a `Selector` contract:

```
pragma solidity 0.5.8;

import "./StoreInterface.sol";

contract Selector {
  function calcStoreInterfaceID() external pure returns (bytes4) {
    StoreInterface i;
    return i.getValue.selector ^ i.setValue.selector;
  }
}
```

ERC165 defines that an interface can be identified as the XOR of all

```
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
    return methodId == i.getValue.selector;
  }
}
```

```
interface StoreInterface {
  function getValue() external view returns (uint256);
  function supportMethod(bytes4 methodId) external view returns (bool);
}
```


```
import "./StoreInterface.sol";

contract StoreReader {
  StoreInterface store;

  function setStore(address storeAddress) external {
    store = StoreInterface(storeAddress);
    StoreInterface i;
    require(store.supportMethod(i.getValue.selector), "missing implementation");
  }

  function getStoreValue() external view returns (uint256) {
    require(store != StoreInterface(0), "empty store");
    return store.getValue();
  }
}
```

```
contract NonStore {
}
```
