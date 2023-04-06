import 'package:flutter/material.dart';

class TextStreamWidget extends StatefulWidget {
  final Stream<String> textStream;

  const TextStreamWidget({Key? key, required this.textStream})
      : super(key: key);

  @override
  State createState() => _TextStreamWidgetState();
}

class _TextStreamWidgetState extends State<TextStreamWidget> {
  final List<String> _texts = [];

  @override
  void initState() {
    super.initState();
    widget.textStream.listen((String data) {
      setState(() {
        final lines = data.split('\n');
        _texts.addAll(lines);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView.builder(
        itemCount: _texts.length,
        itemBuilder: (context, index) {
          final reversedIndex = _texts.length - index - 1;
          return Text(_texts[reversedIndex]);
        },
      ),
    );
  }
}
