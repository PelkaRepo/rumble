const LambdaTester = require('lambda-tester');
const rumbler = require('../index').rumbler;

describe('rumbler', function() {
  it('test success', function() {
    return LambdaTester(rumbler)
      .event({
        name: 'foo-bar'
      })
      .expectResult();
  });
});
