import React, { Component } from 'react'
import { Card, Button, Icon } from 'semantic-ui-react'
import Web3 from 'web3'
import contract from 'truffle-contract'
import Layout from '../components/Layout.js'
import { Link } from '../routes'
import fundingServiceJson from '../../smart-contracts/ethereum/build/contracts/FundingService.json'

const provider = new Web3.providers.HttpProvider('http://localhost:8545')
const web3 = new Web3(provider)
const FundingService = contract(fundingServiceJson)

FundingService.setProvider(provider)

// dirty hack for web3@1.0.0 support for localhost testrpc, see https://github.com/trufflesuite/truffle-contract/issues/56#issuecomment-331084530
if (typeof FundingService.currentProvider.sendAsync !== 'function') {
    FundingService.currentProvider.sendAsync = function() {
        return FundingService.currentProvider.send.apply(FundingService.currentProvider, arguments)
    }
}

export default class FundingIndex extends Component {
    state = {
        developersInfo: []
    }

    static async getInitialProps() {
        const fundingService = await FundingService.deployed()
        const developerAddresses = await fundingService.getDevelopers()

        let developersInfo = await Promise.all(
            developerAddresses.map(async (address) => {
                const id = await fundingService.developerMap(address)
                const devInfo = await fundingService.developers(id)
                return {
                    address,
                    id,
                    name: devInfo[2]
                }
            })
        )

        return { developersInfo }
    }

    renderDevelopers() {
        const items = this.props.developersInfo.map((devInfo) => {
            return {
                header: devInfo.name,
                description: (
                    <Link route={`/developers/${devInfo.id}`}>
                        <a>View Developer</a>
                    </Link>
                ),
                meta: `ID: ${devInfo.id} --- ${devInfo.address}`,
                fluid: true
            }
        })

        return <Card.Group items={items} />
    }

    render() {
        return (
            <Layout>
                <div>
                    <h3>All Developers</h3>
                    <Link route="/developers/new">
                        <a>
                            <Button floated="right" content="Create Developer" icon="add circle" primary />
                        </a>
                    </Link>
                    {this.renderDevelopers()}
                </div>
            </Layout>
        )
    }
}
