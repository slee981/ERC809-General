let ManagerFactory = artifacts.require('ManagerFactory');
let PriceCalculator = artifacts.require('PriceCalculator');
let AssetManager = artifacts.require('AssetManager');
let Reservation = artifacts.require('Reservation');
let Asset = artifacts.require('Asset');

contract('AssetManager', (accounts) => {

    // constructor args for manager
    const managerWallet = accounts[0];
    const managerIdentity = accounts[1];
    const managerOwners = [accounts[2], accounts[3]];

    // constructor arg for asset
    const inventory = 3;
    const pricePerSecond = 100;

    // fake address to play attacker
    const attacker = accounts[4];
    const renter1 = attacker;
    const renter2 = accounts[5];
    const renter3 = accounts[6];

    // new owner address to add and remove
    const newWorker1 = accounts[5];
    const newWorker2 = accounts[6];

    let factory;
    let managers;
    let assetManager;
    let priceCalc;
    let priceCalcAddr;

    beforeEach('setup Factory and AssetManager', async function() {
        factory = await ManagerFactory.new();
        assert.ok(factory);
        priceCalc = await PriceCalculator.new(pricePerSecond);
        priceCalcAddr = priceCalc.contract.address
        if (priceCalcAddr == undefined) {
          priceCalcAddr = priceCalc.contract._address;
        }
        assert.ok(priceCalc);
        const result = await factory.createNewManager(managerOwners, priceCalcAddr, managerIdentity, managerWallet);
        assert.ok(result);
        managers = await factory.getAssetManagers();
        assetManager = await AssetManager.at(managers[0]);
        assert.ok(assetManager);
    })

    describe('Check GroupOwned', () => {
        it('should have the correct owners', async() => {
            let _isOwner1 = await assetManager.owner(managerOwners[0]);
            let _isOwner2 = await assetManager.owner(managerOwners[1]);
            assert.equal(_isOwner1, true, 'Error with first owner');
            assert.equal(_isOwner2, true, 'Error with second owner')
        });

        it('should not report false owners', async() => {
            let _isNotOwner = await assetManager.owner(attacker);
            assert.equal(_isNotOwner, false);
        });

        it('should let an owner add and remove an owner', async() => {
            await assetManager.addOwners([newWorker1], {from:managerOwners[0]});
            let _isNewWorker = await assetManager.owner(newWorker1);
            assert.equal(_isNewWorker, true, 'Did not add new owner');

            await assetManager.removeOwners([newWorker1], {from:managerOwners[0]});
            _isNewWorker = await assetManager.owner(newWorker1);
            assert.equal(_isNewWorker, false, 'Did not remove new owner');
        });

        it('should let an owner add and remove multiple owners at once', async() => {
            await assetManager.addOwners([newWorker1, newWorker2], {from:managerOwners[1]});
            let _isNewWorker1 = await assetManager.owner(newWorker1);
            let _isNewWorker2 = await assetManager.owner(newWorker2);
            assert.equal(_isNewWorker1, true, 'Did not add new owner 1');
            assert.equal(_isNewWorker1, true, 'Did not add new owner 2');

            await assetManager.removeOwners([newWorker1, newWorker2], {from:managerOwners[1]});
            _isNewWorker1 = await assetManager.owner(newWorker1);
            _isNewWorker2 = await assetManager.owner(newWorker2);
            assert.equal(_isNewWorker1, false, 'Did not add new owner 1');
            assert.equal(_isNewWorker1, false, 'Did not add new owner 2');
        });

        it('should revert when a non owner tries to add an owner', async() => {
            try {
                const attackerIsOwner = await assetManager.owner(attacker);
                assert.equal(attackerIsOwner, false, 'Attacker is an owner');
                await assetManager.addOwners([newWorker1], {from:attacker});
                assert.fail('Expected revert');
            } catch (error) {
                const revertFound = error.message.search('revert') >= 0;
                assert(revertFound, `Expected "revert", got ${error} instead`);
            }
        });

        it('should revert when a non owner tries to remove an owner', async() => {
            try {
                await assetManager.removeOwners([managerOwners[0]], {from:attacker});
                assert.fail('Expected revert');
            } catch (error) {
                const revertFound = error.message.search('revert') >= 0;
                assert(revertFound, `Expected "revert", got ${error} instead`);
            }
        })

        it('should let an owner add and remove an admin', async() => {
            await assetManager.addAdmins([newWorker1], {from:managerOwners[0]});
            let _isNewWorker = await assetManager.admin(newWorker1);
            assert.equal(_isNewWorker, true, 'Did not add new owner');

            await assetManager.removeAdmins([newWorker1], {from:managerOwners[0]});
            _isNewWorker = await assetManager.admin(newWorker1);
            assert.equal(_isNewWorker, false, 'Did not remove new owner');
        });

        it('should let an owner add and remove multiple admins at once', async() => {
            await assetManager.addAdmins([newWorker1, newWorker2], {from:managerOwners[1]});
            let _isNewWorker1 = await assetManager.admin(newWorker1);
            let _isNewWorker2 = await assetManager.admin(newWorker2);
            assert.equal(_isNewWorker1, true, 'Did not add new owner 1');
            assert.equal(_isNewWorker1, true, 'Did not add new owner 2');

            await assetManager.removeAdmins([newWorker1, newWorker2], {from:managerOwners[1]});
            _isNewWorker1 = await assetManager.admin(newWorker1);
            _isNewWorker2 = await assetManager.admin(newWorker2);
            assert.equal(_isNewWorker1, false, 'Did not add new owner 1');
            assert.equal(_isNewWorker1, false, 'Did not add new owner 2');
        });

        it('should revert when a non owner tries to add an admin', async() => {
            try {
                const attackerIsOwner = await assetManager.owner(attacker);
                assert.equal(attackerIsOwner, false, 'Attacker is an owner');
                await assetManager.addAdmins([newWorker1], {from:attacker});
                assert.fail('Expected revert');
            } catch (error) {
                const revertFound = error.message.search('revert') >= 0;
                assert(revertFound, `Expected "revert", got ${error} instead`);
            }
        });

        it('should revert when a non owner tries to remove an admin', async() => {
            try {
                await assetManager.removeAdmins([managerOwners[0]], {from:attacker});
                assert.fail('Expected revert');
            } catch (error) {
                const revertFound = error.message.search('revert') >= 0;
                assert(revertFound, `Expected "revert", got ${error} instead`);
            }
        })
    })

    describe('Check AssetManager', () => {
        it('should have the correct wallet', async() => {
            let wallet = await assetManager.getWallet();
            assert.equal(wallet, managerWallet);
        });

        it('should have the correct identity', async() => {
            let id = await assetManager.getID();
            assert.equal(id, managerIdentity);
        });

        it('should let an owner add a new asset', async() => {
            const initialAssets = await assetManager.getAssets();
            assert.equal(initialAssets.length, 0, 'error with initial assets');
            await assetManager.addNewAsset(inventory, {from:managerOwners[0]});
            const newAssets = await assetManager.getAssets();
            assert.equal(newAssets.length, 1, 'did not add asset');
        });

        it('should not let a non-owner add a new asset', async() => {
            try {
                await assetManager.addNewAsset(inventory, {from:attacker});
                assert.fail('Expected revert');
            } catch (error) {
                const revertFound = error.message.search('revert') >= 0;
                assert(revertFound, `Expected "revert", got ${error} instead`);
            }
        })
    })

    describe('Check ERC809', () => {

        const renter = accounts[5];
        let assetAddr1;
        let assetAddr2;
        let start;
        let stop;
        let asset;

        beforeEach('make assets', async() => {

            // let manager 1 add inventory
            await assetManager.addNewAsset(inventory, {from:managerOwners[0]});

            // let manager 2 add inventory
            await assetManager.addNewAsset(2, {from:managerOwners[1]});

            const newAssets = await assetManager.getAssets();
            assetAddr1 = newAssets[0];
            assetAddr2 = newAssets[1];

            asset = await Asset.at(assetAddr1);
            start = await asset.getTime();
            start = Number(start);
            stop = Number(start) + 100;
        })

        it('should let anyone with enough money make a reservation', async() => {
            const res = await assetManager.reserve(assetAddr1, start, stop, {from:renter, value:12000});
            assert.ok(res);
        })

        it('should not let a renter make a reservation if they do not send enough money', async() => {
            try {
                const res = await assetManager.reserve(assetAddr1, start, stop, {from:renter, value:800});
                assert.fail('Expected revert');
            } catch (error) {
                const revertFound = error.message.search('revert') >= 0;
                assert(revertFound, `Expected "revert", got ${error} instead`);
            }
        })

        it('should tell you if an asset in unavailable', async() => {
            await assetManager.reserve(assetAddr1, start, stop, {from:renter, value:12000});
            await assetManager.reserve(assetAddr1, start, stop, {from:renter, value:12000});
            await assetManager.reserve(assetAddr1, start, stop, {from:renter, value:12000});
            const available = await assetManager.hasAvailability(assetAddr1, start, stop);
            assert.equal(available, false);
        })

        it('should revert if someone tries to "over reserve" an asset', async() => {
            try {
                await assetManager.reserve(assetAddr1, start, stop, {from:renter, value:11000});
                await assetManager.reserve(assetAddr1, start, stop, {from:renter, value:11000});
                await assetManager.reserve(assetAddr1, start, stop, {from:renter, value:11000});
                await assetManager.reserve(assetAddr1, start, stop, {from:renter, value:11000});
                assert.fail('Expected revert');
            } catch (error) {
                const revertFound = error.message.search('revert') >= 0;
                assert(revertFound, `Expected "revert", got ${error} instead`);
            }
        })

        it('should let a valid renter know if they can access', async() => {
            await assetManager.reserve(assetAddr1, start, stop, {from:renter, value:11000});
            const validRenter_manager = await assetManager.canAccess(assetAddr1, renter);
            const validRenter_asset = await asset.canAccess(renter);
            assert.equal(validRenter_manager, true, 'Error with manager');
            assert.equal(validRenter_asset, true, 'Error with asset');
        })

        it('should not let an invalid renter know they can access', async() => {
            // change the start and stop time to try and
            // access in the wrong time period
            start = 1;
            stop = 100;
            await assetManager.reserve(assetAddr1, start, stop, {from:renter, value:11000});
            const validRenter_asset = await asset.canAccess(renter);
            const validRenter_manager = await assetManager.canAccess(assetAddr1, renter);
            assert.equal(validRenter_manager, false);
            assert.equal(validRenter_asset, false);
        })

        it('should let the account manager end the reservation', async() => {
            await assetManager.reserve(assetAddr1, start, stop, {from:renter1, value:12000});
            await assetManager.reserve(assetAddr1, start, stop, {from:renter2, value:12000});
            await assetManager.reserve(assetAddr1, start, stop, {from:renter3, value:12000});

            let reservations = await asset.getNumReservations();
            assert.equal(reservations.toNumber(), 3, 'Did not make proper reservations');

            const reservationToEnd = await asset.getReservations(renter1);
            await assetManager.endReservation(reservationToEnd[0], {from:managerOwners[0], gas:6000000});

            reservations = await asset.getNumReservations();
            assert.equal(reservations.toNumber(), 2, 'Did not end reservation');
        })

        it('should not let anyone else end the reservation', async() => {
            try {
                await assetManager.reserve(assetAddr1, start, stop, {from:renter1, value:12000});
                await assetManager.reserve(assetAddr1, start, stop, {from:renter2, value:12000});
                await assetManager.reserve(assetAddr1, start, stop, {from:renter3, value:12000});

                let reservations = await asset.getNumReservations();
                assert.equal(reservations.toNumber(), 3, 'Did not make proper reservations');

                const reservationToEnd = await asset.getReservations(renter1);
                await assetManager.endReservation(reservationToEnd[0], {from:attacker, gas:6000000});
                assert.fail('Expected revert');
            } catch (error) {
                const revertFound = error.message.search('revert') >= 0;
                assert(revertFound, `Expected "revert", got ${error} instead`);
            }
        });

        it('should let the account manager cancel the reservation', async() => {
            await assetManager.reserve(assetAddr1, start, stop, {from:renter1, value:12000});
            await assetManager.reserve(assetAddr1, start, stop, {from:renter2, value:12000});
            await assetManager.reserve(assetAddr1, start, stop, {from:renter3, value:12000});

            let reservations = await asset.getNumReservations();
            assert.equal(reservations.toNumber(), 3, 'Did not make proper reservations');

            const reservationToEnd = await asset.getReservations(renter1);
            await assetManager.cancelReservation(reservationToEnd[0], {from:managerOwners[0], gas:6000000});

            reservations = await asset.getNumReservations();
            assert.equal(reservations.toNumber(), 2, 'Did not end reservation');
        })
    })
})
