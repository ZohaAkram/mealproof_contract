const admin = artifacts.require('admin_manufacture');
module.exports = function (deployer) {
  deployer.deploy(admin);
};
