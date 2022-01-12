exports.onCreateWebpackConfig = ({
  stage,
  rules,
  loaders,
  plugins,
  actions,
}) => {
  actions.setWebpackConfig({
    module: {
      rules: [
        {
          test: /\.wasm$/,
          type: 'webassembly/async',
        }
      ]
    },
    experiments: {
      asyncWebAssembly: true
    },
    node: {
      fs: 'empty'
    }
  })
}