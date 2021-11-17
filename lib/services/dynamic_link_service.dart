import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:nb_utils/nb_utils.dart';

class DynamicLinkService {
  Future handleDynamicLinks() async {
    //Esto se llama si la app no esta abierta
    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();

    _handleDeepLink(data);

    // Esto se llama cuando la app esta en Background
    FirebaseDynamicLinks.instance.onLink(
      onSuccess: (PendingDynamicLinkData? dynamicLinkData) async {
        final Uri? deepLink = dynamicLinkData?.link;
        if (deepLink != null) {
          log('Ingresando desde Dynamic Link => $deepLink');
        }
      },
      onError: (OnLinkErrorException e) async {
        log('Dynamic Link Fallo: ${e.message}');
      },
    );
  }

  void _handleDeepLink(PendingDynamicLinkData? data) {
    final Uri? deepLink = data?.link;
    if (deepLink != null) {
      log('_handleDeepLink | deepLink: $deepLink');
    }
  }
}
