#!/usr/bin/env node

// creates a server
const server = require('./microservice')({
  logger: {
    level: 'info',
  },
});

// Run the server!
// eslint-disable-next-line no-unused-vars
server.listen(3000, '0.0.0.0', (err, address) => {
  if (err) {
    console.log(err);
    process.exit(1);
  }
});
