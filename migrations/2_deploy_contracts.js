var CryptoChatToken= artifacts.require("./CryptoChatToken.sol");

module.exports = function(deployer) {
  deployer.deploy(CryptoChatToken);
};
