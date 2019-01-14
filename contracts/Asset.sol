pragma solidity ^0.4.23;

import './renting/RentableAsset.sol';

contract Asset is RentableAsset {

    /**************************************************
    * Storage
    ***************************************************/

    /**************************************************
    * Constructor
    ***************************************************/
    constructor(uint256 _inventory)
        RentableAsset(_inventory)
        public {}

    /**************************************************
    * Functions
    ***************************************************/
}
