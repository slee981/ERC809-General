pragma solidity ^0.4.23;

import './renting/RentableAsset.sol';

contract Asset is RentableAsset {

    /**************************************************
    * Storage
    ***************************************************/

    /**************************************************
    * Constructor
    ***************************************************/
    constructor(uint256 _inventory, uint256 _minRentTime)
        RentableAsset(_inventory, _minRentTime)
        public {}

    /**************************************************
    * Functions
    ***************************************************/
    function changeInventory(uint256 _newInventory)
        external
        onlyManager
    {
        inventory = _newInventory;
    }
}
