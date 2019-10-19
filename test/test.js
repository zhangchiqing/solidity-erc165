const Store = artifacts.require('Store');
const StoreReader = artifacts.require('StoreReader');
const StoreWriter = artifacts.require('StoreWriter');
const NonStore = artifacts.require('NonStore');
const Selector = artifacts.require('Selector');
const assert = require('assert');

contract('StoreReader', () => {
  it('should be able to read store value', async () => {
    const store = await Store.new();
    await store.setValue(100);
    const reader = await StoreReader.new(store.address);
    assert.equal(await reader.readStoreValue(), 100);
  });

  it('should fail when setStore with NonStore', async () => {
    const nonStore = await NonStore.new();
    let succeeded = false;
    try {
      await StoreReader.new(nonStore.address);
    } catch (e) {
      assert.equal(e.reason, 'Doesn\'t support StoreInterface');
    }
    assert.equal(succeeded, false);
  });

  it('should print selector interface id', async () => {
    const sel = await Selector.new();
    // getValueSelector 0x20965255
    console.log('getValueSelector', await sel.getValueSelector());

    // setValueSelector 0x55241077
    console.log('setValueSelector', await sel.setValueSelector());

    // calcStoreInterfaceId 0x75b24222
    console.log('calcStoreInterfaceId', await sel.calcStoreInterfaceId());
  });
});

contract('StoreWriter', () => {
  it('A reader should be able to read the value after a writer sets a value', async () => {
    const store = await Store.new();
    const reader = await StoreReader.new(store.address);
    const writer = await StoreWriter.new(store.address);
    await writer.writeStoreValue(100);
    assert.equal(await reader.readStoreValue(), 100);
  });
});
