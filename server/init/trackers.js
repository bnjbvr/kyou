// Generated by CoffeeScript 1.9.0
var fs, getTrackers, log, moment, normalizer, path, slugify;

fs = require('fs');

path = require('path');

moment = require('moment');

slugify = require('cozy-slug');

log = require('printit')({
  prefix: 'init tracker',
  date: true
});

normalizer = require('../lib/normalizer');

getTrackers = require('../lib/trackers').getTrackers;

module.exports = function(app) {
  var getController, recConfig;
  getController = function(tracker) {
    return function(req, res, next) {
      var options;
      options = {
        group: true
      };
      if (req.day != null) {
        options.startKey = req.day;
      }
      return tracker.model.rawRequest(tracker.requestName, options, function(err, rows) {
        var data;
        if (err) {
          return next(err);
        } else {
          data = normalizer.normalize(rows, req.day);
          return res.send(normalizer.toClientFormat(data));
        }
      });
    };
  };
  recConfig = function(trackers) {
    var slug, tracker;
    if (trackers.length > 0) {
      tracker = trackers.pop();
      log.info("configure tracker " + tracker.name);
      slug = slugify(tracker.name);
      path = "/basic-trackers/" + slug;
      if (tracker.requestName == null) {
        tracker.requestName = 'nbByDay';
      }
      app.get(path + "/:day", getController(tracker));
      log.info('Tracker controller added.');
      return tracker.model.defineRequest(tracker.requestName, tracker.request, function(err) {
        if (err) {
          log.error('Tracker request creation failed.');
          return recConfig();
        } else {
          log.info('Tracker request creation succeeded.');
          return recConfig(trackers);
        }
      });
    }
  };
  return recConfig(getTrackers().reverse());
};
