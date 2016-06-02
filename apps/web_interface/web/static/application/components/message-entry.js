import React from "react";
import Autolinker from "autolinker";
import HtmlToReact from "html-to-react";
import replaceAll from "replaceall";

function normalizeEntities(text){
  text = replaceAll("\n", "<br/>", text);
  return text;
}

function rawHtml(text){
  var htmlToReactParser = new HtmlToReact.Parser(React);
  return htmlToReactParser.parse(`<span>${text}</span>`);
}

export default class MessageEntry extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      visible: true,
      text: ""
    };
  }

  componentDidMount(){
    let { message } = this.props;

    if(message.author == "bot"){
      this.appendText(0);
    } else {
      this.setState({
        text: message.body
      });
    }
  }

  render() {
    let { message } = this.props;
    let content = this.text();

    if(message.author === "system"){
      content = (<pre>{content}</pre>);
    }

    return (
      <div className={ this.className() }>{content}</div>
    );
  }

  text() {
    if(this.state.finished){
      let autolinked = Autolinker.link(this.state.text, {
        stripPrefix: false
      });

      return rawHtml(autolinked);
    } else {
      return rawHtml(this.state.text);
    }
  }

  className() {
    let { message } = this.props;
    return message.author;
  }

  appendText(offset) {
    let { message } = this.props;
    let { body } = message;
    let { text } = this.state;

    if(offset < body.length){
      let newChar = body[offset];
      newChar = normalizeEntities(newChar);

      this.setState({
        text: text + newChar
      });

      setTimeout(() => this.appendText(offset + 1), Math.random() * 20 + 10);
    } else {
      this.setState({
        finished: true
      });
    }
  }
}
