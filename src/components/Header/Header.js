import React from 'react';
import PropTypes from 'prop-types';

const Header = ({ children }) => (
  <div className="header">
    {children}
  </div>
);

Header.propTypes = {
  children: PropTypes.node.isRequired,
};
export default Header;