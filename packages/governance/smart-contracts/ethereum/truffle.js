var HDWalletProvider = require("truffle-hdwallet-provider");

var mnemonic = "candy maple cake sugar pudding cream honey rich smooth crumble sweet treat";

// Mainnet	test network	https://mainnet.infura.io/q0dsZEe9ohtOnGy8V0cT
// Ropsten	test network	https://ropsten.infura.io/q0dsZEe9ohtOnGy8V0cT
// INFURAnet	test network	https://infuranet.infura.io/q0dsZEe9ohtOnGy8V0cT
// Koven	test network	https://koven.infura.io/q0dsZEe9ohtOnGy8V0cT
// Rinkeby	test network	https://rinkeby.infura.io/q0dsZEe9ohtOnGy8V0cT
// IPFS	gateway	https://mainnet.infura.io/q0dsZEe9ohtOnGy8V0cT

module.exports = {
    contracts_build_directory: "./build",
    networks: {
        development: {
            host: "localhost",
            port: 8545,
            network_id: "*", // Match any network id
            //gas: 99999999999,
            from: "0x627306090abaB3A6e1400e9345bC60c78a8BEf57" // candy maple cake sugar pudding cream honey rich smooth crumble sweet treat
        },
        ropsten: {
            provider: function () {
                return new HDWalletProvider(mnemonic, "https://ropsten.infura.io/q0dsZEe9ohtOnGy8V0cT")
            },
            network_id: 3
        }
    },
    mocha: {
        useColors: true
    }
};
