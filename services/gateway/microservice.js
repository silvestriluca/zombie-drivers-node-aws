#!/usr/bin/env node

// Requires standard libraries
const querystring = require('querystring');
// Require the framework and instantiate it
const fastify = require('fastify');
// Requires SNS Class
const { SNS } = require('@aws-sdk/client-sns');
const process = require('process');
// Reqires other libraries
const debugHelpers = require('./debug-helpers');

const REGION = process.env.REGION || 'eu-west-1';

async function sendToSns(payload) {
  // Instantiates sns client
  const sns = new SNS({ region: REGION });
  return null;
}

/**
 * Builds the app and its routes
 * @param {*} opts fastify options
 * @returns an instance of fastify
 */
function build(opts = {}) {
  const app = fastify(opts);
  // Root route
  // eslint-disable-next-line no-unused-vars
  app.get('/', async (request, reply) => {
    if (request.query.debug === 'true') {
      return { hello: 'world', debug: debugHelpers.getIpMap() };
    }

    return { hello: 'world' };
  });
  // driver location
  app.patch('/drivers/:id/locations', async (request, reply) => {
    await sendToSns(request.body);
  });
  return app;
}

module.exports = build;
