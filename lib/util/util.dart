const int rangeMin = 0;
const int rangeMax = 100;

double convertRange({
  required int oldMax,
  required int oldMin,
  int newMax = rangeMax,
  int newMin = rangeMin,
  required int oldValue,
}) {
  var oldRange = (oldMax - oldMin);
  var newRange = (newMax - newMin);
  var newValue = (((oldValue - oldMin) * newRange) / oldRange) + newMin;
  return newValue;
}