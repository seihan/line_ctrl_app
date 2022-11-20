import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart';

/// A container with to view stream values
/// a [stream] is required which has to offers [Vector2] values
/// the output is a text widget with leading optional string list [names] or
/// 'x: value ... y: value'
/// only [x] and [y] values are printed
/// as long as no data is available a circular progress indicator is shown
class DataView extends StatelessWidget {
  final Stream<Vector2>? stream;
  final List<String>? names;

  const DataView({Key? key, required this.stream, this.names})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Vector2>(
      stream: stream,
      initialData: Vector2.zero(),
      builder: (c, snapshot) {
        if (snapshot.hasData) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              (names != null)
                  ? Text('${names?.first}: ${snapshot.data?.x}')
                  : Text('x: ${snapshot.data?.x}\t'),
              (names != null)
                  ? Text('${names?.last}: ${snapshot.data?.y}')
                  : Text('y: ${snapshot.data?.y}'),
            ],
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
