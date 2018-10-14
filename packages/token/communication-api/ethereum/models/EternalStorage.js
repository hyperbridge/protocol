import * as abiDecoder from '../lib/abi-decoder'


window.web3 = new window.Web3(new window.Web3.providers.HttpProvider("http://localhost:8545"))


class EternalStorage {
    constructor() {
    }

    init(contractMeta, contractAddress, fromAddress, toAddress) {
        console.log("Initializing EternalStorage contract", arguments)

        //web3.setProvider(new web3.providers.HttpProvider("https://ropsten.infura.io/XXXXXX"))
        this.contractMeta = contractMeta
        this.contractAddress = contractAddress
        this.fromAddress = fromAddress
        this.toAddress = toAddress
        this.nonce = 0
        this.contract = new web3.eth.Contract(this.contractMeta.abi, this.contractAddress)
    }


    getBalance() {
        return 0
    }
}

export default new EternalStorage()