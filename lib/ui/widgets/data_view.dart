import 'package:flutter/material.dart';
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
              Container(
                color: Colors.blue,
                height: x < (screenSize.height * 0.9)
                    ? x
                    : (screenSize.height * 0.9),
                width: 10,
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
