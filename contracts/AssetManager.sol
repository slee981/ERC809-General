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

    function addNewAsset(uint256 _inventory)
        external
        onlyOwners
    {
        address _newAsset = new Asset(_inventory);
        assets.push(_newAsset);
    }

    function changeWallet(address _newWalletAddr)
        external
        onlyOwners
    {
        wallet = _newWalletAddr;
    }

    function changeID(address _newID)
        external
        onlyOwners
    {
        identity = _newID;
    }

    function getAssets() external view returns (address[]) {
        return assets;
    }

    function getWallet() external view returns (address) {
        return wallet;
    }

    function getID() external view returns (address) {
        return identity;
    }
}
