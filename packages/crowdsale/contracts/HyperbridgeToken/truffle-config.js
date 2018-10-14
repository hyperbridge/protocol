const HDWalletProvider = require("truffle-hdwallet-provider");
const mnemonic = "load machine oxygen defense unique rural bulk napkin congress any balcony cash";

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
