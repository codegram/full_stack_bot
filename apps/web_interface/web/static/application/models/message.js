import { observable } from 'mobx';

export default class {
  @observable author = null;
  @observable body = null;
  @observable action = null;
  @observable parameters = {};

  constructor({author, body, action, parameters}){
    this.author = author;
    this.body = body;
    this.action = action;
    this.parameters = parameters;
  }
}
