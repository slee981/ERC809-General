pragma solidity ^0.4.23;

contract GroupOwned {

    /**************************************************
    * Storage
    ***************************************************/
    mapping (address => bool) private isOwner;
    mapping (address => bool) private isAdmin;

    /**************************************************
    * Constructor
    ***************************************************/
    constructor (address[] _owners) internal {
        uint256 numOwners = _owners.length;
        address _addr;

        for(uint i=0; i<numOwners; i++) {
            _addr = _owners[i];
            require(!isOwner[_addr] && _addr != address(0));
            isOwner[_addr] = true;
        }
    }

    /**************************************************
    * Modifiers
    ***************************************************/
    modifier onlyOwners() {
         require(isOwner[msg.sender]);
         _;
    }

    modifier onlyAdmins() {
        require(isAdmin[msg.sender] || isOwner[msg.sender]);
        _;
    }

    /**************************************************
    * Functions
    ***************************************************/

    /* external, restricted access */

    function addOwners(address[] _owners) external onlyOwners {
        uint256 numOwners = _owners.length;
        address _addr;

        for(uint i=0; i<numOwners; i++) {
            _addr = _owners[i];
            require(!isOwner[_addr] && _addr != address(0));
            isOwner[_addr] = true;
        }
    }

    function addAdmins(address[] _admins) external onlyOwners {
        uint256 numAdmins = _admins.length;
        address _addr;

        for(uint i=0; i<numAdmins; i++) {
            _addr = _admins[i];
            require(!isAdmin[_addr] && _addr != address(0));
            isAdmin[_addr] = true;
        }
    }

    function removeOwners(address[] _owners) external onlyOwners {
        uint256 numOwners = _owners.length;
        address _addr;

        for(uint i=0; i<numOwners; i++) {
            _addr = _owners[i];
            require(isOwner[_addr] && _addr != address(0));
            isOwner[_addr] = false;
        }
    }

    function removeAdmins(address[] _admins) external onlyOwners {
        uint256 numAdmins = _admins.length;
        address _addr;

        for(uint i=0; i<numAdmins; i++) {
            _addr = _admins[i];
            require(isAdmin[_addr] && _addr != address(0));
            isAdmin[_addr] = false;
        }
    }

    /* external view */

    function owner(address _addr) external view returns (bool) {
        return isOwner[_addr];
    }

    function admin(address _addr) external view returns (bool) {
        return isAdmin[_addr];
    }
}
