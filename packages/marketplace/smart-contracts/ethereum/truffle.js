const HDWalletProvider = require("truffle-hdwallet-provider");
const mnemonic = "trigger badge lucky excuse hidden best february mother unhappy pioneer donate rug";

module.exports = {
    networks: {
        development: {
            host: "localhost",
            port: 8545,
            network_id: "*" // Match any network id
        },
        rinkeby: {
            provider: () => {
                return new HDWalletProvider(mnemonic, "https://rinkeby.infura.io/yChy4KdIzQOGuSXuzpib");
            },
            network_id: 3
        }
    }
};
