import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:new_version/new_version.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'dart:isolate';

// My imports
import 'package:new_csintranetapp/utils/strings.dart';
import 'package:new_csintranetapp/components/pdf_viewer/pdf_container_widget.dart';
import 'package:new_csintranetapp/components/loaders.dart';
import 'package:new_csintranetapp/providers/main_provider.dart';
import 'package:new_csintranetapp/screens/no_internet_screen.dart';
import 'package:new_csintranetapp/utils/constants.dart';
import 'package:new_csintranetapp/utils/ui_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key? key,
    required this.myURL,
  }) : super(key: key);

  final String myURL;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  InAppWebViewController? webViewController;
  PullToRefreshController? pullToRefreshController;

  final ReceivePort _port = ReceivePort();
  late dynamic _localPath;
  bool _permissionReady = false;
  bool isWasConnectionLoss = false;
  bool isPermissionGranted = false;

  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
          useShouldOverrideUrlLoading: true,
          userAgent: !Platform.isAndroid ? Constants.userAgent : 'random',
          mediaPlaybackRequiresUserGesture: false,
          allowFileAccessFromFileURLs: true,
          useOnDownloadStart: true,
          javaScriptCanOpenWindowsAutomatically: true,
          javaScriptEnabled: true,
          supportZoom: true,
          incognito: false),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  @override
  void initState() {
    init();
    _bindBackgroundIsolate();
    super.initState();
  }

  // Verificamos permiso para descargar documentos
  Future<bool> checkPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.status;
      if (status != PermissionStatus.granted) {
        final result = await Permission.storage.request();
        if (result == PermissionStatus.granted) {
          isPermissionGranted = true;
          setState(() {});
          return true;
        }
      } else {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    _unbindBackgroundIsolate();
    init();
    super.dispose();
  }

  Future<void> init() async {
    if (webViewController != null) {
      await webViewController!
          .loadUrl(urlRequest: URLRequest(url: Uri.parse(widget.myURL)));
      print('test ${Uri.parse(widget.myURL)}');
    } else {
      log("aun no se ha creado el controlador");
    }

    FlutterDownloader.registerCallback(downloadCallback);

    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(color: Colors.blueAccent, enabled: true),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(
              urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );

    //Verificamos si se pierde la conexion
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        setState(() {
          isWasConnectionLoss = true;
        });
      } else {
        setState(() {
          isWasConnectionLoss = false;
        });
      }
    });
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      init();
    });
  }

  void _bindBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send([id, status, progress]);
  }

  @override
  Widget build(BuildContext context) {
    Future<bool> _exitApp() async {
      if (await webViewController!.canGoBack()) {
        webViewController!.goBack();
        return false;
      } else {
        return showCustomDialog(
          context: context,
          title: AppStrings.closeAppText,
          buttonActions: ['No', 'Si'],
          onPressed1: () => Navigator.of(context).pop(false),
          onPressed2: () => exit(0),
        );
      }
    }

    Widget mLoadWeb({String? myURL}) {
      final MainProvider mainProvider =
          Provider.of<MainProvider>(context, listen: false);
      return SafeArea(
        child: Stack(
          children: [
            InAppWebView(
                initialUrlRequest: URLRequest(url: Uri.parse(widget.myURL)),
                initialOptions: options,
                pullToRefreshController: pullToRefreshController,
                onWebViewCreated: (controller) async {
                  webViewController = controller;
                  final newVersion = NewVersion(
                    iOSId: Constants.packageName,
                    androidId: Constants.packageName,
                  );

                  final VersionStatus? status =
                      await newVersion.getVersionStatus();
                  if (status != null) {
                    newVersion.showUpdateDialog(
                      context: context,
                      versionStatus: status,
                      dialogTitle: AppStrings.updateTitle,
                      dialogText: AppStrings.updateText(status),
                      updateButtonText: AppStrings.updateButtonText,
                      dismissButtonText: AppStrings.dismissButtonText,
                    );
                  }
                },
                onLoadStart: (controller, url) {
                  log("onLoadStart");
                  mainProvider.isLoading = true;

                  // return Constants.loginUrl(getStringAsync('deviceId'));
                  //}
                  // if (uri == 'https://csintranet.csi.cat/_util/login/?next=/' ||
                  //     uri ==
                  //         'https://csintranet.csi.cat/_util/login/?next=/news/') {
                  //   controller.loadUrl(
                  //       urlRequest: URLRequest(
                  //           url: Uri.parse(
                  //               '$uri&get=${getStringAsync('deviceId')}')));
                  // }
                },
                onLoadStop: (controller, url) async {
                  log("onLoadStop");
                  mainProvider.isLoading = false;
                  pullToRefreshController!.endRefreshing();
                  setState(() {});
                },
                onLoadError: (controller, url, code, message) {
                  mainProvider.isLoading = false;
                  pullToRefreshController!.endRefreshing();
                  setState(() {});
                },
                shouldOverrideUrlLoading: (controller, navigationAction) async {
                  var uri = navigationAction.request.url;
                  var url = navigationAction.request.url.toString();
                  log('URL => ${Uri.parse(url)}');
                  if (url.endsWith('PDF') || url.endsWith('pdf')) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => PdfViewerScreen(
                                title: url.split("/").last.split(".")[0],
                                url: url)));
                    mainProvider.isPDFView = true;
                    return NavigationActionPolicy.ALLOW;
                  }

                  if (Platform.isAndroid && url.contains("intent")) {
                    if (url.contains("maps")) {
                      var mNewURL = url.replaceAll("intent://", "https://");
                      if (await canLaunch(mNewURL)) {
                        await launch(mNewURL);
                        return NavigationActionPolicy.CANCEL;
                      }
                    } else {
                      String id = url.substring(
                          url.indexOf('id%3D') + 5, url.indexOf('#Intent'));
                      await StoreRedirect.redirect(androidAppId: id);
                      return NavigationActionPolicy.CANCEL;
                    }
                  } else if (url.contains("linkedin.com") ||
                      url.contains("market://") ||
                      url.contains("whatsapp://") ||
                      url.contains("truecaller://") ||
                      url.contains("facebook.com") ||
                      url.contains("twitter.com") ||
                      url.contains("pinterest.com") ||
                      url.contains("snapchat.com") ||
                      url.contains("instagram.com") ||
                      url.contains("play.google.com") ||
                      url.contains("mailto:") ||
                      url.contains("tel:") ||
                      url.contains("messenger.com")) {
                    url = Uri.encodeFull(url);
                    try {
                      if (await canLaunch(url)) {
                        launch(url);
                      } else {
                        launch(url);
                      }
                      return NavigationActionPolicy.CANCEL;
                    } catch (e) {
                      launch(url);
                      return NavigationActionPolicy.CANCEL;
                    }
                  } else if (![
                    "http",
                    "https",
                    "chrome",
                    "data",
                    "javascript",
                    "about"
                  ].contains(uri!.scheme)) {
                    if (await canLaunch(url)) {
                      await launch(
                        url,
                      );
                      return NavigationActionPolicy.CANCEL;
                    }
                  }
                  return NavigationActionPolicy.ALLOW;
                },
                onDownloadStart: (controller, url) {
                  if (!mainProvider.isPDFView) {
                    checkPermission().then((hasGranted) async {
                      _permissionReady = hasGranted;
                      if (_permissionReady == true) {
                        if (Platform.isIOS) {
                          _localPath = await getApplicationDocumentsDirectory();
                        } else {
                          _localPath = "/storage/emulated/0/Download";
                        }
                        log("local Path" + _localPath);

                        final taskId = await FlutterDownloader.enqueue(
                          url: url.toString(),
                          savedDir: _localPath,
                          showNotification: true,
                          openFileFromNotification: true,
                          requiresStorageNotLow: true,
                        );
                      }
                    });
                  }
                },
                // solicitamos permiso para el GPS
                androidOnGeolocationPermissionsShowPrompt:
                    (InAppWebViewController controller, String origin) async {
                  await Permission.location.request();
                  return Future.value(GeolocationPermissionShowPromptResponse(
                      origin: origin, allow: true, retain: true));
                },
                // opcional => Solicitamos permiso para subir un video o foto.
                androidOnPermissionRequest: (InAppWebViewController controller,
                    String origin, List<String> resources) async {
                  if (resources.isNotEmpty) {
                  } else {
                    resources.forEach((element) async {
                      if (element.contains("AUDIO_CAPTURE")) {
                        await Permission.microphone.request();
                      }
                      if (element.contains("VIDEO_CAPTURE")) {
                        await Permission.camera.request();
                      }
                    });
                  }
                  return PermissionRequestResponse(
                      resources: resources,
                      action: PermissionRequestResponseAction.GRANT);
                }).visible(isWasConnectionLoss == false),
            const NoInternetConnection().visible(isWasConnectionLoss == true),
            //Loader can receive a name to change the loader to display
            Loaders().center().visible(mainProvider.isLoading)
          ],
        ),
      );
    }

    Widget mBody() {
      return SafeArea(
        child: Scaffold(
          body: mLoadWeb(myURL: widget.myURL),
        ),
      );
    }

    return WillPopScope(
      onWillPop: _exitApp,
      child: mBody(),
    );
  }
}
