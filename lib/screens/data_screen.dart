import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// My imports
import 'package:new_csintranetapp/screens/splash_screen.dart';
import 'package:new_csintranetapp/components/network_aware_widget.dart';
import 'package:new_csintranetapp/screens/no_internet_screen.dart';
import 'package:new_csintranetapp/services/network_status_service.dart';

//TODO: corregir falla con iOS (NetworkStatus esta siempre offline)

class DataScreen extends StatelessWidget {
  const DataScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamProvider(
        create: (_) => NetworkStatusService().networkStatusController.stream,
        initialData: NetworkStatus.online,
        child: const NetworkAwareWidget(
          onlineChild: SplashScreen(),
          offlineChild: NoInternetConnection(),
        ),
      ),
    );
  }
}
