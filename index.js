var AWS = require('aws-sdk'),
  request = require('request')
AWS.config.update({
  region: 'us-west-2'
});

exports.rumbler = function(event, context, callback) {
  console.log("value1 = " + event.key1);
  // This is the api which will be hit:  https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/2.5_day.geojson
  callback(null, "some success message");
}
