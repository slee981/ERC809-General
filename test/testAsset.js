let PriceCalculator = artifacts.require('PriceCalculator');
let ManagerFactory = artifacts.require('ManagerFactory');
let AssetManager = artifacts.require('AssetManager');
let Asset = artifacts.require('Asset');

contract('Asset', (accounts) => {

    // constructor args for manager
    const managerWallet = accounts[0];
    const managerIdentity = accounts[1];
    const managerOwners = [accounts[0], accounts[2]];

    // constructor arg for asset
    const inventory = 3;
    const minRentTime = 1;

    // fake address to play attacker
    const attacker = accounts[4];
    const renter = attacker;

    // fake info for attack reservation
    const reservation = accounts[5];
    const start = 1;
    const stop = 10;

    // fake info for price calculator
    const pricePerSecond = 100;

    let factory;
    let assetManager;
    let assetManagerAddr;
    let asset;
    let assetAddr;
    let priceCalc;
    let priceCalcAddr;

    beforeEach('setup Factory, AssetManager, and Asset', async function() {
        factory = await ManagerFactory.new();
        assert.ok(factory);

        priceCalc = await PriceCalculator.new(pricePerSecond);
        assert.ok(priceCalc);
        priceCalcAddr = priceCalc.contract.address;

        const result = await factory.createNewManager(managerOwners, priceCalcAddr, managerIdentity, managerWallet);
        assert.ok(result);

        let managers = await factory.getAssetManagers();
        assetManagerAddr = managers[0];
        assetManager = await AssetManager.at(assetManagerAddr);
        assert.ok(assetManager);

        await assetManager.addNewAsset(inventory, minRentTime, {from:managerOwners[0]});
        const newAssets = await assetManager.getAssets();
        assetAddr = newAssets[0];
        asset = await Asset.at(assetAddr);
        assert.ok(asset);
    })

    describe('Check RentableAsset', () => {
        it('should store the correct manager address', async() => {
            const _managerAddr = await asset.getAssetManager();
            assert.equal(_managerAddr, assetManagerAddr);
        });

        it('should revert if anyone but the assetManager tries to add a reservation', async() => {
            try {
                await asset.addReservation(reservation, renter, start, stop, {from:attacker});
                assert.fail('Expected revert');
            } catch (error) {
                const revertFound = error.message.search('revert') >= 0;
                assert(revertFound, `Expected "revert", got ${error} instead`);
            }
        });
    })
})
