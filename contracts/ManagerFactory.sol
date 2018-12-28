pragma solidity ^0.4.23;

import './AssetManager.sol';

contract ManagerFactory {

    /**************************************************
    * Storage
    ***************************************************/
    address[] assetManagers;

    /**************************************************
    * Functions
    ***************************************************/
    function createNewManager(
        address[] _owners,
        address _priceCalc,
        address _identity,
        address _wallet
    )
        external
    {
         address _manager = new AssetManager(_owners, _priceCalc, _identity, _wallet);
         assetManagers.push(_manager);
    }

    function getAssetManagers() external view returns (address[]) {
        return assetManagers;
    }
}
