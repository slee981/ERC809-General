pragma solidity ^0.4.23;

import 'openzeppelin-solidity/contracts/math/SafeMath.sol';
import '../helpers/PriceCalculator.sol';
import '../ownership/GroupOwned.sol';
import '../Asset.sol';
import '../Reservation.sol';

contract ERC809 is GroupOwned {

    using SafeMath for uint256;

    /**************************************************
    * Events
    ***************************************************/
    //event newReservation();

    /**************************************************
    * Storage
    ***************************************************/
    address priceCalculator;

    /**************************************************
    * Constructor
    ***************************************************/
    constructor (address[] _owners, address _priceCalc) GroupOwned(_owners) internal {
        priceCalculator = _priceCalc;
    }

    /**************************************************
    * Functions
    ***************************************************/

    function reserve(address _assetAddr, uint256 _start, uint256 _stop)
        external
        payable
        returns (bool)
    {
        // things reserve needs to do:
        //   1. check dates are valid
        //   2. check assets are available
        //   3. check enough money is sent
        //   4. make new reservation contract
        //   5. send money to new contract
        //   6. call asset and make reservation

        // note, getReservationPrice() checks that the date range is valid
        uint256 _price = getReservationPrice(_assetAddr, _start, _stop);
        Asset _asset = Asset(_assetAddr);

        require(msg.value >= _price);
        require(_asset.hasAvailability(_start, _stop));

        address _renter = msg.sender;
        Reservation _reservation = new Reservation(_renter, _assetAddr, _start, _stop, _price);
        _asset.addReservation(_reservation, _renter, _start, _stop);

        address(_reservation).transfer(msg.value);
    }

    function canAccess(address _assetAddr, address _renter)
        external
        view
        returns (bool)
    {
        Asset _asset = Asset(_assetAddr);
        bool _accessAllowed = _asset.canAccess(_renter);
        return _accessAllowed;
    }

    function hasAvailability(address _assetAddr, uint256 _start, uint256 _stop)
        public
        view
        returns (bool)
    {
        Asset _asset = Asset(_assetAddr);
        return _asset.hasAvailability(_start, _stop);
    }

    function getReservationPrice(address _assetAddr, uint256 _start, uint256 _stop)
        public
        view
        returns (uint256 _price)
    {
        require(_start < _stop);
        uint256 _duration = _stop.sub(_start);
        PriceCalculator _priceCalc = PriceCalculator(priceCalculator);
        _price = _priceCalc.getPrice(_assetAddr, _duration);
    }

    function changePriceCalculator(address _newCalc)
        external
        onlyOwners
        returns (bool)
    {
        return true;
    }

    /*
    function returnAccess(address _reservation)
        external
        returns (bool)
    {
        return true;
    }

    function cancelReservation(address _reservation) external returns (bool) {
        return true;
    }

    function hasAvailability(address[] _assetAddrs, uint256[] memory _starts, uint256[] memory _stops)
        public
        view
        returns (bool)
    {
        uint256 _numAssets = _assetAddrs.length;
        uint256 _numStarts = _starts.length;
        uint256 _numStops = _stops.length;
        require(_numAssets == _numStarts && _numStarts == _numStops);

        address _asset;
        uint256 _start;
        uint256 _stop;
        for (uint256 i=0; i<_numAssets; i++) {
            _asset = _assetAddrs[i];
            _start = _starts[i];
            _stops = _stops[i];
            if (!hasAvailability(_asset, _start, _stop)) {
                return false;
            }
        }
        return true;
    }
    */
}
