pragma solidity ^0.4.23;

contract PriceCalculator {

    /**************************************************
    * Storage
    ***************************************************/
    uint256 basePrice;

    /**************************************************
    * Constructor
    ***************************************************/
    constructor(uint256 _price) public {
        basePrice = _price;
    }

    /**************************************************
    * Functions
    ***************************************************/
    function getPrice(address _assetAddr, uint256 _duration)
        public
        view
        returns (uint256 _reservationPrice)
    {
        _reservationPrice = _duration * basePrice;
    }
}
