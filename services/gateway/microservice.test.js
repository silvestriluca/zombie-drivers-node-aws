const build = require('./microservice');

test('reqests the "/" route', async () => {
  const microservice = build();
  const response = await microservice.inject({
    method: 'GET',
    url: '/',
  });
  expect(response.statusCode).toBe(200);
  microservice.close();
});
