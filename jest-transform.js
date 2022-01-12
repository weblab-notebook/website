module.exports = require('babel-jest').default.createTransformer({
    presets: [
        ['@babel/preset-env', {
            modules: 'auto',
            targets: {
                node: 14,
            }
        }]
    ],
});