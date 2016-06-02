import navigate from "./message-action/navigate";

const actions = {
  navigate
};

export default function(message){
  let { action, parameters } = message;

  if(actions[action]){
    return actions[action].call(this, message, parameters);
  } else {
    return message;
  }
}
