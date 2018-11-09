import truffleContract from 'truffle-contract'
import * as abiDecoder from './lib/abi-decoder'

export let state = {
    provider: null,
    fromAddress: null,
    toAddress: null,
    contracts: {
        MarketplaceStorage: {
            contract: null,
            deployed: null,
            meta: require(__dirname + '/../../../smart-contracts/ethereum/build/contracts/MarketplaceStorage.json'),
            address: null
        },
        Administration: {
            contract: null,
            deployed: null,
            meta: require(__dirname + '/../../../smart-contracts/ethereum/build/contracts/Administration.json'),
            address: null,
            links: [
                {
                    name: 'MarketplaceStorage', address: null
                }
            ],
            params: [
                'MarketplaceStorage'
            ]
        },
        DeveloperStorageAccess: {
            contract: null,
            deployed: null,
            meta: require(__dirname + '/../../../smart-contracts/ethereum/build/contracts/DeveloperStorageAccess.json'),
            address: null
        },
        ProductStorageAccess: {
            contract: null,
            deployed: null,
            meta: require(__dirname + '/../../../smart-contracts/ethereum/build/contracts/ProductStorageAccess.json'),
            address: null
        },
        AdministrationStorageAccess: {
            contract: null,
            deployed: null,
            meta: require(__dirname + '/../../../smart-contracts/ethereum/build/contracts/AdministrationStorageAccess.json'),
            address: null
        },
        Bytes32Utils: {
            contract: null,
            deployed: null,
            meta: require(__dirname + '/../../../smart-contracts/ethereum/build/contracts/Bytes32Utils.json'),
            address: null
        },
        BytesUtils: {
            contract: null,
            deployed: null,
            meta: require(__dirname + '/../../../smart-contracts/ethereum/build/contracts/BytesUtils.json'),
            address: null
        },
        StringUtils: {
            contract: null,
            deployed: null,
            meta: require(__dirname + '/../../../smart-contracts/ethereum/build/contracts/StringUtils.json'),
            address: null
        },
        ProductRegistration: {
            contract: null,
            deployed: null,
            meta: require(__dirname + '/../../../smart-contracts/ethereum/build/contracts/ProductRegistration.json'),
            address: null,
            links: [
                {
                    name: 'BytesUtils', address: null
                },
                {
                    name: 'MarketplaceStorage', address: null
                }
            ],
            params: [
                'MarketplaceStorage'
            ]
        },
        ProductLanguageSupport: {
            contract: null,
            deployed: null,
            meta: require(__dirname + '/../../../smart-contracts/ethereum/build/contracts/ProductLanguageSupport.json'),
            address: null,
            links: [
                {
                    name: 'MarketplaceStorage', address: null
                }
            ],
            params: [
                'MarketplaceStorage'
            ]
        },
        ProductSystemRequirement: {
            contract: null,
            deployed: null,
            meta: require(__dirname + '/../../../smart-contracts/ethereum/build/contracts/ProductSystemRequirement.json'),
            address: null,
            links: [
                {
                    name: 'MarketplaceStorage', address: null
                }
            ],
            params: [
                'MarketplaceStorage'
            ]
        },
        ProductPricePlan: {
            contract: null,
            deployed: null,
            meta: require(__dirname + '/../../../smart-contracts/ethereum/build/contracts/ProductPricePlan.json'),
            address: null,
            links: [
                {
                    name: 'MarketplaceStorage', address: null
                }
            ],
            params: [
                'MarketplaceStorage'
            ]
        },
        ProductVersion: {
            contract: null,
            deployed: null,
            meta: require(__dirname + '/../../../smart-contracts/ethereum/build/contracts/ProductVersion.json'),
            address: null,
            links: [
                {
                    name: 'MarketplaceStorage', address: null
                }
            ],
            params: [
                'MarketplaceStorage'
            ]
        },
        ProductVersionVoting: {
            contract: null,
            deployed: null,
            meta: require(__dirname + '/../../../smart-contracts/ethereum/build/contracts/ProductVersionVoting.json'),
            address: null,
            links: [
                {
                    name: 'MarketplaceStorage', address: null
                }
            ],
            params: [
                'MarketplaceStorage'
            ]
        },
        ProductPurchase: {
            contract: null,
            deployed: null,
            meta: require(__dirname + '/../../../smart-contracts/ethereum/build/contracts/ProductPurchase.json'),
            address: null,
            links: [
                {
                    name: 'StringUtils', address: null
                },
                {
                    name: 'MarketplaceStorage', address: null
                }
            ],
            params: [
                'MarketplaceStorage'
            ]
        },
        Developer: {
            contract: null,
            deployed: null,
            meta: require(__dirname + '/../../../smart-contracts/ethereum/build/contracts/Developer.json'),
            address: null,
            links: [
                {
                    name: 'DeveloperStorageAccess', address: null
                },
                {
                    name: 'MarketplaceStorage', address: null
                }
            ],
            params: [
                'MarketplaceStorage'
            ]
        },
    }
}

const buildContract = (meta, options) => {
    const contract = truffleContract(meta)
    contract.setProvider(state.provider)

    contract.defaults({
        from: options.from,
        gas: options.gas,
        gasPrice: options.gasPrice,
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

export const init = (provider, fromAddress, toAddress) => {
    state.provider = provider
    state.fromAddress = fromAddress
    state.toAddress = toAddress
}

export const setContractAddress = async (contractName, address) => {
    console.log('[MarketplaceProtocol] Setting contract address for: ' + contractName + ' to ' + address)

    return await new Promise((resolve, reject) => {
        const contract = state.contracts[contractName].contract = buildContract(state.contracts[contractName].meta, {
            from: state.fromAddress,
            gas: 6500000,
            gasPrice: 10e9
        })

        contract.at(address).then((deployed) => {
            state.contracts[contractName].deployed = deployed
            state.contracts[contractName].address = deployed.address

            resolve(deployed)
        }).catch(reject)
    })
}

export const deployContract = async (contractName, links, params) => {
    console.log('[MarketplaceProtocol] Deploying contract for: ' + contractName)

    const contract = state.contracts[contractName].contract = buildContract(state.contracts[contractName].meta, {
        from: state.fromAddress,
        gas: 6500000,
        gasPrice: 10e9
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

    return await new Promise((resolve, reject) => {
        contract.new(...params).then((deployed) => {
            state.contracts[contractName].deployed = deployed
            state.contracts[contractName].address = deployed.address

            resolve(deployed)
        }).catch(reject)
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
