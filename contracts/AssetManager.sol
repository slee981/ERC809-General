pragma solidity ^0.4.23;

import './renting/ERC809.sol';
import './Asset.sol';

contract AssetManager is ERC809 {

    /**************************************************
    * Events
    ***************************************************/

    /**************************************************
    * Storage
    ***************************************************/
    address identity;
    address wallet;
    address[] assets;

    /**************************************************
    * Constructor
    ***************************************************/
    constructor(
        address[] _owners,
        address _priceCalc,
        address _identity,
        address _wallet
    )
        ERC809(_owners, _priceCalc)
        public
    {
        identity = _identity;
        wallet = _wallet;
    }

    /**************************************************
    * Functions
    ***************************************************/

    function addNewAsset(uint256 _inventory, uint256 _minRentTime)
        public
        onlyOwners
    {
        address _newAsset = new Asset(_inventory, _minRentTime);
        assets.push(_newAsset);
    }

    function getAssets() external view returns (address[]) {
        return assets;
    }

    function getWallet() external view returns (address) {
        return wallet;
    }

    function getIdentity() external view returns (address) {
        return identity;
    }
}
