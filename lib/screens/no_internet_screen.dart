import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

// My imports
import 'package:new_csintranetapp/utils/images.dart';
import 'package:new_csintranetapp/components/loaders.dart';
import 'package:new_csintranetapp/utils/strings.dart';

class NoInternetConnection extends StatelessWidget {
  const NoInternetConnection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.delayed(const Duration(milliseconds: 500)),
      builder: (context, snapshot) {
        // Verificamos si el tiempo ya paso
        if (snapshot.connectionState == ConnectionState.done) {
          return Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(Images.icWifi,
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                    color: Colors.white70),
                30.height,
                Text(AppStrings.noNetwork,
                    style: boldTextStyle(size: 24, color: Colors.white)),
                8.height,
                Text(AppStrings.checkNetwork,
                        style:
                            secondaryTextStyle(size: 16, color: Colors.white54),
                        textAlign: TextAlign.center)
                    .paddingOnly(left: 16, right: 16),
              ],
            ),
          );
        } else {
          return Hero(
            tag: 'loader',
            child: Loaders(name: 'Circle', size: 80).center(),
          );
        }
      },
    );
  }
}
