module.exports = {
    moduleFileExtensions: ['js'],
    transform: {
        '^.+\\.js$': './jest-transform.js',
    },
    transformIgnorePatterns: [
        // transform ES6 modules generated by BuckleScript
        // https://regexr.com/46984
        '/node_modules/(?!(@.*/)?(bs-.*|reason-.*|rescript.*|@rescript.*)/).+\\.js$',
    ],
    testEnvironment: "jsdom",
    moduleNameMapper: {
        "@fontsource/*": "<rootDir>/__mocks__/font-mock.js",
        // other rules...
    },
};