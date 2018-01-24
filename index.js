var AWS = require('aws-sdk'),
  request = require('request')
AWS.config.update({
  region: 'us-west-2'
});

exports.rumbler = function(event, context, callback) {
  console.log("value1 = " + event.key1);
  callback(null, "some success message");
}
