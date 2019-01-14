pragma solidity ^0.4.23;

import 'openzeppelin-solidity/contracts/math/SafeMath.sol';

contract Reservation {

    using SafeMath for uint256;

    /**************************************************
    * Events
    ***************************************************/
    event Deposit(uint256 amount);

    /**************************************************
    * Storage
    ***************************************************/
    address asset;

    address renter;
    address assetManager;

    uint256 start;
    uint256 stop;

    uint256 price;

    /**************************************************
    * Fallback
    ***************************************************/
    function () public payable {
        if (msg.value > 0) {
            emit Deposit(msg.value);
        }
    }

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
    * Modifiers
    ***************************************************/
    modifier onlyInContract() {
        address _sender = msg.sender;

        require(_sender == renter ||
                _sender == assetManager);
        _;
    }

    modifier onlyAssetManager() {
        require(msg.sender == assetManager);
        _;
    }

    /**************************************************
    * Functions
    ***************************************************/

    function endReservation()
        public
        onlyAssetManager
    {
        // do stuff
        selfdestruct(assetManager);
    }

    function cancelReservation()
        public
        onlyAssetManager
    {
        // do stuff
        selfdestruct(assetManager);
    }

    function getAssetManager() public view returns (address) {
        return assetManager;
    }

    function getAssetAddress() public view returns (address) {
        return asset;
    }
}
