class Utils {
  /// A mapping function to map values from one range into another
  static double reScale({
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

  /// Returns the 0 if the [min] or [max] constrain is reached
  static int deadZone({
    int value = 0,
    int min = 0,
    int max = 0,
  }) {
    if (value < max && value > min) {
      value = 0;
    }
    return value;
  }
}
