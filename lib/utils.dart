import 'dart:typed_data';

class Utils {
  /// A mapping function to map values from one range into another
  static double reScale({
    required double value,
    required double inMin,
    required double inMax,
    required double outMin,
    required double outMax,
  }) {
    if (inMax == inMin) {
      return outMin;
    }
    if (value < inMin) value = inMin;
    if (value > inMax) value = inMax;
    return (value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
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

  /// Concatenate two signed int16 values into unsigned int8 list
  static Uint8List concatSignedInt16Values(int value1, int value2) {
    final byteData = ByteData(4);
    byteData.setInt16(
      0,
      value1,
      Endian.little,
    ); // value1: bytes[0]=LSB, bytes[1]=MSB
    byteData.setInt16(
      2,
      value2,
      Endian.little,
    ); // value2: bytes[2]=LSB, bytes[3]=MSB
    return byteData.buffer
        .asUint8List(); // Resulting Uint8List: [LSB_val1, MSB_val1, LSB_val2, MSB_val2]
  }
}
