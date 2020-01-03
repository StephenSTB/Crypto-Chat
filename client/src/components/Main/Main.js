import React, { Component } from "react";

import "./Main.css";

import upvote from '../../img/upvote.png';

import upvote2 from '../../img/upvotehover1.png';

var MainSelf;

class Main extends Component{
  constructor(props){
    super(props);
    this.state = {text: "message", messageHistory : [] , prevID : 0, usersTokens: 0, dailyTokens: 0, messageRange: 6200};
    MainSelf = this;
    this.addEventListener(this);
    this.getUsersTokens();
  }

  // Send Message to CryptoChat
  sendClick = async () =>{    
    await this.props.contract.methods.mintMessage(document.getElementById("txtArea").value).send({from: this.props.account});
    MainSelf.getUsersTokens();
  }

  addEventListener = async () =>{
    this.props.contract.events.LogMessage({fromBlock: await this.props.web3.eth.getBlockNumber() - this.state.messageRange, toBlock: 'latest'})
    .on('data', function(event){
       // same results as the optional callback above    
        console.log(event.returnValues);
        if(event.returnValues.messageID !== MainSelf.state.prevID){
          var msgHistory = MainSelf.state.messageHistory;
          msgHistory.push([event.returnValues.sender, event.returnValues.username, event.returnValues.message, event.returnValues.messageID]);
          MainSelf.setState({messageHistory: msgHistory, prevID: event.returnValues.messageID});
        }
    })
    .on('error', console.error);

    this.props.contract.events.Transfer({fromBlock: 0, toBlock: 'latest'})
    .on('data', function(event){
      if(event.returnValues.to === MainSelf.props.account){
        MainSelf.getUsersTokens();
      }

    })
    .on('error', console.error);
  }

  getUsersTokens = async() =>{
    var uT;
    await this.props.contract.methods.balanceOf(this.props.account).call().then(function(event){
      uT = event / 1000000000000000000;
    });

    var dT;
    await this.props.contract.methods.availableTokens(this.props.account).call().then(function(event){
      dT = event;
    });

    MainSelf.setState({usersTokens: uT, dailyTokens: dT});
  }

  mintToken = async (sender) =>{
    await this.props.contract.methods.mintToken(sender).send({from : this.props.account});
  }

  upVoteHover(id) {
    document.getElementById(id).setAttribute("src", upvote2);
  }

  upVoteUnHover(id) {
    document.getElementById(id).setAttribute("src", upvote);
  }

  timeSort(){
    var time = document.getElementById("timeSelect").value;

    var msgRange;

    switch(time){
      case "Minute": msgRange = 5; break;
      case "Hour" : msgRange = 255; break;
      case "Day"  : msgRange = 6200; break;
      case "Week" : msgRange = 43400; break;
      default : msgRange = 6200;
    }
    console.log("here1");

    MainSelf.setState({messageRange: msgRange});
    MainSelf.render();
  }

  render(){

    const messageHist = this.state.messageHistory;
    var messages = messageHist.map((msg)=> {
        var vid = "upvote" + msg[3];
      return(
        <div className = "messageContainer">
          <div id = "usernamecontainer" onClick = {() => this.mintToken(msg[0])}><div id = "username">{msg[1]}</div>:</div> &nbsp; &nbsp; &nbsp; &nbsp;
          <div id = "message">{msg[2]}</div>
          <div onClick = {() => this.mintToken(msg[0])}><img alt="" id = {vid} src={upvote} onMouseOver = {() => this.upVoteHover(vid)} onMouseOut= {() => this.upVoteUnHover(vid)}/></div>
          <div id = "ID">#{msg[3]}</div>
        </div>
      );
    });
    

    return(
      <div className = "Main">
        <div className = "tokenInfo">
          <div id = "CCTokens">Tokens: {this.state.usersTokens}</div>
          <div id = "dailyTokens">Daily Allowance: {this.state.dailyTokens}</div>
          <div id ="sortMessages">
            <select className="arrows" id="timeSelect" onChange={MainSelf.timeSort} defaultValue="Day">
              <option value="Minute">Minute</option>
              <option value="Hour">Hour</option>
              <option value="Day">Day</option>
              <option value="Week">Week</option>
            </select>
          </div>
        </div>
        
        <div id = "chatBox">{messages}</div>
        <div className = "Submition">
          <textarea id = "txtArea" ></textarea>
          <div id = "send" onClick = {this.sendClick}>Send</div>
        </div>
      </div>

    );
  }
}

export default Main;