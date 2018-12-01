import React from 'react';
import PropTypes from 'prop-types';

const Screen = ({ children }) => (
  <section className="Screen">
    {children}
  </section>
);

Screen.propTypes = {
  children: PropTypes.node.isRequired,
};
export default Screen;
