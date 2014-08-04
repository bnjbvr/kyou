// Generated by CoffeeScript 1.7.1
var americano;

americano = require('americano-cozy');

module.exports = {
  name: "Blood Pressure (diastolic)",
  color: "#2FAD5B",
  description: "Your diastolic blood pressure.",
  model: americano.getModel('BloodPressure', {
    date: Date
  }),
  request: {
    map: function(doc) {
      return emit(doc.date.substring(0, 10), doc.diastolic);
    },
    reduce: function(key, values, rereduce) {
      return sum(values) / values.length;
    }
  }
};
