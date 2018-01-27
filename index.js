const EMPTY = '';
var AWS = require('aws-sdk'),
  request = require('request'),
  jsonpath = require('jsonpath'),
  jsonlint = require("jsonlint");
AWS.config.region = (process.env.AWS_REGION !== '' && process.env.AWS_REGION !== undefined) ? process.env.AWS_REGION : 'us-west-2';

exports.rumbler = function(event, context, callback) {
  var sns = new AWS.SNS();
  var source_url = get_source_url();
  var rumbler_topic_arn = get_rumbler_topic_arn();
  request.get({
      url: source_url,
      headers: [{
        name: 'Content-Type',
        value: 'application/json'
      }]
    }, function(error, response, body) {
      var rumbles = parse_usgs_rumbles(JSON.parse(response.body));

      sns.publish({
          Message: JSON.stringify(rumbles),
          TargetArn: rumbler_topic_arn
      }, function(e, data) {
          if (e) {
              console.log("There was a problem publishing to the rumbler topic: " + e.stack);
              callback(e);
              return;
          }
          context.done(null, 'Push event sent to registered users');
      });

      callback(null, rumbles);
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

get_rumbler_topic_arn = function(callback) {
  var rumbler_topic_arn = process.env.RUMBLER_TOPIC_ARN;

  if (rumbler_topic_arn === EMPTY) {
    throw new Error('There was no Rumbler SNS topic to which events should be published');
  }
  return rumbler_topic_arn;
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
