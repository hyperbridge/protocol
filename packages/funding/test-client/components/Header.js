import React from 'react'
import { Menu } from 'semantic-ui-react'
import { Link } from '../routes'

export default () => (
    <Menu style={{ marginTop: '10px' }}>
        <Menu.Item>Launchpad</Menu.Item>
        <Menu.Menu position="right">
            <Link route="/projects">
                <a className="item">Projects</a>
            </Link>
            <Link route="/">
                <a className="item">Developers</a>
            </Link>
        </Menu.Menu>
    </Menu>
)
