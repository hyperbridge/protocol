import React, { Component } from 'react'
import { Card, Button, Icon } from 'semantic-ui-react'
import Web3 from 'web3'
import contract from 'truffle-contract'
import Layout from '../components/Layout.js'
import { Link } from '../routes'
import fundingServiceJson from '../../smart-contracts/ethereum/build/contracts/FundingService.json'
import projectJson from '../../smart-contracts/ethereum/build/contracts/Project.json'

const provider = new Web3.providers.HttpProvider('http://localhost:8545')
const web3 = new Web3(provider)
const FundingService = contract(fundingServiceJson)
const Project = contract(projectJson)

FundingService.setProvider(provider)
Project.setProvider(provider)

// dirty hack for web3@1.0.0 support for localhost testrpc, see https://github.com/trufflesuite/truffle-contract/issues/56#issuecomment-331084530
if (typeof FundingService.currentProvider.sendAsync !== 'function') {
    FundingService.currentProvider.sendAsync = function() {
        return FundingService.currentProvider.send.apply(FundingService.currentProvider, arguments)
    }
}

export default class ProjectsIndex extends Component {
    static async getInitialProps() {
        const fundingService = await FundingService.deployed()
        const projectAddresses = await fundingService.getProjects()

        let projectsInfo = await Promise.all(
            projectAddresses.map(async (address) => {
                const id = await fundingService.projectMap(address)
                const project = await Project.at(address)
                const title = await project.title()
                return {
                    id,
                    address,
                    title
                }
            })
        )

        return { projectsInfo }
    }

    renderProjects() {
        const items = this.props.projectsInfo.map((projInfo) => {
            return {
                header: projInfo.title,
                description: (
                    <Link route={`/projects/${projInfo.id}`}>
                        <a>View Project</a>
                    </Link>
                ),
                meta: `ID: ${projInfo.id} --- ${projInfo.address}`,
                fluid: true
            }
        })

        return <Card.Group items={items} />
    }

    render() {
        return (
            <Layout>
                <div>
                    <h3>All Projects</h3>
                    <Link route="/projects/new">
                        <a>
                            <Button floated="right" content="Create Project" icon="add circle" primary />
                        </a>
                    </Link>
                    {this.renderProjects()}
                </div>
            </Layout>
        )
    }
}
