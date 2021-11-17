import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:nb_utils/nb_utils.dart';

// ignore: must_be_immutable
class Loaders extends StatefulWidget {
  String? name;
  double size;
  Color? color;

  Loaders({
    Key? key,
    this.name = 'Circle',
    this.size = 30.0,
    this.color = Colors.white70,
  }) : super(key: key);

  @override
  _LoadersState createState() => _LoadersState();
}

class _LoadersState extends State<Loaders> {
  @override
  Widget build(BuildContext context) {
    var name = widget.name;

    Widget child = Container();

    if (name == 'RotatingPlane') {
      child = SpinKitRotatingPlain(
        size: widget.size,
        color: widget.color ?? context.primaryColor,
      );
    } else if (name == 'DoubleBounce') {
      child = SpinKitDoubleBounce(
        size: widget.size,
        color: widget.color ?? context.primaryColor,
      );
    } else if (name == 'Wave') {
      child = SpinKitWave(
        size: widget.size,
        color: widget.color ?? context.primaryColor,
      );
    } else if (name == 'WanderingCubes') {
      child = SpinKitWanderingCubes(
        size: widget.size,
        color: widget.color ?? context.primaryColor,
      );
    } else if (name == 'Pulse') {
      child = SpinKitPulse(
        size: widget.size,
        color: widget.color ?? context.primaryColor,
      );
    } else if (name == 'ChasingDots') {
      child = SpinKitChasingDots(
        size: widget.size,
        color: widget.color ?? context.primaryColor,
      );
    } else if (name == 'FadingFour') {
      child = SpinKitFadingFour(
        size: widget.size,
        color: widget.color ?? context.primaryColor,
      );
    } else if (name == 'Circle') {
      child = SpinKitCircle(
        size: widget.size,
        color: widget.color ?? context.primaryColor,
      );
    } else if (name == 'CubeGrid') {
      child = SpinKitCubeGrid(
        size: widget.size,
        color: widget.color ?? context.primaryColor,
      );
    } else if (name == 'FadingCircle') {
      child = SpinKitFadingCircle(
        size: widget.size,
        color: widget.color ?? context.primaryColor,
      );
    } else if (name == 'FoldingCube') {
      child = SpinKitFoldingCube(
        size: widget.size,
        color: widget.color ?? context.primaryColor,
      );
    } else if (name == 'RotatingCircle') {
      child = SpinKitRotatingCircle(
        size: widget.size,
        color: widget.color ?? context.primaryColor,
      );
    } else if (name == 'Ring') {
      child = SpinKitRing(
        size: widget.size,
        color: widget.color ?? context.primaryColor,
      );
    }
    return Center(
      child: Container(
        height: 150,
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}
