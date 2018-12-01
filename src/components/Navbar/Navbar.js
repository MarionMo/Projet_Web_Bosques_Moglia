import React from 'react';

import { NavLink as RRNavLink } from 'react-router-dom';

import {
  Container,
  Collapse,
  Navbar,
  NavbarBrand,
  Nav,
  NavItem,
  NavLink,
} from 'reactstrap';

export default class NavBar extends React.Component {
  constructor(props) {
    super(props);
    console.log('');
  }

  render() {
    return (
      <Container>
        <Navbar className="navbar navbar-dark bg-dark" white expand="md">
          <NavbarBrand href="/">Pico 8</NavbarBrand>
          <Collapse navbar>
            <Nav className="ml-auto" navbar>
              <NavItem>
                <NavLink tag={RRNavLink} to="/home">Accueil</NavLink>
              </NavItem>
            </Nav>
          </Collapse>
        </Navbar>
      </Container>
    );
  }
}