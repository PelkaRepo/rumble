const LambdaTester = require('lambda-tester');
const rumbler = require('../index').rumbler;
var expect = require("chai").expect;
var index = require("../index");

describe('rumbler', function() {
  beforeEach(function() {
    process.env.SOURCE_URL = 'https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/2.5_day.geojson';
  });

  it('test success', function() {
    return LambdaTester(rumbler)
      .event({
        name: 'foo-bar'
      })
      .expectResult();
  });
});

describe('index', function() {
  beforeEach(function() {
    process.env.SOURCE_URL = 'https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/2.5_day.geojson';
  });

  describe('URL source retrieval', function() {
    it('can retrieve a source URL if present in Lambda environment variables', function() {
      expect(get_source_url()).to.equal('https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/2.5_day.geojson');
    });
  });

  describe('URL source retrieval', function() {
    it('to throw an error if source URL is not present', function() {
      process.env.SOURCE_URL = '';
      expect(function() {
        get_source_url();
      }).to.throw('There was no source API URL from which to access seismic data');
    });
  });

  describe('USGS seismic data parsing', function() {
    beforeEach(function() {
      malformedTestBody = '[["type": "hello"]';
      testBody = {
        "type": "FeatureCollection",
        "metadata": {
          "generated": 1516867387000,
          "url": "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/2.5_day.geojson",
          "title": "USGS Magnitude 2.5+ Earthquakes, Past Day",
          "status": 200,
          "api": "1.5.8",
          "count": 69
        },
        "features": [{
          "type": "Feature",
          "properties": {
            "mag": 4,
            "place": "275km ESE of Kodiak, Alaska",
            "time": 1516864753230,
            "updated": 1516865568040,
            "tz": -600,
            "url": "https://earthquake.usgs.gov/earthquakes/eventpage/us2000cp6u",
            "detail": "https://earthquake.usgs.gov/earthquakes/feed/v1.0/detail/us2000cp6u.geojson",
            "felt": null,
            "cdi": null,
            "mmi": null,
            "alert": null,
            "status": "reviewed",
            "tsunami": 0,
            "sig": 246,
            "net": "us",
            "code": "2000cp6u",
            "ids": ",us2000cp6u,",
            "sources": ",us,",
            "types": ",geoserve,origin,phase-data,",
            "nst": null,
            "dmin": 2.556,
            "rms": 0.54,
            "gap": 206,
            "magType": "mb",
            "type": "earthquake",
            "title": "M 4.0 - 275km ESE of Kodiak, Alaska"
          },
          "geometry": {
            "type": "Point",
            "coordinates": [-148.5459,
              56.4847,
              22.49
            ]
          },
          "id": "us2000cp6u"
        }, {
          "type": "Feature",
          "properties": {
            "mag": 4,
            "place": "275km ESE of Bend, Oregon",
            "time": 1516864753230,
            "updated": 1516865568040,
            "tz": -600,
            "url": "https://earthquake.usgs.gov/earthquakes/eventpage/us2000cp6u",
            "detail": "https://earthquake.usgs.gov/earthquakes/feed/v1.0/detail/us2000cp6u.geojson",
            "felt": null,
            "cdi": null,
            "mmi": null,
            "alert": null,
            "status": "reviewed",
            "tsunami": 0,
            "sig": 246,
            "net": "us",
            "code": "2000cp6u4",
            "ids": ",us2000cp6u5,",
            "sources": ",us,",
            "types": ",geoserve,origin,phase-data,",
            "nst": null,
            "dmin": 2.556,
            "rms": 0.54,
            "gap": 206,
            "magType": "mb",
            "type": "earthquake",
            "title": "M 4.0 - 275km ESE of Bend, Oregon"
          },
          "geometry": {
            "type": "Point",
            "coordinates": [-148.5459,
              56.4847,
              22.49
            ]
          },
          "id": "us2000cp6u4"
        }],
        "bbox": [-178.3749, -59.2085,
          0,
          166.4776,
          67.5743,
          478.75
        ]
      }
    });

    it('to be a list containing locations that incurred seismic activity', function() {
      const expectedList = ["Alaska", "Oregon"];
      expect(parse_usgs_rumbles(testBody)).to.deep.equal(expectedList);
    });

    it('to not allow invalid JSON by throwing a special error', function() {
      expect(function() {
        parse_usgs_rumbles(malformedTestBody);
      }).to.throw('Seismic data for USGS source did not contain validly parsable data:');
    });
  });
});
