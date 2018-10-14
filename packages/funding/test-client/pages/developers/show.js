import React, { Component } from 'react'
import { Card } from 'semantic-ui-react'
import Web3 from 'web3'
import contract from 'truffle-contract'
import Layout from '../../components/Layout'
import fundingServiceJson from '../../../smart-contracts/ethereum/build/contracts/FundingService.json'
import projectJson from '../../../smart-contracts/ethereum/build/contracts/Project.json'

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

export default class DeveloperShow extends Component {
    static async getInitialProps(props) {
        const fundingService = await FundingService.deployed()

        const developerInfo = await fundingService.getDeveloper(props.query.id)
        const projectIds = developerInfo[2].map((id) => {
            return id.toNumber()
        })

        const projects = await Promise.all(
            projectIds.map(async (id) => {
                const projectAddress = await fundingService.projects(id)
                const project = await Project.at(projectAddress)
                const title = await project.title()
                const description = await project.description()

                return {
                    id,
                    title,
                    address: projectAddress,
                    description
                }
            })
        )

        return {
            id: props.query.id,
            address: developerInfo[0],
            name: developerInfo[1],
            projects
        }
    }

    renderProjects() {
        const items = this.props.projects.map((project) => {
            return {
                header: project.title,
                meta: `ID: ${project.id} --- ${project.address}`,
                description: project.description,
                fluid: true
            }
        })

        return <Card.Group items={items} />
    }

    render() {
        return (
            <Layout>
                <h1>{this.props.name}</h1>
                <h5>{this.props.address}</h5>
                <hr />
                <h3>{`${this.props.name}'s Projects`}</h3>
                {this.renderProjects()}
            </Layout>
        )
    }
}
