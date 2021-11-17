import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

// My imports
import 'package:new_csintranetapp/services/network_status_service.dart';

class NetworkAwareWidget extends StatelessWidget {
  final Widget onlineChild;
  final Widget offlineChild;

  const NetworkAwareWidget({
    Key? key,
    required this.onlineChild,
    required this.offlineChild,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    NetworkStatus networkStatus = Provider.of<NetworkStatus>(context);
    log(networkStatus);
    if (networkStatus == NetworkStatus.online) {
      return onlineChild;
    } else {
      return offlineChild;
    }
  }
}
