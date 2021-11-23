#!/usr/bin/env node
'use strict'

//creates a server
const server = require('./microservice')({
    logger: {
      level: 'info'
    }
  })

  // Run the server!
  server.listen(3000, (err, address) => {
    if (err) {
      console.log(err)
      process.exit(1)
    }
  })
