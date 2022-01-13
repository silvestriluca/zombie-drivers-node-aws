const debugHelpers = require('./debug-helpers');

test('Tests getIpMap', () => {
  const { getIpMap } = debugHelpers;
  const ipMap = getIpMap();
  console.log(ipMap);
  expect(ipMap).not.toBe(null);
  expect(ipMap).not.toBeUndefined();
});
