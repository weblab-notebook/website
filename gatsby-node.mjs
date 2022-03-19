import { getPriceData, getProductData } from "./lib/es6/src/build/getStripeData.bs";

export let onCreateWebpackConfig = ({
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

export let createPages = async ({ actions: { createPage } }) => {

  createPage({
    path: `/cloud`,
    component: require.resolve("./src/build/cloud.js"),
    context: { priceData: await getPriceData(), productData: await getProductData() },
  })
}