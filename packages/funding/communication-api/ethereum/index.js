import truffleContract from 'truffle-contract'
import * as abiDecoder from './lib/abi-decoder'

// const provider = new window.Web3.providers.HttpProvider("http://localhost:8545")

// window.web3 = new window.Web3(provider)


export let state = {
    provider: null,
    fromAddress: null,
    toAddress: null,
    contracts: {
        FundingStorage: {
            contract: null,
            deployed: null,
            meta: require(__dirname + '/../../../smart-contracts/ethereum/build/contracts/FundingStorage.json'),
            address: null
        },
        DeveloperStorageAccess: {
            contract: null,
            deployed: null,
            meta: require(__dirname + '/../../../smart-contracts/ethereum/build/contracts/DeveloperStorageAccess.json'),
            address: null
        },
        ProjectStorageAccess: {
            contract: null,
            deployed: null,
            meta: require(__dirname + '/../../../smart-contracts/ethereum/build/contracts/ProjectStorageAccess.json'),
            address: null
        },
        ContributionStorageAccess: {
            contract: null,
            deployed: null,
            meta: require(__dirname + '/../../../smart-contracts/ethereum/build/contracts/ContributionStorageAccess.json'),
            address: null
        },
        FundingVault: {
            contract: null,
            deployed: null,
            meta: require(__dirname + '/../../../smart-contracts/ethereum/build/contracts/FundingVault.json'),
            address: null,
            params: [
                'FundingStorage'
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
                }
            ],
            params: [
                'FundingStorage',
                false
            ]
        },
        Contribution: {
            contract: null,
            deployed: null,
            meta: require(__dirname + '/../../../smart-contracts/ethereum/build/contracts/Contribution.json'),
            address: null,
            links: [
                {
                    name: 'ContributionStorageAccess', address: null
                },
                {
                    name: 'ProjectStorageAccess', address: null
                }
            ],
            params: [
                'FundingStorage',
                false
            ]
        },
        ProjectTimeline: {
            contract: null,
            deployed: null,
            meta: require(__dirname + '/../../../smart-contracts/ethereum/build/contracts/ProjectTimeline.json'),
            address: null,
            params: [
                'FundingStorage',
                false
            ]
        },
        ProjectTimelineHelpersLibrary: {
            contract: null,
            deployed: null,
            meta: require(__dirname + '/../../../smart-contracts/ethereum/build/contracts/ProjectTimelineHelpersLibrary.json'),
            address: null,
            links: [
                {
                    name: 'ProjectStorageAccess', address: null
                }
            ],
            params: [
                'FundingStorage',
                false
            ]
        },
        ProjectTimelineProposal: {
            contract: null,
            deployed: null,
            meta: require(__dirname + '/../../../smart-contracts/ethereum/build/contracts/ProjectTimelineProposal.json'),
            address: null,
            links: [
                {
                    name: 'ProjectTimelineHelpersLibrary', address: null
                }
            ],
            params: [
                'FundingStorage',
                false
            ]
        },
        ProjectContributionTierHelpersLibrary: {
            contract: null,
            deployed: null,
            meta: require(__dirname + '/../../../smart-contracts/ethereum/build/contracts/ProjectContributionTierHelpersLibrary.json'),
            address: null,
            links: [
                {
                    name: 'ProjectStorageAccess', address: null
                }
            ]
        },
        ProjectMilestoneCompletion: {
            contract: null,
            deployed: null,
            meta: require(__dirname + '/../../../smart-contracts/ethereum/build/contracts/ProjectMilestoneCompletion.json'),
            address: null,
            links: [
                {
                    name: 'ProjectTimelineHelpersLibrary', address: null
                }
            ],
            params: [
                'FundingStorage',
                false
            ]
        },
        ProjectRegistrationHelpersLibrary: {
            contract: null,
            deployed: null,
            meta: require(__dirname + '/../../../smart-contracts/ethereum/build/contracts/ProjectRegistrationHelpersLibrary.json'),
            address: null,
            links: [
                {
                    name: 'ProjectStorageAccess', address: null
                }
            ]
        },
        ProjectRegistration: {
            contract: null,
            deployed: null,
            meta: require(__dirname + '/../../../smart-contracts/ethereum/build/contracts/ProjectRegistration.json'),
            address: null,
            links: [
                {
                    name: 'FundingStorage', address: null
                },
                {
                    name: 'ProjectRegistrationHelpersLibrary', address: null
                },
                {
                    name: 'ProjectTimelineHelpersLibrary', address: null
                },
                {
                    name: 'ProjectContributionTierHelpersLibrary', address: null
                }
            ],
            params: [
                'FundingStorage',
                false
            ]
        },
        CurationStorageAccess: {
            contract: null,
            deployed: null,
            meta: require(__dirname + '/../../../smart-contracts/ethereum/build/contracts/CurationStorageAccess.json'),
            address: null
        },
        Curation: {
            contract: null,
            deployed: null,
            meta: require(__dirname + '/../../../smart-contracts/ethereum/build/contracts/Curation.json'),
            address: null,
            links: [
                {
                    name: 'CurationStorageAccess', address: null
                },
                {
                    name: 'ProjectStorageAccess', address: null
                }
            ],
            params: [
                'FundingStorage',
                false
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
        gasPrice: options.gasPrice
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
    console.log('[FundingProtocol] Setting contract address for: ' + contractName + ' to ' + address)

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
    console.log('[FundingProtocol] Deploying contract for: ' + contractName)

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
