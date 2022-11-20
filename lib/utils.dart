/// A mapping function to map values from one range into another
double reScale({
  double value = 0,
  double inMin = 0,
  double inMax = 0,
  double outMin = 0,
  double outMax = 0,
}) {
  if (value >= inMin && value <= inMax) {
    return (value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
  } else {
    return 0;
  }
}