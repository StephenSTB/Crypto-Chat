import React, { Component } from "react";

import {
  NavLink,
} from "react-router-dom";

import "./TopBar.css";

class TopBar extends Component{

    constructor(props){
      super(props);
      this.state = {userText: "Join", contract: this.props.contract};
      //this.handleClick = this.handleClick.bind(this);
      this.validUser();
    }
  
    validUser = async () => {
  
      var result;
      await this.state.contract.methods.isUser().call({from: this.props.account}).then(function(event){
        result = event;
        //console.log(result);
      });
  
      var username;
      if(result === true){
  
        await this.state.contract.methods.getUsername().call({from: this.props.account}).then(function(event){
            username = event;
        });
      
        this.setState({userText: username});
        
        return true;
      }
    }
  
    render(){
      if(this.state.userText === "Join"){
        return(
          <div className = "NavBar">
            <NavLink to = "/" id = "name"> <h2>Crypto Chat</h2></NavLink>
            <NavLink to = "/Join" id = "joinbtn"><div id = "joinbtn2">{this.state.userText}</div></NavLink>
          </div>
        );
      }

      return(
        <div className = "NavBar">
          <NavLink to = "/" id = "name"> <h2>Crypto Chat</h2></NavLink>
          <NavLink to = "/Settings" id = "joinbtn"><div id = "joinbtn2">{this.state.userText}</div></NavLink>
        </div>
      );
    }
  }

  export default TopBar;