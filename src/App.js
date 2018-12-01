import React from 'react';
import { BrowserRouter as Router, Route, Switch } from 'react-router-dom';

import './App.css';
import 'bootstrap/dist/css/bootstrap.css';
import Header from './components/Header/Header';
import Home from './screens/Home';
import NavBar from './components/Navbar/Navbar';

const App = () => (
  <Router>
    <main className="app">
      <Header><NavBar /></Header>
      <Switch>
        <Route exact path="/" component={Home} />
        <Route path="/home" component={Home} />
      </Switch>
    </main>
  </Router>
);
export default App;
