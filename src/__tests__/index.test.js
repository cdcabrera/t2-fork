const { t2, opts } = require('../');

describe('t2', () => {
  it('should have specific defined methods and properties', () => {
    expect(t2).toBeDefined();
    expect(opts).toBeDefined();
  });

  it('should export an object', () => {
    expect(t2('testing')).toMatchSnapshot('output');
  });
});
