#!/usr/bin/env node

// Require the framework and instantiate it
const fastify = require('fastify');

/**
 * Builds the app and its routes
 * @param {*} opts fastify options
 * @returns an instance of fastify
 */
function build(opts = {}) {
  const app = fastify(opts);
  // Root route
  // eslint-disable-next-line no-unused-vars
  app.get('/', async (request, reply) => ({ hello: 'world' }));
  return app;
}

module.exports = build;
