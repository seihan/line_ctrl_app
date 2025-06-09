import 'package:flutter/material.dart';
import 'package:line_ctrl_app/utils.dart';
import 'package:vector_math/vector_math.dart' as vec;

/// A container with to view stream values
/// a [stream] is required which has to offers [Vector2] values
/// the output is a text widget with leading optional string list [names] or
/// 'x: value ... y: value'
/// only [x] and [y] values are printed
/// two bars visualizes the vertical and horizontal axis by varying it's
/// sizes corresponding to the values limited by the screen dimensions
/// as long as no data is available a circular progress indicator is shown
class DataView extends StatelessWidget {
  final Stream<vec.Vector2>? stream;
  final List<String>? names;

  const DataView({Key? key, required this.stream, this.names})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return StreamBuilder<vec.Vector2>(
      stream: stream,
      initialData: vec.Vector2.zero(),
      builder: (c, snapshot) {
        if (snapshot.hasData) {
          double x = snapshot.data?.x ?? 0;
          x = Utils.reScale(
            value: x,
            inMin: -255,
            inMax: 255,
            outMin: -screenSize.height * 0.35,
            outMax: screenSize.height * 0.35,
          );
          double y = snapshot.data?.y ?? 0;
          return Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  (names != null)
                      ? Text('${names?.first}: ${x.toStringAsFixed(2)}')
                      : Text('x: ${x.toStringAsFixed(2)}\t'),
                  (names != null)
                      ? Text('${names?.last}: ${y.toStringAsFixed(2)}')
                      : Text('y: ${y.toStringAsFixed(2)}'),
                ],
              ),
              // horizontal bar
              y < 0
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          color: Colors.red,
                          height: 10,
                          width: y < (screenSize.width * 0.5)
                              ? y * -1
                              : (screenSize.width * 0.5),
                        ),
                        SizedBox(
                          width: screenSize.width * 0.5,
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          width: screenSize.width * 0.5,
                        ),
                        Container(
                          color: Colors.red,
                          height: 10,
                          width: y < (screenSize.width * 0.5)
                              ? y
                              : (screenSize.width * 0.5),
                        ),
                      ],
                    ),
              // vertical bar
              x < 0
                  ? Column(
                      // For negative x: bar from center to top
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          // Space above the bar in the top half.
                          // x is negative, so this is (screenSize.height * 0.5) - abs(x_scaled).
                          height: (screenSize.height * 0.5) + x,
                        ),
                        Container(
                          color: Colors.blue,
                          height: x * -1, // bar height, abs(x_scaled)
                          width: 10,
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: screenSize.height * 0.5,
                        ),
                        Container(
                          color: Colors.blue,
                          height: x < (screenSize.height * 0.5)
                              ? x
                              : (screenSize.height * 0.5),
                          width: 10,
                        ),
                      ],
                    ),
            ],
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
