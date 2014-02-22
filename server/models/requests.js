// Generated by CoffeeScript 1.7.1
var americano;

americano = require('americano-cozy');

module.exports = {
  mood: {
    all: americano.defaultRequests.all,
    statusByDay: function(doc) {
      var status;
      status = 0;
      if (doc.status === "bad") {
        status = 1;
      }
      if (doc.status === "neutral") {
        status = 2;
      }
      if (doc.status === "good") {
        status = 3;
      }
      return emit(doc.date.substring(0, 10), status);
    },
    byDay: function(doc) {
      return emit(doc.date.substring(0, 10), doc);
    }
  },
  tracker: {
    all: americano.defaultRequests.all
  },
  trackeramount: {
    nbByDay: function(doc) {
      return emit([doc.tracker, doc.date.substring(0, 10)], doc.amount);
    },
    byDay: function(doc) {
      return emit([doc.tracker, doc.date.substring(0, 10)], doc);
    }
  },
  dailynote: {
    byDay: function(doc) {
      return emit(doc.date.substring(0, 10), doc);
    }
  }
};
