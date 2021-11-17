import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

// My imports
import 'package:new_csintranetapp/components/custom_splash_widget.dart';
import 'package:new_csintranetapp/screens/home_screen.dart';
import 'package:new_csintranetapp/utils/constants.dart';
import 'package:new_csintranetapp/utils/images.dart';
import 'package:new_csintranetapp/utils/strings.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({
    Key? key,
  }) : super(key: key);

  String initialURL() {
    bool notFirstTime = getBoolAsync('not_first_time');
    if (notFirstTime == true) {
      return Constants.url;
    } else {
      setValue('not_first_time', true);
      var url = Uri.parse(Constants.url);
      var queryParams = ((url.hasQuery) ? '&' : '?') +
          "device_id=" +
          getStringAsync('deviceId');
      var newUrl = url.toString() + queryParams;
      return newUrl;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SplashWidget(
      seconds: 3,
      navigateAfterSeconds: HomeScreen(myURL: initialURL()),
      title: Text(
        AppStrings.welcomeText,
        style: const TextStyle(
            fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.white),
      ),
      image: Image.asset(Images.appIcon),
      photoSize: MediaQuery.of(context).size.width * 0.25,
      loaderType: 'Circle',
      loaderSize: 60,
    );
  }
}
