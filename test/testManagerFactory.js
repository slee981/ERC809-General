let ManagerFactory = artifacts.require('ManagerFactory');
let PriceCalculator = artifacts.require('PriceCalculator');

contract('ManagerFactory', (accounts) => {

    const managerWallet = accounts[0];
    const managerIdentity = accounts[1];
    const managerOwners = [accounts[0], accounts[2]];
    const priceCalc = accounts[3];

    let factory;

    beforeEach('setup Factory', async function() {
        factory = await ManagerFactory.new();
        assert.ok(factory);
    })

    describe('Check factory', () => {
        it('should let you create a new AssetManager', async() => {
            const result = await factory.createNewManager(managerOwners, priceCalc, managerIdentity, managerWallet);
            assert.ok(result);
        });
    })
})
