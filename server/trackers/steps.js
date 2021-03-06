// Generated by CoffeeScript 1.9.0
var americano;

americano = require('americano-cozy');

module.exports = {
  name: "Steps",
  color: "#D35400",
  description: "Number of steps you walked every day. Data should be imported from Jawbone\nKonnector.",
  model: americano.getModel('Steps', {
    date: Date
  }),
  request: {
    map: function(doc) {
      return emit(doc.date.substring(0, 10), doc.steps);
    },
    reduce: function(key, values, rereduce) {
      return sum(values);
    }
  }
};
