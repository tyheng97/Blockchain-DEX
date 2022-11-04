require("babel-register");
require("babel-polyfill");

module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "*", // Match any network id
      gas: 6721975,
      gasPrice: 25000000000,
    },
  },
  contracts_directory: "./src/contracts/",
  contracts_build_directory: "./src/abis/",
  compilers: {
    solc: {
      version: "0.6.8",
      optimizer: {
        enabled: true,
        runs: 200,
      },
      evmVersion: "petersburg",
    },
  },
};
