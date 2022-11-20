import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vec;

/// A container with to view stream values
/// a [stream] is required which has to offers [Vector2] values
/// the output is a text widget with leading optional string list [names] or
/// 'x: value ... y: value'
/// only [x] and [y] values are printed
/// as long as no data is available a circular progress indicator is shown
class DataView extends StatelessWidget {
  final Stream<vec.Vector2>? stream;
  final List<String>? names;

  const DataView({Key? key, required this.stream, this.names})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<vec.Vector2>(
      stream: stream,
      initialData: vec.Vector2.zero(),
      builder: (c, snapshot) {
        if (snapshot.hasData) {
          return Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  (names != null)
                      ? Text('${names?.first}: ${snapshot.data?.x}')
                      : Text('x: ${snapshot.data?.x}\t'),
                  (names != null)
                      ? Text('${names?.last}: ${snapshot.data?.y}')
                      : Text('y: ${snapshot.data?.y}'),
                ],
              ),
              Row(
                children: <Widget>[
                  if (snapshot.data!.y < 0)
                    Container(
                      color: Colors.red,
                      height: 10,
                      width: snapshot.data!.y * -1,
                    ),
                  const Spacer(),
                  if (snapshot.data!.y > 0)
                    Container(
                      color: Colors.red,
                      height: 10,
                      width: snapshot.data!.y,
                    ),
                ],
              ),
              Container(
                color: Colors.blue,
                height: snapshot.data!.x,
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
