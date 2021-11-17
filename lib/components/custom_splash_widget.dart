import 'dart:async';
import 'dart:core';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

//My imports
import 'package:new_csintranetapp/components/loaders.dart';

class SplashWidget extends StatefulWidget {
  /// Seconds to navigate after for time based navigation
  final int seconds;

  /// App title, shown in the middle of screen in case of no image available
  final Text title;

  /// Page background color
  final Color? backgroundColor;

  /// Style for the laodertext
  final TextStyle styleTextUnderTheLoader;

  /// The page where you want to navigate if you have chosen time based navigation
  final dynamic navigateAfterSeconds;

  /// Main image size
  final double? photoSize;

  /// Triggered if the user clicks the screen
  final dynamic onClick;

  /// Main image mainly used for logos and like that
  final Image? image;

  /// Loading text, default: "Loading"
  final Text loadingText;

  ///  Background image for the entire screen
  final ImageProvider? imageBackground;

  /// Background gradient for the entire screen
  final Gradient? gradientBackground;

  /// Whether to display a loader or not
  final bool useLoader;

  /// Custom page route if you have a custom transition you want to play
  final Route? pageRoute;

  /// RouteSettings name for pushing a route with custom name (if left out in MaterialApp route names) to navigator stack (Contribution by Ramis Mustafa)
  final String? routeName;

  /// Loader color
  final Color loaderColor;

  /// Loader Type
  final String? loaderType;

  /// Loader Size
  final double loaderSize;

  /// Use one of the provided factory constructors instead of.
  @protected
  const SplashWidget({
    Key? key,
    this.loaderColor = Colors.white70,
    this.seconds = 3,
    this.photoSize,
    this.loaderType,
    this.loaderSize = 30,
    this.pageRoute,
    this.onClick,
    this.navigateAfterSeconds,
    this.title = const Text(''),
    this.backgroundColor,
    this.styleTextUnderTheLoader = const TextStyle(
        fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.black),
    this.image,
    this.loadingText = const Text(""),
    this.imageBackground,
    this.gradientBackground,
    this.useLoader = true,
    this.routeName,
  }) : super(key: key);

  factory SplashWidget.timer(
          {int seconds = 2,
          Color? loaderColor,
          String? loaderType,
          Color? backgroundColor,
          double? photoSize,
          double? loaderSize,
          Text? loadingText,
          Image? image,
          Route? pageRoute,
          dynamic onClick,
          dynamic navigateAfterSeconds,
          Text? title,
          TextStyle? styleTextUnderTheLoader,
          ImageProvider? imageBackground,
          Gradient? gradientBackground,
          bool? useLoader,
          String? routeName}) =>
      SplashWidget(
        loaderColor: loaderColor ?? Colors.white70,
        seconds: seconds,
        photoSize: photoSize,
        loaderSize: loaderSize ?? 30,
        loaderType: loaderType,
        loadingText: loadingText ?? const Text(''),
        backgroundColor: backgroundColor,
        image: image,
        pageRoute: pageRoute,
        onClick: onClick,
        navigateAfterSeconds: navigateAfterSeconds,
        title: title ?? const Text(''),
        styleTextUnderTheLoader: styleTextUnderTheLoader ??
            const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.black),
        imageBackground: imageBackground,
        gradientBackground: gradientBackground,
        useLoader: useLoader ?? true,
        routeName: routeName,
      );

  factory SplashWidget.network(
          {Color? loaderColor,
          Color? backgroundColor,
          double? photoSize,
          double? loaderSize,
          Text? loadingText,
          String? loaderType,
          Image? image,
          Route? pageRoute,
          dynamic onClick,
          dynamic navigateAfterSeconds,
          Text? title,
          TextStyle? styleTextUnderTheLoader,
          ImageProvider? imageBackground,
          Gradient? gradientBackground,
          bool? useLoader,
          String? routeName}) =>
      SplashWidget(
        loaderColor: loaderColor ?? Colors.white70,
        photoSize: photoSize,
        loadingText: loadingText ?? const Text(''),
        backgroundColor: backgroundColor,
        image: image,
        loaderType: loaderType,
        pageRoute: pageRoute,
        loaderSize: loaderSize ?? 30,
        onClick: onClick,
        navigateAfterSeconds: navigateAfterSeconds,
        title: title ?? const Text(''),
        styleTextUnderTheLoader: styleTextUnderTheLoader ??
            const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.black),
        imageBackground: imageBackground,
        gradientBackground: gradientBackground,
        useLoader: useLoader ?? true,
        routeName: routeName,
      );

  @override
  _SplashWidgetState createState() => _SplashWidgetState();
}

class _SplashWidgetState extends State<SplashWidget> {
  @override
  void initState() {
    super.initState();
    if (widget.routeName != null &&
        widget.routeName is String &&
        widget.routeName![0] != '/') {
      throw ArgumentError(
          "widget.routeName must be a String beginning with forward slash (/)");
    }
    Timer(Duration(seconds: widget.seconds), () {
      if (widget.navigateAfterSeconds is String) {
        Navigator.of(context).pushReplacementNamed(widget.navigateAfterSeconds);
      } else if (widget.navigateAfterSeconds is Widget) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => widget.navigateAfterSeconds));
      } else {
        throw ArgumentError(
            'widget.navigateAfterSeconds must either be a String or Widget');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InkWell(
        onTap: widget.onClick,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            //background
            Container(
              decoration: BoxDecoration(
                image: widget.imageBackground == null
                    ? null
                    : DecorationImage(
                        fit: BoxFit.cover,
                        image: widget.imageBackground!,
                      ),
                gradient: widget.gradientBackground,
                color: widget.backgroundColor,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ZoomOut(
                    from: 2,
                    delay: const Duration(milliseconds: 2000),
                    duration: const Duration(milliseconds: 1000),
                    child: widget.title),
                const Padding(
                  padding: EdgeInsets.only(top: 10.0),
                ),
                Align(
                  alignment: Alignment.center,
                  child: ZoomOut(
                    from: 2,
                    delay: const Duration(milliseconds: 2000),
                    duration: const Duration(milliseconds: 1000),
                    child: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: Hero(
                        tag: "splashscreenImage",
                        child: Container(child: widget.image),
                      ),
                      radius: widget.photoSize,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                !widget.useLoader
                    ? Container()
                    : ZoomOut(
                        delay: const Duration(milliseconds: 2000),
                        child: Hero(
                          tag: 'loader',
                          child: Loaders(
                            name: widget.loaderType,
                            color: widget.loaderColor,
                            size: widget.loaderSize,
                          ),
                        ),
                      ),
                const Padding(
                  padding: EdgeInsets.only(top: 50.0),
                ),
                widget.loadingText
              ],
            ),
          ],
        ),
      ),
    );
  }
}
