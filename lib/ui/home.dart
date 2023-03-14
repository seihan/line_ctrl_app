import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_ctrl_app/models/sensor_model.dart';
import 'package:line_ctrl_app/models/steering_model.dart';
import 'package:line_ctrl_app/ui/widgets/control_buttons.dart';
import 'package:line_ctrl_app/ui/widgets/data_view.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    return ChangeNotifierProvider<SteeringModel>(
      create: (_) => SteeringModel(),
      child: Consumer<SteeringModel>(
        builder: (context, model, child) {
          return model.connected ? _mainWidget(model) : secondWidget(model);
        },
      ),
    );
  }

  Widget secondWidget(SteeringModel model) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Consumer<SensorController>(
              builder: (context, model, child) {
                return DataView(
                  stream: model.vector2,
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.red,
        child: const Icon(Icons.stop),
      ),
    );
  }

  Widget _mainWidget(SteeringModel model) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(30),
              alignment: Alignment.bottomLeft,
              child: ControlButtons(
                title: 'left motor',
                value: model.leftValue,
                size: 69,
                active: model.paused,
                up: model.leftUp,
                down: model.leftDown,
                left: model.leftLeft,
                right: model.leftRight,
                middle: model.leftStop,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(30),
              alignment: Alignment.bottomRight,
              child: ControlButtons(
                title: 'right motor',
                value: model.rightValue,
                size: 69,
                active: model.paused,
                up: model.rightUp,
                down: model.rightDown,
                left: model.rightLeft,
                right: model.rightRight,
                middle: model.rightStop,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: model.togglePause,
        child: Icon(
          model.paused ? Icons.play_arrow : Icons.pause,
        ),
      ),
    );
  }
}
