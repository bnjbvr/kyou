// Generated by CoffeeScript 1.7.1
var americano;

americano = require('americano-cozy');

module.exports = {
  name: "Weight- Withings",
  color: "#96A6A6",
  description: "Your weight in grams.",
  model: americano.getModel('WithingsScaleMeasure', {
    date: Date
  }),
  request: {
    map: function(doc) {
      return emit(doc.date.substring(0, 10), doc.weight);
    },
    reduce: function(key, values, rereduce) {
      return sum(values) / values.length;
    }
  }
};