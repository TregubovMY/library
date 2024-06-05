const path    = require("path")
const webpack = require("webpack")

module.exports = {
  mode: "production",
  devtool: "source-map",
  entry: {
    application: "./app/javascript/application.js",
    modal: "./app/javascript/modal.js"
  },
  output: {
    filename: "[name].js",
    sourceMapFilename: "[file].map",
    chunkFormat: "module",
    path: path.resolve(__dirname, "app/assets/builds"),
    assetModuleFilename: "app/assets/images/[name][ext]"
  },
  module: {
    rules: [
      {
        test: /\.(png|svg|jpg|jpeg|)$/i,
        type: 'asset/resource',
      }
    ]
  },
  plugins: [
    new webpack.optimize.LimitChunkCountPlugin({
      maxChunks: 1
    })
  ]
}
