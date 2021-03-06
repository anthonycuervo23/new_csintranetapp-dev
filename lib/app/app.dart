import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;

// My imports
import 'package:new_csintranetapp/components/pdf_viewer/pdf_container_widget.dart';
import 'package:new_csintranetapp/screens/home_screen.dart';
import 'package:new_csintranetapp/services/navigation_service.dart';
import 'package:new_csintranetapp/utils/constants.dart';
import 'package:new_csintranetapp/providers/main_provider.dart';
import 'package:new_csintranetapp/screens/data_screen.dart';
import 'package:new_csintranetapp/utils/images.dart';

Future<Widget> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initialize();
  await FlutterDownloader.initialize(debug: true);
  await configLocalNotification();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark));

  return const MyApp();
}





Future<void> configLocalNotification() async {
  // Obtenemos el device ID y lo asignamos a nuestro usuario en OneSignal
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String deviceId;
  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    deviceId = androidInfo.androidId!;
    await setValue('deviceId', deviceId);
    log(deviceId);
    OneSignal.shared.setExternalUserId(deviceId);
  } else if (Platform.isIOS) {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    deviceId = iosInfo.identifierForVendor!;
    await setValue('deviceId', deviceId);
    log(deviceId);
    OneSignal.shared.setExternalUserId(deviceId);
  }

  // await OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
  await OneSignal.shared.setAppId(Constants.oneSignalKey);
  await OneSignal.shared.sendTag("DEBUG", true);
  await OneSignal.shared
      .promptUserForPushNotificationPermission(fallbackToSettings: true);



}

class GlobalScrollBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics();
  }
}

class MyHomePage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _MyHomePageState();

}

class _MyHomePageState extends State<MyHomePage> {
  static const platform = MethodChannel('flutter.native/notihelper');
  String _urlFromNotification = '';
  @override
  void initState() {

    OneSignal.shared
        .setNotificationOpenedHandler((OSNotificationOpenedResult result) async {
      bool notFirstTime = getBoolAsync('not_first_notification');
      var url = result.notification.additionalData?['url'];

      // await NavigationService.replaceTo(HomeScreen(myURL: url));

      developer.log(url,name: "URL");
      log('url - $url');
      Fluttertoast.showToast(msg: "-> "+url);
      responseFromNativeCode(url);
      await NavigationService.replaceTo(HomeScreen(myURL: url));
      // if (notFirstTime == true) {
      //   var url = result.notification.additionalData?['url'];
      //   if(!url.isEmpty) {
      //     if (url.endsWith('PDF') || url.endsWith('pdf')) {
      //       await NavigationService.navigateTo(PdfViewerScreen(
      //           title: url
      //               .split("/")
      //               .last
      //               .split(".")[0], url: url));
      //     } else {
      //       await NavigationService.replaceTo(HomeScreen(myURL: url));
      //     }
      //   }
      // } else {
      //   await setValue('not_first_notification', true);
      //
      //   var url = result.notification.additionalData?['url'];
      //
      //   if (url != null && !url.isEmpty) {
      //     if (url.toString().endsWith('PDF') || url.toString().endsWith('pdf')) {
      //       await NavigationService.navigateTo(PdfViewerScreen(
      //           title: url.toString().split("/").last.split(".")[0],
      //           url: url.toString()));
      //     } else {
      //       var url = Uri.parse(result.notification.additionalData?['url']);
      //       var queryParams = ((url.hasQuery) ? '&' : '?') +
      //           "device_id=" +
      //           getStringAsync('deviceId');
      //       var newUrl = url.toString() + queryParams;
      //       await NavigationService.replaceTo(HomeScreen(myURL: newUrl));
      //     }
      //   } else {
      //     url = Constants.url;
      //     await NavigationService.replaceTo(HomeScreen(myURL: url));
      //   }
      // }
    });

    super.initState();
  }
  Future<void> responseFromNativeCode(String url) async {
    // String response = "";
    // try {
    //   final String result = await platform.invokeMethod('getNotiUrl');
    //   response = result;
    //   log('result -  $result');
    // } on PlatformException catch (e) {
    //   response = "Failed to Invoke: '${e.message}'.";
    // }
    setState(() {
      _urlFromNotification = url;
    });
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Material(
  //     child: Center(
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //         children: [
  //           RaisedButton(
  //             child: Text('Call Native Method'),
  //             onPressed: responseFromNativeCode,
  //           ),
  //           Text(_responseFromNativeCode),
  //         ],
  //       ),
  //     ),
  //   );
  // }

@override
Widget build(BuildContext context) {
  precacheImage(AssetImage(Images.appIcon), context);
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => MainProvider(),
      ),
    ],
    child: MaterialApp(
      builder: (BuildContext context, Widget? widget) {
        return ScrollConfiguration(
          behavior: GlobalScrollBehavior(),
          child: widget!,
        );
      },
      navigatorKey: NavigationService.navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
          primaryColor: Colors.white,
          scaffoldBackgroundColor: const Color(0xff056dac),
          textTheme:
              GoogleFonts.robotoTextTheme(Theme.of(context).textTheme)),
      //Primero verificamos en DataScreen() que tenemos conexion a internet
      home:  DataScreen( url: _urlFromNotification),
    ),
  );
}

}
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MyHomePage(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }


  // @override
  // Widget build(BuildContext context) {
  //   precacheImage(AssetImage(Images.appIcon), context);
  //   return MultiProvider(
  //     providers: [
  //       ChangeNotifierProvider(
  //         create: (_) => MainProvider(),
  //       ),
  //     ],
  //     child: MaterialApp(
  //       builder: (BuildContext context, Widget? widget) {
  //         return ScrollConfiguration(
  //           behavior: GlobalScrollBehavior(),
  //           child: widget!,
  //         );
  //       },
  //       navigatorKey: NavigationService.navigatorKey,
  //       debugShowCheckedModeBanner: false,
  //       theme: ThemeData.light().copyWith(
  //           primaryColor: Colors.white,
  //           scaffoldBackgroundColor: const Color(0xff056dac),
  //           textTheme:
  //               GoogleFonts.robotoTextTheme(Theme.of(context).textTheme)),
  //       //Primero verificamos en DataScreen() que tenemos conexion a internet
  //       home: const DataScreen(),
  //     ),
  //   );
  // }
}
