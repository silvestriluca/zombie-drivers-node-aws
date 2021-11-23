#!/usr/bin/env node
'use strict'

// Require the framework and instantiate it
const fastify = require('fastify')

//Builds the app and its routes
function build(opts={}) {
  const app = fastify(opts)
  //Root route
  app.get('/', async function (request, reply) {
    return { hello: 'world' }
  })

  return app
}

module.exports = build
