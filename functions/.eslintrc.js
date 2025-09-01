module.exports = {
  env: {
    es6: true,
    node: true,
  },
  parserOptions: {
    "ecmaVersion": 2018,
  },
  extends: [
    "eslint:recommended",
    "google",
  ],
  rules: {
    "valid-jsdoc": "off",
    "object-curly-spacing": "off",  // Ignore spaces after or before `{` and `}`
    "indent": "off",                // Ignore indentation errors
    "no-multi-spaces": "off",        // Allow multiple spaces in code
    "max-len": ["error", { "code": 120 }],  // Allow longer lines up to 120 characters
    "padded-blocks": "off",          // Ignore extra blank lines in blocks
    "no-restricted-globals": ["error", "name", "length"],
    "prefer-arrow-callback": "error",
    "quotes": ["error", "double", {"allowTemplateLiterals": true}],
  },
  overrides: [
    {
      files: ["**/*.spec.*"],
      env: {
        mocha: true,
      },
      rules: {},
    },
  ],
  globals: {},
};
