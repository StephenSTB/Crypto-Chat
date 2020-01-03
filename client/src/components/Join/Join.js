import React, { Component } from "react";

import "./Join.css";

import {
    Redirect,
  } from "react-router-dom";

var self



class Join extends Component {
    constructor(props){
        super(props);
        self = this;
        self.state = {error: null, redirect: false}; 
        this.redirect();
    }

    redirect = async () =>{
        var re;
        await this.props.contract.methods.isUser().call({from:this.props.accounts[0]}).then(function(result){
            re = result;
        });
        if(re === true){
            window.location.assign("/");
        }
        
    }

    handleClick = async () =>{
        if(document.getElementById("userInput").value.length > 3 && document.getElementById("userInput").value.length < 26){
            var taken;
            await this.props.contract.methods.usernameTaken(document.getElementById("userInput").value).call().then(function(result){
                taken = result;
            });
            if(taken === true){
                self.setState({error:"Username has already been taken."});
                return;
            }
            await this.props.contract.methods.addUser(document.getElementById("userInput").value).send({from: this.props.account, value: 4000000000000000});
            self.setState({error:"", redirect: true});
            window.location.assign("/");
        }
        else{
            if(document.getElementById("userInput").value.length < 4){
                self.setState({error:"Username must be greater then 3 characters."});
            }
            else if(document.getElementById("userInput").value.length > 25){
                self.setState({error:"Username must be less then 26 characters."});
            }
            
        }  
    }

    render() {
        if(this.redirect === true){
            console.log("here");
            return(<Redirect to="/"/>);
        }
        return(
            <div className = "JoinMain">
             <h2 id = "signUp">Sign Up</h2>
             <div id = "curAddress"><div id ="adrLabel">Current Address:</div><div id = "adr">{this.props.account}</div></div>
             <div id = "user"><div id = "userLabel">Username:</div><input id ="userInput"></input> </div>
             <div id = "error">{this.state.error}</div>
             <div id = "join" onClick = {this.handleClick}>Join</div>
                
            </div>
        );
    }
}
export default Join;