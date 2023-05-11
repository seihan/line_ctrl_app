import 'package:flutter/material.dart';
import 'package:line_ctrl_app/ui/widgets/text_stream_widget.dart';

class ConnectionLogViewer extends StatelessWidget {
  final Stream<String> stream;
  const ConnectionLogViewer({
    Key? key,
    required this.stream,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 50),
      height: 115,
      child: TextStreamWidget(textStream: stream),
    );
  }
}
