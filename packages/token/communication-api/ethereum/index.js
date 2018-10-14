import * as truffleContract from 'truffle-contract'
import * as abiDecoder from './lib/abi-decoder'

// const provider = new window.Web3.providers.HttpProvider("http://localhost:8545")

// window.web3 = new window.Web3(provider)


export let state = {
    fromAddress: null,
    toAddress: null,
    contracts: {
        EternalStorage: {
            contract: null,
            deployed: null,
            meta: require(__dirname + '/../../../smart-contracts/ethereum/build/contracts/EternalStorage.json'),
            address: null
        },
        Token: {
            contract: null,
            deployed: null,
            meta: require(__dirname + '/../../../smart-contracts/ethereum/build/contracts/Token.json'),
            address: null
        },
        TokenDelegate: {
            contract: null,
            deployed: null,
            meta: require(__dirname + '/../../../smart-contracts/ethereum/build/contracts/TokenDelegate.json'),
            address: null
        }
    }
}

const buildContract = (meta, options) => {
    const contract = truffleContract(meta)
    contract.setProvider(provider)

    contract.defaults({
        from: options.from,
        gas: options.gas
    })

    contract.setNetwork('*')

    // dirty hack for web3@1.0.0 support for localhost testrpc, see https://github.com/trufflesuite/truffle-contract/issues/56#issuecomment-331084530
    if (typeof contract.currentProvider.sendAsync !== 'function') {
        contract.currentProvider.sendAsync = function () {
            return contract.currentProvider.send.apply(contract.currentProvider, arguments)
        }
    }

    return contract
}

export const init = (fromAddress, toAddress) => {
    state.fromAddress = fromAddress
    state.toAddress = toAddress
}

export const setContractAddress = async (contractName, address) => {
    console.log('[Token] Setting contract address for: ' + contractName + ' to ' + address)

    return await new Promise((resolve, reject) => {
        const contract = state.contracts[contractName].contract = buildContract(state.contracts[contractName].meta, {
            from: state.fromAddress,
            gas: 6500000
        })

        contract.at(address).then((deployed) => {
            state.contracts[contractName].deployed = deployed
            state.contracts[contractName].address = deployed.address

            resolve(deployed)
        }).catch(reject)
    })
}

export const deployContract = async (contractName, links, params) => {
    console.log('[Token] Deploying contract for: ' + contractName)

    const contract = state.contracts[contractName].contract = buildContract(state.contracts[contractName].meta, {
        from: state.fromAddress,
        gas: 6500000
    })

    if (!links) {
        links = []
    }

    //let data = meta.bytecode

    for (let i in links) {
        let link = links[i]

        contract.link(link.name, link.address)

        //data = data.replace(new RegExp('__' + link.name + '_+', 'g'), link.address.replace('0x', ''))
    }

    return await new Promise((resolve) => {
        contract.new(...params).then((deployed) => {
            state.contracts[contractName].deployed = deployed

            resolve(deployed)
        })
    })
}

export const call = async (contractName, methodName, params) => {
    console.log('Calling ' + contractName + '.' + methodName + ' with params: ', params)

    if (contractName === 'test' && methodName === 'test') {

    } else {
        return await new Promise((resolve) => {
            const data = state.contracts[contractName].deployed.methods[methodName]
                .apply(null, params)
                .call({ from: state.fromAddress, gas: 3000000 }, (err, res) => {
                    if (err) throw err
                    resolve(res)
                })
        })
    }
}
