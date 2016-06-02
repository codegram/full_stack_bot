import React from "react";
import { Socket } from "phoenix";

import {observer} from "mobx-react";

import MessageEntry from "./message-entry";
import messageAction from "../services/message-action";
import bowser from "bowser";
import welcomeMessage from "../welcome-message.txt";

require("./chat-box.scss");

@observer
class ChatBox extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      input: ""
    };
  }

  componentDidMount() {
    let {chatSession} = this.props;

    window.addEventListener('keypress', this._handleKeyPress.bind(this));
    window.addEventListener('keydown', this._handleKeyDown.bind(this));
  }

  render() {
    let { chatSession } = this.props;

    if(chatSession.connected){
      let { input } = this.state;
      let { chatSession } = this.props;
      let messages = chatSession.messages;

      let list = messages.map((m) =>
                              <li key={messages.indexOf(m)}>
                                <MessageEntry message={m} />
                              </li>);

      return (
        <div className="chat-box" onClick={() => this.inputText.focus()} id="chat-box">
          <a
            className="application-logo"
            href="https://2016.fullstackfest.com"
            target="_blank">Full Stack Fest</a>
          <input type="text"
            tabindex="1"
            className="message-input" ref={(input) => this.inputText = input}
            onKeyPress={(e) => this._handleKeyPress(e) }/>
          <ul>
            {list}
            <li key="input">
              <div className="me">{input}<span className="input-cursor"></span></div>
            </li>
          </ul>
        </div>
      );
    } else {
      return (
        <span>Connecting...</span>
      );
    }
  }

  componentDidUpdate() {
    if(!bowser.mobile && !bowser.tablet){
      window.scrollTo(0,document.body.scrollHeight);
    }
  }

  _handleKeyDown(e) {
    if(e.code === 'Backspace' || e.key === 'Backspace' || e.keyIdentifier === "U+0008"){
      e.preventDefault();
      let { input } = this.state;
      this.setState({
        input: input.substring(0, input.length - 1)
      });
    }
  }

  _handleKeyPress(e) {
    let { input } = this.state;
    let { chatSession } = this.props;

    if (e.charCode === 13) {
      let message = { body: input, author: "me" };
      chatSession.sendMessage(message);
      this.setState({input: ""});
    } else {
      this.setState({
        input: input + (e.key || String.fromCharCode(e.keyCode))
      });
    }

    e.preventDefault();
    e.stopPropagation();
    return false;
  }
}

export default ChatBox;
