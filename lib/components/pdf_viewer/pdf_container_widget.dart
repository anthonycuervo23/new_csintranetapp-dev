import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

// My imports
import 'package:new_csintranetapp/utils/strings.dart';
import 'package:new_csintranetapp/providers/main_provider.dart';
import 'package:new_csintranetapp/components/pdf_viewer/pdf_search_toolbar.dart';
import 'package:new_csintranetapp/components/pdf_viewer/pdf_toolbar.dart';
import 'package:new_csintranetapp/utils/ui_utils.dart';

class PdfViewerScreen extends StatefulWidget {
  static const routeName = '/pdfViewer';

  const PdfViewerScreen({
    Key? key,
    required this.title,
    required this.url,
  }) : super(key: key);

  final String title;
  final String url;

  @override
  _PdfViewerScreenState createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final FocusNode _focusNode = FocusNode()..requestFocus();
  final GlobalKey<ToolbarState> _toolbarKey = GlobalKey();
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  final GlobalKey<SearchToolbarState> _textSearchKey = GlobalKey();
  bool _canShowPdf = false;
  LocalHistoryEntry? _historyEntry;

  OverlayEntry? _selectionOverlayEntry;
  PdfTextSelectionChangedDetails? _textSelectionDetails;
  bool _canShowToast = false;
  bool _canShowToolbar = true;
  PdfViewerController? _pdfViewerController;

  @override
  void initState() {
    _pdfViewerController = PdfViewerController();
    super.initState();
  }

  /// Mostrar opcion de copiar al seleccionar Texto
  void _showContextMenu(BuildContext context, Offset? offset) {
    final RenderBox renderBoxContainer =
        context.findRenderObject()! as RenderBox;
    if (renderBoxContainer != null) {
      const List<BoxShadow> boxShadows = <BoxShadow>[
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.14),
          blurRadius: 2,
          offset: Offset(0, 0),
        ),
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.12),
          blurRadius: 2,
          offset: Offset(0, 2),
        ),
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.2),
          blurRadius: 3,
          offset: Offset(0, 1),
        ),
      ];
      final PdfTextSelectionChangedDetails? details = _textSelectionDetails;
      final Offset containerOffset = renderBoxContainer.localToGlobal(
        renderBoxContainer.paintBounds.topLeft,
      );
      if (details != null &&
              containerOffset.dy <
                  details.globalSelectedRegion!.topLeft.dy - 55 ||
          (containerOffset.dy <
                  details!.globalSelectedRegion!.center.dy - (48 / 2) &&
              details.globalSelectedRegion!.height > 100)) {
        double top = 0.0;
        double left = 0.0;
        final Rect globalSelectedRect = details.globalSelectedRegion!;
        if (offset != null) {
          top = offset.dy;
          left = offset.dx;
        } else if ((globalSelectedRect.top) >
            MediaQuery.of(context).size.height / 2) {
          top = globalSelectedRect.topLeft.dy - 55;
          left = globalSelectedRect.bottomLeft.dx;
        } else {
          top = globalSelectedRect.height > 100
              ? globalSelectedRect.center.dy - (48 / 2)
              : globalSelectedRect.topLeft.dy - 55;
          left = globalSelectedRect.height > 100
              ? globalSelectedRect.center.dx - (100 / 2)
              : globalSelectedRect.bottomLeft.dx;
        }
        final OverlayState? _overlayState =
            Overlay.of(context, rootOverlay: true);
        _selectionOverlayEntry = OverlayEntry(
          builder: (BuildContext context) => Positioned(
            top: top,
            left: left,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFFFFFF),
                boxShadow: boxShadows,
              ),
              constraints:
                  const BoxConstraints.tightFor(width: 100, height: 48),
              child: TextButton(
                onPressed: () async {
                  _handleContextMenuClose();
                  _pdfViewerController!.clearSelection();
                  if (_textSearchKey.currentState != null &&
                      _textSearchKey
                          .currentState!.pdfTextSearchResult.hasResult) {
                    setState(() {
                      _canShowToolbar = false;
                    });
                  }
                  await Clipboard.setData(
                      ClipboardData(text: details.selectedText));
                  setState(() {
                    _canShowToast = true;
                  });
                  await Future<dynamic>.delayed(const Duration(seconds: 1));
                  setState(() {
                    _canShowToast = false;
                  });
                },
                child: Text(
                  AppStrings.copy,
                  style:
                      const TextStyle(fontSize: 17, color: Color(0xFF000000)),
                ),
              ),
            ),
          ),
        );
        _overlayState?.insert(_selectionOverlayEntry!);
      }
    }
  }

  /// Asegurar el historial de entrada de la búsqueda de texto.
  void _ensureHistoryEntry() {
    if (_historyEntry == null) {
      final ModalRoute<dynamic>? route = ModalRoute.of(context);
      if (route != null) {
        _historyEntry = LocalHistoryEntry(onRemove: _handleHistoryEntryRemoved);
        route.addLocalHistoryEntry(_historyEntry!);
      }
    }
  }

  /// Elimina la entrada del historial para la búsqueda de texto.
  void _handleHistoryEntryRemoved() {
    _textSearchKey.currentState?.pdfTextSearchResult.clear();
    _historyEntry = null;
  }

  /// Comprobar y cierrar la opcion de copiar la selección de texto.
  void _handleContextMenuClose() {
    if (_selectionOverlayEntry != null) {
      _selectionOverlayEntry?.remove();
      _selectionOverlayEntry = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final MainProvider mainProvider = Provider.of(context);
    PreferredSizeWidget appBar = AppBar(
      flexibleSpace: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.only(left: 50),
            child: Semantics(
              label: widget.title,
              child: RawKeyboardListener(
                focusNode: _focusNode,
                child: Toolbar(
                  key: _toolbarKey,
                  showTooltip: true,
                  controller: _pdfViewerController,
                  onTap: (Object toolbarItem) {
                    if (_pdfViewerKey.currentState!.isBookmarkViewOpen) {
                      Navigator.pop(context);
                    }
                    if (toolbarItem.toString() == 'Bookmarks') {
                      setState(() {
                        _canShowToolbar = false;
                      });
                      _pdfViewerKey.currentState?.openBookmarkView();
                    } else if (toolbarItem.toString() == 'Search') {
                      setState(() {
                        _canShowToolbar = false;
                        _ensureHistoryEntry();
                      });
                    }
                    if (toolbarItem.toString() != 'Bookmarks') {
                      _handleContextMenuClose();
                    }
                    if (toolbarItem != 'Jump to the page') {
                      final FocusScopeNode currentFocus =
                          FocusScope.of(context);
                      if (!currentFocus.hasPrimaryFocus) {
                        currentFocus.requestFocus(FocusNode());
                      }
                    }
                  },
                ),
              ),
            ),
          )
        ],
      ),
      leading: IconButton(
        onPressed: () {
          mainProvider.isPDFView = false;
          Navigator.maybePop(context);
        },
        icon: const Icon(Icons.arrow_back),
      ),
      automaticallyImplyLeading: true,
      backgroundColor: context.scaffoldBackgroundColor,
      elevation: 1,
    );

    appBar = _canShowToolbar
        ? appBar
        : !_pdfViewerKey.currentState!.isBookmarkViewOpen
            ? AppBar(
                flexibleSpace: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SearchToolbar(
                      key: _textSearchKey,
                      canShowTooltip: true,
                      controller: _pdfViewerController,
                      primaryColor: context.scaffoldBackgroundColor,
                      onTap: (Object toolbarItem) async {
                        if (toolbarItem.toString() == 'Cancel Search') {
                          setState(() {
                            _canShowToolbar = true;
                            if (Navigator.canPop(context)) {
                              Navigator.of(context).maybePop();
                            }
                          });
                        }
                        if (toolbarItem.toString() == 'Previous Instance') {
                          setState(() {
                            _canShowToolbar = false;
                          });
                        }
                        if (toolbarItem.toString() == 'Next Instance') {
                          setState(() {
                            _canShowToolbar = false;
                          });
                        }
                        if (toolbarItem.toString() == 'Clear Text') {
                          setState(() {
                            _canShowToolbar = false;
                          });
                        }
                        if (toolbarItem.toString() == 'noResultFound') {
                          setState(() {
                            _textSearchKey.currentState?.canShowToast = true;
                          });
                          await Future<dynamic>.delayed(
                              const Duration(seconds: 1));
                          setState(() {
                            _textSearchKey.currentState?.canShowToast = false;
                          });
                        }
                      },
                    )
                  ],
                ),
                automaticallyImplyLeading: false,
                backgroundColor: context.scaffoldBackgroundColor,
              )
            : PreferredSize(
                preferredSize: Size.zero,
                child: Container(),
              );

    return Scaffold(
      appBar: appBar,
      body: FutureBuilder(
        future: Future<dynamic>.delayed(const Duration(milliseconds: 200))
            .then((dynamic value) {
          _canShowPdf = true;
        }),
        builder: (BuildContext context, AsyncSnapshot<Object?> snapshot) {
          final Widget pdfViewer = Listener(
            onPointerDown: (PointerDownEvent details) {
              _textSearchKey.currentState?.focusNode!.unfocus();
              _focusNode.unfocus();
            },
            child: SfPdfViewer.network(
              widget.url,
              key: _pdfViewerKey,
              controller: _pdfViewerController,
              onTextSelectionChanged:
                  (PdfTextSelectionChangedDetails details) async {
                if (details.selectedText == null &&
                    _selectionOverlayEntry != null) {
                  _textSelectionDetails = null;
                } else if (details.selectedText != null &&
                    _selectionOverlayEntry == null) {
                  _textSelectionDetails = details;
                  _showContextMenu(context, null);
                }
              },
              onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                showErrorDialog(context, details.error, details.description);
              },
            ),
          );
          if (_canShowPdf) {
            return WillPopScope(
              onWillPop: () async {
                setState(() {
                  _canShowToolbar = true;
                });
                return true;
              },
              child: Stack(children: <Widget>[
                pdfViewer,
                showToast(_textSearchKey.currentState?.canShowToast ?? false,
                    Alignment.center, AppStrings.noResults),
                showToast(
                    _canShowToast, Alignment.bottomCenter, AppStrings.copied),
              ]),
            );
          } else {
            return Container(
              color: Theme.of(context).primaryColor,
            );
          }
        },
      ),
    );
  }
}
