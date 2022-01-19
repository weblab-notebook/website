/**
 * Configure your Gatsby site with this file.
 *
 * See: https://www.gatsbyjs.com/docs/gatsby-config/
 */
require("dotenv").config({
  path: `.env.${process.env.NODE_ENV}`,
})
module.exports = {
  siteMetadata: {
    siteUrl: "https://www.weblab.ai",
  },
  /* Your site config here */
  plugins: ["gatsby-plugin-material-ui", "gatsby-plugin-react-helmet", {
    resolve: "gatsby-plugin-react-svg",
    options: {
      rule: {
        include: /svg/ // See below to configure properly
      }
    }
  }, {
      resolve: "gatsby-plugin-google-gtag",
      options: {
        // You can add multiple tracking ids and a pageview event will be fired for all of them.
        trackingIds: [
          process.env.GOOGLE_ANALYTICS_KEY, // Google Analytics / GA
        ],
        // This object gets passed directly to the gtag config command
        // This config will be shared across all trackingIds
        gtagConfig: {
          anonymize_ip: true,
        },
        // This object is used for configuration specific to this plugin
        pluginConfig: {
          // Puts tracking script in the head instead of the body
          head: false,
          // Setting this parameter is also optional
          respectDNT: true,
        },
      },
    }, {
      resolve: "gatsby-plugin-csp",
      options: {
        disableOnDev: true,
        reportOnly: false,
        mergeScriptHashes: true, // you can disable scripts sha256 hashes
        mergeStyleHashes: false, // you can disable styles sha256 hashes
        mergeDefaultDirectives: true,
        directives: {
          "default-src": "'self'",
          "style-src": " 'self' 'unsafe-inline'",
          "img-src": "'self' data: blob: https: www.googletagmanager.com",
          "script-src": "'self' 'unsafe-eval' https://cdn.jsdelivr.net https://cdn.skypack.dev www.googletagmanager.com",
          "connect-src": "'self' https: data:",
        }
      }
    },
    {
      resolve: "gatsby-plugin-sitemap",
      options: {
        output: "/"
      },
    }],
}
