pragma solidity ^0.4.23;

import 'openzeppelin-solidity/contracts/math/SafeMath.sol';
import '../helpers/PriceCalculator.sol';
import '../ownership/GroupOwned.sol';
import './RentableAsset.sol';
import './Reservation.sol';

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
    constructor (address[] _owners, address _priceCalc)

        GroupOwned(_owners)
        internal
    {
        priceCalculator = _priceCalc;
    }

    /**************************************************
    * Functions
    ***************************************************/

    /* main ERC809 functions */

    function reserve(address _assetAddr, uint256 _start, uint256 _stop)
        external
        payable
        returns (bool)
    {
        // things reserve needs to do:
        //   1. check dates are valid
        //   2. check assets are available to rent
        //   3. check enough money is sent
        //   4. make new reservation contract i.e. escrow
        //   5. send money to new contract
        //   6. call asset and record reservation

        // note, getReservationPrice() checks that the date range is valid
        uint256 _price = getReservationPrice(_assetAddr, _start, _stop);
        RentableAsset _asset = RentableAsset(_assetAddr);

        require(msg.value >= _price);
        require(_asset.hasAvailability(_start, _stop));

        address _renter = msg.sender;
        Reservation _reservation = new Reservation(_renter, _assetAddr, _start, _stop, _price);
        _asset.addReservation(_reservation, _renter, _start, _stop);

        address(_reservation).transfer(msg.value);
        return true;
    }

    function canAccess(address _assetAddr, address _renter)
        external
        view
        returns (bool)
    {
        RentableAsset _asset = RentableAsset(_assetAddr);
        bool _accessAllowed = _asset.canAccess(_renter);
        return _accessAllowed;
    }

    function endReservation(address _reservationAddr)
        external
        onlyAdmins
        returns (bool)
    {
        Reservation _reservation = Reservation(_reservationAddr);
        _reservation.endReservation();

        address _assetAddr = _reservation.getAssetAddress();
        RentableAsset _asset = RentableAsset(_assetAddr);
        _asset.endReservation(_reservationAddr);
        return true;
    }

    function cancelReservation(address _reservationAddr)
        external
        onlyAdmins
        returns (bool)
    {
        Reservation _reservation = Reservation(_reservationAddr);
        _reservation.cancelReservation();

        address _assetAddr = _reservation.getAssetAddress();
        RentableAsset _asset = RentableAsset(_assetAddr);
        _asset.endReservation(_reservationAddr);
        return true;
    }

    function hasAvailability(address _assetAddr, uint256 _start, uint256 _stop)
        public
        view
        returns (bool)
    {
        RentableAsset _asset = RentableAsset(_assetAddr);
        return _asset.hasAvailability(_start, _stop);
    }

    /* helpers */

    function changePriceCalculator(address _newCalc)
        public
        onlyOwners
        returns (bool)
    {
        return true;
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
}
