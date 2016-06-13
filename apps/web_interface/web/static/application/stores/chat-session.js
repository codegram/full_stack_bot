import { observable, computed, observe } from 'mobx';
import messageAction from "../services/message-action";
import Message from "../models/message";
import { Socket } from "phoenix";
import uuid from "node-uuid";

function generateSessionId() {
  let sessionId = localStorage.sessionId || uuid.v1();
  localStorage.sessionId = sessionId;
  return sessionId;
}

export default class {
  @observable messages = [];
  @observable connected = false;

  constructor() {
    observe(this.messages, (change) => {
      change.added = change.added.map(messageAction);
      return change;
    });
  }

  connect() {
    let socket = new Socket("/socket");
    socket.connect();

    let channel = socket.channel(`rooms:${generateSessionId()}`, {});

    channel.join()
      .receive("ok", () => this.connected = true)
      .receive("ok", () => this.sendInitialMessage())
      .receive("error", resp => { console.log("Unable to join", resp); });

    channel.on("message", (message) => this.addMessage(message) );

    this.channel = channel;
  }

  sendMessage(message){
    this.channel.push("message", message);
    this.addMessage(message);
  }

  addMessage(message) {
    this.messages.push(new Message(message));
  }

  sendInitialMessage() {
    let message = new Message({ author: "me", body: "/start"});
    this.channel.push("message", message);
  }

  @computed get messageCount() {
    return this.messages.length;
  }
}
