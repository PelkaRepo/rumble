const EMPTY = '';
var AWS = require('aws-sdk'),
  request = require('request'),
  jsonpath = require('jsonpath'),
  jsonlint = require("jsonlint");
AWS.config.update({
  region: process.env.AWS_REGION
});

exports.rumbler = function(event, context, callback) {
  var source_url = get_source_url();
  request.get({
      url: source_url,
      headers: [{
        name: 'Content-Type',
        value: 'application/json'
      }]
    }, function(error, response, body) {
      callback(null, parse_usgs_rumbles(JSON.parse(response.body)));
    })
    .on('error', function(e) {
      throw new Error('There was a problem processing the URL request to ' + source_url + ': ' + e)
    });
}

get_source_url = function(callback) {
  var source_url = process.env.SOURCE_URL;

  if (source_url === EMPTY) {
    throw new Error('There was no source API URL from which to access seismic data');
  }
  return source_url;
}

// TODO: This should reference a data object model and/or a schema, in hindsight
parse_usgs_rumbles = function(seismic_data) {
  try {
    // This is the equivalent pattern as jq's $.features[].properties.place
    var unfiltered_rumbles = jsonpath.query(seismic_data, '$.features[*]..place'),
      rumbles = [];
    for (var i = 0; i < unfiltered_rumbles.length; i++) {
      var current_rumble_tokens = unfiltered_rumbles[i].split(',');
      // Position of location
      var current_location = current_rumble_tokens[current_rumble_tokens.length - 1].trim();
      if (current_location !== EMPTY) {
        rumbles.push(current_location);
      }
    }
    return rumbles;
  } catch (e) {
    throw new Error('Seismic data for USGS source did not contain validly parsable data: ' + e);
  }
}
