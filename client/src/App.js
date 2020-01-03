import React, { Component } from "react";
import MintTokenContract from "./contracts/CryptoChatToken.json";
import getWeb3 from "./utils/getWeb3";


import "./App.css";

import {
  Route,
  HashRouter,
} from "react-router-dom";

import Main from "./components/Main/Main";

import Join from "./components/Join/Join";

import TopBar from "./components/TopBar/TopBar";

var account;
var web3

class App extends Component {
  state = { storageValue: 0, web3: null, accounts: null, contract: null, account: null};

  componentDidMount = async () => {
    try {
      // Get network provider and web3 instance.
      web3 = await getWeb3();

      // Use web3 to get the user's accounts.
      const accounts = await web3.eth.getAccounts();

      account = accounts[0];

      // Get the contract instance.
      const networkId = await web3.eth.net.getId();
      const deployedNetwork = MintTokenContract.networks[networkId];
      const instance = new web3.eth.Contract(
        MintTokenContract.abi,
        deployedNetwork && deployedNetwork.address,
      );
        
      web3.currentProvider.publicConfigStore.on('update', function(event){
          var a = account.toString().toLowerCase() ;
          var b = event.selectedAddress.toString().toLowerCase();
          if(a !== b){
            //console.error(a + "\n" + b);
            window.location.reload();
            account = event.selectedAddress
          }
      });


      // Set web3, accounts, and contract to the state, and then proceed with an
      // example of interacting with the contract's methods.
      this.setState({ web3, accounts, contract: instance, account });

      this.addEventListener(this);

    } catch (error) {
      // Catch any errors for any of the above operations.
      alert(
        `Failed to load web3, accounts, or contract. Check console for details.`,
      );
      console.error(error);
    }
  };


  addEventListener() {

    this.state.contract.events.LogDisplay({fromBlock: 0, toBlock: 'latest'})
    .on('data', function(event){
      console.log(event.returnValues); // same results as the optional callback above
    })
    .on('error', console.error);

    this.state.contract.events.LogUpdate({fromBlock: 0, toBlock: 'latest'})
    .on('data', function(event){
      console.log(event.returnValues); // same results as the optional callback above
    })
    .on('error', console.error);

    this.state.contract.events.LogValidUser({fromBlock: 0, toBlock: 'latest'})
    .on('data', function(event){
      console.log(event.returnValues.valid);
    })
    .on('error', console.error);

  }

  render() {
    if (!this.state.web3) {
      return <div>Loading Web3, accounts, and contract...</div>;
    }
    return (
      <div className="App">
        <HashRouter>
          <TopBar {...this.state}></TopBar> 
          <Route exact path="/" render = {(routeProps)=>(<Main {...routeProps} {...this.state}/>)}/> 
          <Route path="/Join" render = {(routeProps)=>(<Join {...routeProps} {...this.state}/>)}/>   
        </HashRouter> 
      </div>
    );
  }
}

export default App;
