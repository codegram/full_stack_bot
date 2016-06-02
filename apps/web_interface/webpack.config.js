var CopyWebpackPlugin = require("copy-webpack-plugin");
var precss       = require('precss');
var autoprefixer = require('autoprefixer');
var bourbon = require('node-bourbon').includePaths;
var neat = require('node-neat').includePaths[1];
var webpack = require('webpack');

module.exports = {
  entry: ["./web/static/index.js"],
  output: {
    path: "./priv/static/assets",
    filename: "index.js",
    publicPath: '/assets/'
  },

  resolve: {
    extensions: ['', '.js', '.jsx']
  },

  module: {
    loaders: [{
      test: /\.jsx?$/,
      exclude: /node_modules/,
      loader: "babel"
    }, {
      test: /\.json$/,
      loader: "json"
    }, {
      test: /\.txt$/,
      loader: "raw"
    }, {
      test: /\.scss$/,
      loaders: ["style", "css", "postcss", "sass?includePaths[]=" + bourbon + "&includePaths[]=" + neat]
    }, {
      test: /\.css$/,
      loaders: ["style", "css", "postcss"]
    }, {
      test: /\.(woff(2)?)|ttf|svg|eot(\?v=[0-9]\.[0-9]\.[0-9])?$/, loader: "url-loader?limit=10000&mimetype=application/font-woff"
    }, {
      test: /\.(jpe?g|png|gif|svg)$/i,
      loaders: [
        'url?hash=sha512&digest=hex&name=[hash].[ext]&limit=10000',
        'image-webpack?bypassOnDebug&optimizationLevel=7&interlaced=false'
      ]
    }]
  },

  postcss: function() {
    return [precss, autoprefixer];
  },

  plugins: [
    new CopyWebpackPlugin([{ from: "./web/static/assets" }]),
    new webpack.DefinePlugin({
      'process.env':{
        'NODE_ENV': JSON.stringify(process.env.NODE_ENV || 'development')
      }
    })
  ]
};
