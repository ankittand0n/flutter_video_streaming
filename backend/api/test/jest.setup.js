// Increase timeout for all tests
jest.setTimeout(10000);

// Silence console logs during tests
global.console = {
  ...console,
  // Comment out any of these to see more logs
  log: jest.fn(),
  debug: jest.fn(),
  info: jest.fn(),
  warn: jest.fn(),
  error: jest.fn(),
};