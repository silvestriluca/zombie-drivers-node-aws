#!/usr/bin/env node

// Requires standard libraries
const os = require('os');

/**
 * Gets a Map of {interfaces: IP}
 *
 * @returns Map of {interfaces: IP}
 */
function getIpMap() {
  const ifaces = os.networkInterfaces();
  const localIpMap = {};
  Object.keys(ifaces).forEach((ifname) => {
    ifaces[ifname].forEach((iface) => {
      if (iface.family !== 'IPv4' || iface.internal !== false) {
        // Skip over internal (i.e. 127.0.0.1) and non-IPv4 addresses

      } else {
        if (!localIpMap[ifname]) {
          localIpMap[ifname] = [];
        }
        localIpMap[ifname].push(iface.address);
      }
    });
  });
  return localIpMap;
}

module.exports = {
  getIpMap,
};
