pragma solidity ^0.4.23;

contract Reservation {

    event NewReservation(address renter, address asset);

    /**************************************************
    * Storage
    ***************************************************/
    address renter;
    address asset;
    address assetManager;

    uint256 start;
    uint256 stop;

    uint256 price;

    /**************************************************
    * Constructor
    ***************************************************/
    constructor(
        address _renter,
        address _asset,
        uint256 _start,
        uint256 _stop,
        uint256 _price
    )
        public
    {
        renter = _renter;
        asset = _asset;
        assetManager = msg.sender;
        start = _start;
        stop = _stop;
        price = _price;
    }

    /**************************************************
    * Functions
    ***************************************************/
    function () public payable {
        emit NewReservation(renter, asset);
    }

    function end() public {
        selfdestruct(assetManager);
    }
}
