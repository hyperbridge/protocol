import * as abiDecoder from '../lib/abi-decoder'


window.web3 = new window.Web3(new window.Web3.providers.HttpProvider("http://localhost:8545"))


class Marketplace {
    constructor() {
    }

    init(contractMeta, contractAddress, fromAddress, toAddress) {
        console.log("Initializing Marketplace contract", arguments)
        
        //web3.setProvider(new web3.providers.HttpProvider("https://ropsten.infura.io/XXXXXX"))
        this.contractMeta = contractMeta
        this.contractAddress = contractAddress
        this.fromAddress = fromAddress
        this.toAddress = toAddress
        this.nonce = 0
        this.contract = new web3.eth.Contract(this.contractMeta.abi, this.contractAddress)
    }

    async createProduct({ name, version, category, files, checksum, permissions }) {
        console.log('Calling Marketplace.createProduct: ', arguments)

        return await new Promise((resolve) => {
            this.contract.methods
                .submitAppForReview(name, web3.utils.asciiToHex(version), category, files, checksum, permissions)
                .send({ from: this.fromAddress, gas: 3000000 })
                .on('receipt', (receipt) => {
                    resolve(receipt.events.AppSubmitted.returnValues.id)
                })
        })
    }

    async updateProduct({ id, name, version, category, files, checksum, permissions }) {
        console.log('Calling Marketplace.updateProduct: ', arguments)

        return await new Promise((resolve) => {
            this.contract.methods
                .submitVersionForReview(id, web3.utils.asciiToHex(version), files, checksum, permissions)
                .send({ from: this.fromAddress, gas: 3000000 })
                .on('receipt', (receipt) => {
                    resolve(receipt.events.VersionSubmitted.returnValues.app_id)
                })
        })
    }

    async voteForApp(id, version, vote) {
        console.log('Calling Marketplace.voteForApp with arguments: ', arguments)

        return await new Promise((resolve) => {
            this.contract.methods
                .voteForApp(id, web3.utils.asciiToHex(version), vote)
                .send({ from: this.fromAddress, gas: 3000000 })
                .on('receipt', (receipt) => {
                    resolve()
                })
        })
    }

    async updateAppVotes(id, version) {
        console.log('Calling Marketplace.updateAppVotes with arguments: ', arguments)

        return await new Promise((resolve) => {
            this.contract.methods
                .updateAppVotes(id, web3.utils.asciiToHex(version))
                .send({ from: this.fromAddress, gas: 3000000 })
                .on('receipt', (receipt) => {
                    resolve()
                })
        })
    }

    async listApps(page, offset) {
        console.log('Calling Marketplace.listApps with arguments: ', arguments)

        return await new Promise((resolve) => {
            const data = this.contract.methods
                .listApps(page, offset)
                .call({ from: this.fromAddress, gas: 3000000 }, (err, res) => {
                    if (err) throw err
                    resolve(res)
                })
        })
    }

    async getApp(id) {
        console.log('Calling Marketplace.getApp with arguments: ', arguments)

        return await new Promise((resolve) => {
            const data = this.contract.methods
                .getLatestVersion(id)
                .call({ from: this.fromAddress, gas: 3000000 }, (err, res) => {
                    if (err) throw err
                    resolve(res)
                })
        })
    }

    getBalance() {
        return 0
    }
}

export default new Marketplace()