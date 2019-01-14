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

    /*
       placeholders for more complex functions that
       would likely depend on the asset, and may
       include some minimum time etc.
    */

    function getPrice(address _assetAddr, uint256 _duration)
        public
        view
        returns (uint256 _reservationPrice)
    {
        _reservationPrice = _duration * basePrice;
    }

    function getPrice(address[] _assetAddrs, uint256[] _durations)
        public
        view
        returns (uint256 _reservationPrice)
    {
        uint256 _numItems = _assetAddrs.length;
        require(_numItems == _durations.length);

        _reservationPrice = 0;

        for (uint256 i=0; i<_numItems; i++) {
            _reservationPrice += _durations[i] * basePrice;
        }
    }
}
