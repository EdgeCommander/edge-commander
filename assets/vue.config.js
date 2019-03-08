const path = require('path');

module.exports = {
  lintOnSave: true,
  outputDir: path.resolve(__dirname, '../priv/static'),
  filenameHashing: false,
  chainWebpack: config => {
    config.optimization.delete('splitChunks')
  }
};
