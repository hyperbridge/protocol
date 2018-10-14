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

export default class ProjectShow extends Component {
    static async getInitialProps(props) {
        const fundingService = await FundingService.deployed()

        console.log(props.query.id)
        const address = await fundingService.projects(props.query.id)
        const project = await Project.at(address)
        const title = await project.title()
        const description = await project.description()
        const about = await project.about()
        const devId = await project.developerId()
        const developerInfo = await fundingService.getDeveloper(devId)
        const developerAddress = developerInfo[0]
        const developerName = developerInfo[1]

        return {
            id: props.query.id,
            title,
            description,
            about,
            address,
            developerAddress,
            name: developerInfo[1],
            developerName
        }
    }

    render() {
        return (
            <Layout>
                <h1>{`${this.props.title} (ID: ${this.props.id} --- ${this.props.address})`}</h1>
                <h5>{`Developed by: ${this.props.developerName} (${this.props.developerAddress})`}</h5>
                <h3>{this.props.description}</h3>
                <hr />
                <h3>{this.props.about}</h3>
            </Layout>
        )
    }
}
