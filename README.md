# Full Stack Bot

The engine behind Full Stack Fest's 2016 AI bot.

![Demo](http://www.giphy.com/gifs/3oD3YFS3Zz3msIOSyY)

## Tech Stack

* An `Elixir`'s' umbrella app containing two apps:
  * The bot engine that talks to [api.ai](https://api.ai)
  * A web interface leveraging phoenix

The web interface uses:

* `webpack` to bundle all the assets
* `Babel` to cross-compile ES7
* `react.js` for the view layer
* `mobx` for state handling

It can be easily deployed via docker as it includes a Dockerfile.
