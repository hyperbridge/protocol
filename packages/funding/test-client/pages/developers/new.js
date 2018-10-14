import React, { Component } from 'react'
import { Form, Button, Message } from 'semantic-ui-react'
import Web3 from 'web3'
import contract from 'truffle-contract'
import Layout from '../../components/Layout.js'
import fundingServiceJson from '../../../smart-contracts/ethereum/build/contracts/FundingService.json'
import { Router } from '../../routes'

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

export default class DeveloperNew extends Component {
    state = {
        name: '',
        errorMessage: '',
        loading: false
    }

    onSubmit = async (event) => {
        event.preventDefault()

        this.setState({ loading: true, errorMessage: '' })

        try {
            const fundingService = await FundingService.deployed()

            const accounts = await web3.eth.getAccounts()

            await fundingService.createDeveloper(this.state.name, {
                from: accounts[0],
                gas: 3000000
            })

            Router.pushRoute('/')
        } catch (err) {
            this.setState({ errorMessage: err.message })
        }

        this.setState({ loading: false })
    }

    render() {
        return (
            <Layout>
                <h1>New Developer</h1>

                <Form onSubmit={this.onSubmit} error={!!this.state.errorMessage}>
                    <Form.Field>
                        <label>Name</label>
                        <input
                            value={this.state.name}
                            onChange={(event) => {
                                this.setState({ name: event.target.value })
                            }}
                        />
                    </Form.Field>
                    <Message error header="Oops!" content={this.state.errorMessage} />
                    <Button loading={this.state.loading} primary>
                        Create
                    </Button>
                </Form>
            </Layout>
        )
    }
}
