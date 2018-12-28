var ManagerFactory = artifacts.require('./ManagerFactory.sol');

// rinkeby addresses
let steve = "0xBAE2175539624c861920C9566486DA79b582D362";

module.exports = function(deployer, networks) {
  deployer.deploy(ManagerFactory, [steve], steve);
};
