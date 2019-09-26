const Store = artifacts.require('Store');
const StoreReader = artifacts.require('StoreReader');
const NonStore = artifacts.require('NonStore');
const Selector = artifacts.require('Selector');
const assert = require('assert');

contract('StoreReader', () => {
  it('should not be empty', async () => {
    const reader = await StoreReader.new();
    let succeeded = false;
    try {
      await reader.getStoreValue();
    } catch (e) {
      assert.equal(e.message, 'Returned error: VM Exception while processing transaction: revert empty store');
    }
    assert.equal(succeeded, false);
  });

  it('should support method selector', async () => {
    const reader = await StoreReader.new();
    const store = await Store.new();
    await store.setValue(100);
    await reader.setStore(store.address);
    assert.equal(await reader.getStoreValue(), 100);
  });

  it('should fail when setStore with NonStore', async () => {
    const reader = await StoreReader.new();
    const nonStore = await NonStore.new();
    let succeeded = false;
    try {
      await reader.setStore(nonStore.address);
    } catch (e) {
      assert.equal(e.message, 'Returned error: VM Exception while processing transaction: revert');
    }
    assert.equal(succeeded, false);
  });

  it('should print selector interface id', async () => {
    const sel = await Selector.new();
    console.log('StoreInterface.INTERFACE_ID_STORE: ', await sel.genInterfaceId());
  });
});
