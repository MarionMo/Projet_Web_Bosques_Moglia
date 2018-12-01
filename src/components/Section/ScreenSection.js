import React from 'react';
import PropTypes from 'prop-types';
import { Container } from 'reactstrap';

import './ScreenSection.scss';

const ScreenSection = ({ children }) => (
  <Container tag="section" className="ScreenSection">
    { children }
  </Container>
);

ScreenSection.propTypes = {
  children: PropTypes.node.isRequired,
};
export default ScreenSection;
