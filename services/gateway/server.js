#!/usr/bin/env node

const process = require('process');
// Defines Port and Host of the microservice
const PORT = parseInt(process.env.PORT, 10) || 3000;
const HOST = process.env.HOST || 'localhost';

// creates a server
const server = require('./microservice')({
  logger: {
    level: 'info',
  },
});

// Run the server!
// eslint-disable-next-line no-unused-vars
server.listen({ port: PORT, host: HOST }, (err, address) => {
  if (err) {
    console.error(err);
    process.exit(1);
  }
});

/**
 * Event handler to close the server and its processes in a graceful way
 *
 * @param {string} signal
 */
async function closeGracefully(signal) {
  console.info(`Received signal to terminate: ${signal}`);
  await server.close();
  // await db.close() if we have a db connection in this app
  // await other things we should cleanup nicely
  process.exit();
}

// Catches SIGTERM & SIGINT
process.on('SIGTERM', closeGracefully);
process.on('SIGINT', closeGracefully);
