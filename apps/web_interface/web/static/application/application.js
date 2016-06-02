import React from "react";
import ReactDOM from "react-dom";

import ChatBox from "./components/chat-box";
import ChatSession from "./stores/chat-session";

require("./application.scss");

const chatSession = new ChatSession();
chatSession.connect();

chatSession.addMessage({
  author: "system",
  body: require("./welcome-message.txt")
});

ReactDOM.render(<ChatBox chatSession={chatSession} />, document.getElementById('application'));
