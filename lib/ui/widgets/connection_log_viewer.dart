import 'package:flutter/material.dart';
import 'package:line_ctrl_app/ui/widgets/text_stream_widget.dart';

import '../../models/bluetooth_connection_model.dart';

class ConnectionLogViewer extends StatelessWidget {
  final BluetoothConnectionModel model;
  const ConnectionLogViewer({
    Key? key,
    required this.model,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 50),
      height: 115,
      child: TextStreamWidget(textStream: model.log),
    );
  }
}
