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

    // fake address to play attacker
    const attacker = accounts[4];
    const renter = attacker;
    const renter2 = accounts[6];
    const renter3 = accounts[7];

    // fake info for attack reservation
    const reservation = accounts[5];
    let start = 1;
    let stop = 10;

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
        if (priceCalcAddr == undefined) {
          priceCalcAddr = priceCalc.contract._address;
        }

        const result = await factory.createNewManager(managerOwners, priceCalcAddr, managerIdentity, managerWallet);
        assert.ok(result);

        let managers = await factory.getAssetManagers();
        assetManagerAddr = managers[0];
        assetManager = await AssetManager.at(assetManagerAddr);
        assert.ok(assetManager);

        await assetManager.addNewAsset(inventory, {from:managerOwners[0]});
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

        it('should revert if anyone but the assetManager tries to remove a reservation', async() => {
            try {
                const res = await assetManager.reserve(assetAddr, start, stop, {from:renter, value:1100});
                assert.ok(res);

                await asset.endReservation(reservation, {from:renter});
                assert.fail('Expected revert');
            } catch (error) {
                const revertFound = error.message.search('revert') >= 0;
                assert(revertFound, `Expected "revert", got ${error} instead`);
            }
        });

        it('should not let anyone but the assetManager change inventory', async() => {
            try {
                const newInventory = 5;
                await asset.changeInventory(newInventory, {from:attacker});
                assert.fail('Expected revert');
            } catch (error) {
                const revertFound = error.message.search('revert') >= 0;
                assert(revertFound, `Expected "revert", got ${error} instead`);
            }
        });

        it('should correctly track availability', async() => {
            let available = await asset.hasAvailability(start, stop);
            assert.equal(available, true);

            await assetManager.reserve(assetAddr, start, stop, {from:renter, value:1100});
            available = await asset.hasAvailability(start, stop);
            assert.equal(available, true);

            await assetManager.reserve(assetAddr, start, stop, {from:renter, value:1100});
            available = await asset.hasAvailability(start, stop);
            assert.equal(available, true);

            // total inventory equals 3, so after this reservation
            // should not allow for more availability
            await assetManager.reserve(assetAddr, start, stop, {from:renter, value:1100});
            available = await asset.hasAvailability(start, stop);
            assert.equal(available, false);
        });

        it('should correctly let a guest know they can access', async() => {

            // make an 'old' reservation
            // start = 1 in UNIX time
            // stop = 10 in UNIX time
            await assetManager.reserve(assetAddr, start, stop, {from:renter, value:1100});
            let access = await asset.canAccess(renter);
            assert.equal(access, false);

            // make a current reservation
            start = await asset.getTime();
            start = start.toNumber();
            stop = start + 10;

            await assetManager.reserve(assetAddr, start, stop, {from:renter, value:1100});
            access = await asset.canAccess(renter);
            assert.equal(access, true);
        });

        it('should get all reservations made by a single individual', async() => {
            await assetManager.reserve(assetAddr, start, stop, {from:renter, value:1100});
            await assetManager.reserve(assetAddr, start, stop, {from:renter, value:1100});
            await assetManager.reserve(assetAddr, start, stop, {from:renter, value:1100});

            const reservations = await asset.getReservations(renter);
            assert.equal(reservations.length, 3);
        });
    })
})
