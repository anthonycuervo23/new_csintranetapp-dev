import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:nb_utils/nb_utils.dart';

// My imports
import 'package:new_csintranetapp/utils/strings.dart';
import 'package:new_csintranetapp/components/pdf_viewer/pdf_toolbar_item.dart';
import 'package:new_csintranetapp/utils/ui_utils.dart';

/// Signature for [SearchToolbar.onTap] callback.
typedef SearchTapCallback = void Function(Object item);

/// Signature for [Toolbar.onTap] callback.
typedef TapCallback = void Function(Object item);

class Toolbar extends StatefulWidget {
  const Toolbar({
    this.controller,
    this.onTap,
    this.showTooltip = true,
    Key? key,
  }) : super(key: key);

  /// Indica si tooltip para los elementos del toolbar debe mostrarse o no.
  final bool showTooltip;

  final PdfViewerController? controller;

  /// Se llama cuando uno de los elementes del toolbar es seleccionado.
  final TapCallback? onTap;

  @override
  ToolbarState createState() => ToolbarState();
}

class ToolbarState extends State<Toolbar> {
  Color? _color;
  Color? _disabledColor;
  int _pageCount = 0;

  final FocusNode _focusNode = FocusNode();

  TextEditingController? _textEditingController;

  @override
  void initState() {
    widget.controller?.addListener(_pageChanged);
    _textEditingController =
        TextEditingController(text: widget.controller!.pageNumber.toString());
    _pageCount = widget.controller!.pageCount;
    super.initState();
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_pageChanged);
    super.dispose();
  }

  /// Se llama cuando la pagina cambia y actualiza el numero de la pagina en el textField
  void _pageChanged({String? property}) {
    if (widget.controller?.pageCount != null &&
        _pageCount != widget.controller!.pageCount) {
      _pageCount = widget.controller!.pageCount;
      setState(() {});
    }
    if (widget.controller?.pageNumber != null &&
        _textEditingController!.text !=
            widget.controller!.pageNumber.toString()) {
      Future<dynamic>.delayed(Duration.zero, () {
        _textEditingController!.text = widget.controller!.pageNumber.toString();
        setState(() {});
      });
    }
  }

  @override
  void didChangeDependencies() {
    _color = context.primaryColor;
    _disabledColor = Colors.black12;
    super.didChangeDependencies();
  }

  /// Widget de Paginacion, sirve para elegir una pagina en concreto.
  Widget paginationTextField(BuildContext context) {
    return TextField(
      autofocus: false,
      style:
          TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: _color),
      enableInteractiveSelection: false,
      keyboardType: TextInputType.number,
      controller: _textEditingController,
      textAlign: TextAlign.center,
      maxLength: 3,
      focusNode: _focusNode,
      maxLines: 1,
      decoration: InputDecoration(
        counterText: '',
        border: const UnderlineInputBorder(
          borderSide: BorderSide(width: 1.0),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: context.primaryColor, width: 2.0),
        ),
      ),
      enabled: widget.controller!.pageCount == 0 ? false : true,
      onTap: widget.controller!.pageCount == 0
          ? null
          : () {
              _textEditingController!.selection = TextSelection(
                  baseOffset: 0,
                  extentOffset: _textEditingController!.value.text.length);
              _focusNode.requestFocus();
              widget.onTap?.call('Jump to the page');
            },
      onSubmitted: (String text) {
        _focusNode.unfocus();
      },
      onEditingComplete: () {
        final String str = _textEditingController!.text;
        if (str != widget.controller!.pageNumber.toString()) {
          try {
            final int index = int.parse(str);
            if (index > 0 && index <= widget.controller!.pageCount) {
              widget.controller?.jumpToPage(index);
              FocusScope.of(context).requestFocus(FocusNode());
              widget.onTap?.call('Navigated');
            } else {
              _textEditingController!.text =
                  widget.controller!.pageNumber.toString();
              showErrorDialog(context, 'Error', AppStrings.validPageNumber);
            }
          } catch (exception) {
            return showErrorDialog(
                context, 'Error', AppStrings.validPageNumber);
          }
        }
        widget.onTap?.call('Navigated');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool canJumpToPreviousPage = widget.controller!.pageNumber > 1;
    final bool canJumpToNextPage =
        widget.controller!.pageNumber < widget.controller!.pageCount;
    return GestureDetector(
      onTap: () {
        widget.onTap?.call('Toolbar');
      },
      child: Container(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0),
          height: 60, // height del toolbar
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(children: <Widget>[
                // Paginacion
                ToolbarItem(
                    height: 25, // height de la paginacion
                    width: 75, // width de la paginacion
                    child: Row(children: <Widget>[
                      Flexible(
                        child: paginationTextField(context),
                      ),
                      Padding(
                          padding:
                              const EdgeInsets.only(left: 10.0, right: 10.0),
                          child: Text(
                            '/',
                            style: buildTextStyle(),
                            semanticsLabel: '',
                          )),
                      Text(
                        _pageCount.toString(),
                        style: buildTextStyle(),
                        semanticsLabel: '',
                      )
                    ])),
                // Boton de pagina anterior
                Visibility(
                  visible: MediaQuery.of(context).size.width > 360.0,
                  child: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: ToolbarItem(
                        height: 40, // height Boton de pagina anterior
                        width: 40, // width Boton de pagina anterior
                        child: Material(
                            color: Colors.transparent,
                            child: IconButton(
                              icon: Icon(
                                Icons.keyboard_arrow_up,
                                color: canJumpToPreviousPage
                                    ? _color
                                    : _disabledColor,
                                size: 28,
                              ),
                              onPressed: canJumpToPreviousPage
                                  ? () {
                                      widget.onTap?.call('Previous page');
                                      widget.controller?.previousPage();
                                    }
                                  : null,
                              tooltip:
                                  widget.showTooltip ? 'Previous page' : null,
                            )),
                      )),
                ),
                // Boton de proxima pagina
                Visibility(
                  visible: MediaQuery.of(context).size.width > 360.0,
                  child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: ToolbarItem(
                        height: 40, // height Boton de proxima pagina
                        width: 40, // width Boton de proxima pagina
                        child: Material(
                            color: Colors.transparent,
                            child: IconButton(
                              icon: Icon(
                                Icons.keyboard_arrow_down,
                                color:
                                    canJumpToNextPage ? _color : _disabledColor,
                                size: 28,
                              ),
                              onPressed: canJumpToNextPage
                                  ? () {
                                      widget.onTap?.call('Next page');
                                      widget.controller?.nextPage();
                                    }
                                  : null,
                              tooltip: widget.showTooltip ? 'Next page' : null,
                            )),
                      )),
                )
              ]),
              // Boton Bookmark
              ToolbarItem(
                  height: 40, // height Boton Bookmark
                  width: 40, // width Boton Bookmark
                  child: Material(
                    color: Colors.transparent,
                    child: IconButton(
                      icon: Icon(
                        Icons.bookmark,
                        color: widget.controller!.pageNumber == 0
                            ? Colors.black12
                            : _color,
                        size: 28,
                      ),
                      onPressed: widget.controller!.pageNumber == 0
                          ? null
                          : () {
                              _textEditingController!.selection =
                                  const TextSelection(
                                      baseOffset: -1, extentOffset: -1);
                              widget.onTap?.call('Bookmarks');
                            },
                      tooltip: widget.showTooltip ? 'Bookmarks' : null,
                    ),
                  )),
              // Boton de Buscar
              ToolbarItem(
                  height: 40, // height Boton de Buscar
                  width: 40, // width Boton de Buscar
                  child: Material(
                    color: Colors.transparent,
                    child: IconButton(
                      icon: Icon(
                        Icons.search,
                        color: widget.controller!.pageNumber == 0
                            ? Colors.black12
                            : _color,
                        size: 28,
                      ),
                      onPressed: widget.controller!.pageNumber == 0
                          ? null
                          : () {
                              widget.controller!.clearSelection();
                              widget.onTap?.call('Search');
                            },
                      tooltip: widget.showTooltip ? 'Search' : null,
                    ),
                  )),
            ],
          )),
    );
  }

  TextStyle buildTextStyle() => TextStyle(color: _color, fontSize: 18);
}
