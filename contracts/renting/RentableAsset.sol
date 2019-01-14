pragma solidity ^0.4.23;

contract RentableAsset {

    /**************************************************
    * Storage
    ***************************************************/
    address assetManager;
    uint256 inventory;

    ReservationKey[] reservations;

    struct ReservationKey {
        address reservation;
        address renter;
        uint256 start;
        uint256 stop;
    }

    /**************************************************
    * Constructor
    ***************************************************/
    constructor(uint256 _inventory) internal {
        assetManager = msg.sender;
        inventory = _inventory;
    }

    /**************************************************
    * Modifiers
    ***************************************************/
    modifier onlyManager() {
        require(msg.sender == assetManager);
        _;
    }

    /**************************************************
    * Functions
    ***************************************************/
    function addReservation(address _reservation, address _renter, uint256 _start, uint256 _stop)
        public
        onlyManager
    {
        /* TODO: maybe convert start and stop to minRentUnits? */
        ReservationKey memory _reservationKey = ReservationKey(
            _reservation,
            _renter,
            _start,
            _stop
        );

        reservations.push(_reservationKey);
    }

    function endReservation(address _reservation)
        public
        onlyManager
        returns (bool)
    {
        uint256 numReservations = reservations.length;
        ReservationKey memory _reservationKey;

        for (uint256 i=0; i<numReservations; i++) {
            _reservationKey = reservations[i];

            if (_reservationKey.reservation == _reservation) {
                _remove(i, reservations);
                return true;
            }
        }
        return false;
    }

    function changeInventory(uint256 _newInventory)
        external
        onlyManager
    {
        inventory = _newInventory;
    }

    function hasAvailability(uint256 _start, uint256 _stop)
        public
        view
        returns (bool _available)
    {
        uint256 alreadyReserved = 0;
        uint256 numReservations = reservations.length;

        ReservationKey memory _reservationKey;
        uint256 _resStart;
        uint256 _resStop;

        for (uint256 i=0; i<numReservations; i++) {
            _reservationKey = reservations[i];
            _resStart = _reservationKey.start;
            _resStop = _reservationKey.stop;

            // if ANY overlap in start and stop times,
            // increment alreadyReserved counter by one
            if (_start >= _resStart && _start < _resStop) {
                alreadyReserved += 1;
            } else if (_stop > _resStart && _stop <= _resStop) {
                alreadyReserved += 1;
            }
        }
        _available = alreadyReserved < inventory;
    }

    function canAccess(address _claimedRenter)
        public
        view
        returns (bool)
    {
        uint256 numReservations = reservations.length;

        ReservationKey memory _reservationKey;
        address _renter;

        for (uint256 i=0; i<numReservations; i++) {
            _reservationKey = reservations[i];
            _renter = _reservationKey.renter;

            // find if renter matches claimedRenter,
            // check if times are valid
            if (_renter == _claimedRenter &&
                _reservationKey.start <= now &&
                _reservationKey.stop > now) {

                return true;
            }
        }
        return false;
    }

    /* Is this necessary? */
    function getAssetManager() external view returns (address) {
        return assetManager;
    }

    function getNumReservations() external view returns (uint256) {
        return reservations.length;
    }

    function getReservations(address _renter)
        external
        view
        returns (address[])
    {
        uint256 numReservations = reservations.length;
        address[] memory _reservations = new address[](numReservations);

        ReservationKey memory _reservationKey;
        address _res;
        uint256 _count = 0;

        for (uint256 i=0; i<numReservations; i++) {
            _reservationKey = reservations[i];

            if (_renter == _reservationKey.renter) {
                _res = _reservationKey.reservation;
                _reservations[_count] = _res;
                _count ++;
            }
        }
        return _reservations;
    }

    // helper for testing
    function getTime() external view returns (uint256) {
        return now;
    }

    function _remove(uint256 _index, ReservationKey[] storage _reservations)
        internal
    {
        uint256 numReservations = _reservations.length;
        require(_index < numReservations && _index >= 0);

        for (uint256 i = _index; i<numReservations-1; i++){
            _reservations[i] = _reservations[i+1];
        }
        delete _reservations[numReservations-1];
        _reservations.length--;
    }
}
