import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:nb_utils/nb_utils.dart';

//My Imports
import 'package:new_csintranetapp/utils/strings.dart';
import 'package:new_csintranetapp/utils/ui_utils.dart';
import 'package:new_csintranetapp/components/pdf_viewer/pdf_toolbar.dart';

/// SearchToolbar widget
class SearchToolbar extends StatefulWidget {
  const SearchToolbar({
    this.controller,
    this.onTap,
    this.canShowTooltip = true,
    this.primaryColor,
    Key? key,
  }) : super(key: key);

  /// Indica si tooltip para los elementos del toolbar debe mostrarse o no.
  final bool canShowTooltip;

  final PdfViewerController? controller;

  /// Se llama cuando uno de los elementes del toolbar es seleccionado.
  final SearchTapCallback? onTap;

  final Color? primaryColor;

  @override
  SearchToolbarState createState() => SearchToolbarState();
}

class SearchToolbarState extends State<SearchToolbar> {
  int _searchTextLength = 0;
  Color? _color;
  Color? _textColor;

  /// Indica si los elementos del searchToolBar deben mostrarse o no.
  bool _canShowItem = false;

  /// Indica si se debe mostrar el toast de la busqueda o no.
  bool canShowToast = false;

  final TextEditingController _editingController = TextEditingController();

  /// Se usa para obtener el texto de busqueda.
  PdfTextSearchResult pdfTextSearchResult = PdfTextSearchResult();

  FocusNode? focusNode;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
    focusNode?.requestFocus();
  }

  @override
  void dispose() {
    focusNode?.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    _color = context.primaryColor;
    _textColor = context.primaryColor.withOpacity(0.87);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56, // height SearchToolbar
      child: Row(
        children: <Widget>[
          Material(
            color: Colors.transparent,
            child: IconButton(
              // Boton para volver al toolbar principal
              icon: Icon(
                Icons.arrow_back,
                color: _color,
                size: 28,
              ),
              onPressed: () {
                widget.onTap?.call('Cancel Search');
                _editingController.clear();
                pdfTextSearchResult.clear();
              },
            ),
          ),
          // Buscar textfield.
          Flexible(
            child: TextFormField(
              style: TextStyle(color: _color, fontSize: 18),
              enableInteractiveSelection: false,
              focusNode: focusNode,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.search,
              controller: _editingController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Buscar...',
                hintStyle: TextStyle(
                    color: context.primaryColor.withOpacity(0.34),
                    fontSize: 18),
              ),
              onChanged: (String text) {
                if (_searchTextLength < _editingController.value.text.length) {
                  setState(() {});
                  _searchTextLength = _editingController.value.text.length;
                }
                if (_editingController.value.text.length < _searchTextLength) {
                  setState(() {
                    _canShowItem = false;
                  });
                }
              },
              onFieldSubmitted: (String value) async {
                pdfTextSearchResult = await widget.controller!
                    .searchText(_editingController.text);
                if (pdfTextSearchResult.totalInstanceCount == 0) {
                  widget.onTap?.call('noResultFound');
                } else {
                  _canShowItem = true;
                }
              },
            ),
          ),
          // Cancelar busqueda
          Visibility(
            visible: _editingController.text.isNotEmpty,
            child: Material(
              color: Colors.transparent,
              child: IconButton(
                icon: Icon(
                  Icons.clear,
                  size: 28,
                  color: _color,
                ),
                onPressed: () {
                  setState(() {
                    _editingController.clear();
                    pdfTextSearchResult.clear();
                    widget.controller!.clearSelection();
                    _canShowItem = false;
                    focusNode?.requestFocus();
                  });
                  widget.onTap?.call('Clear Text');
                },
                tooltip: widget.canShowTooltip ? 'Clear Text' : null,
              ),
            ),
          ),
          // Hacer la busqueda
          Visibility(
            visible: _canShowItem,
            child: Row(
              children: <Widget>[
                // instancia actual
                Text(
                  '${pdfTextSearchResult.currentInstanceIndex}',
                  style: TextStyle(color: _textColor, fontSize: 15),
                ),
                Text(
                  ' de ',
                  style: TextStyle(color: _textColor, fontSize: 15),
                ),
                // cuenta total de la instancia
                Text(
                  '${pdfTextSearchResult.totalInstanceCount}',
                  style: TextStyle(color: _textColor, fontSize: 15),
                ),
                // Navegar a la instancia anterior
                Material(
                  color: Colors.transparent,
                  child: IconButton(
                    icon: Icon(
                      Icons.navigate_before,
                      color: _color,
                      size: 28,
                    ),
                    onPressed: () {
                      setState(() {
                        pdfTextSearchResult.previousInstance();
                      });
                      widget.onTap?.call('Previous Instance');
                    },
                    tooltip: widget.canShowTooltip ? 'Previous' : null,
                  ),
                ),
                // Navegar a la proxima instancia
                Material(
                  color: Colors.transparent,
                  child: IconButton(
                    icon: Icon(
                      Icons.navigate_next,
                      size: 28,
                      color: _color,
                    ),
                    onPressed: () {
                      setState(() {
                        if (pdfTextSearchResult.currentInstanceIndex ==
                                pdfTextSearchResult.totalInstanceCount &&
                            pdfTextSearchResult.currentInstanceIndex != 0 &&
                            pdfTextSearchResult.totalInstanceCount != 0) {
                          showCustomDialog(
                            context: context,
                            title: AppStrings.results,
                            subtitle: AppStrings.noMoreResults,
                            buttonActions: ['Si', 'No'],
                            onPressed1: () {
                              pdfTextSearchResult.nextInstance();
                              Navigator.of(context).pop();
                            },
                            onPressed2: () {
                              pdfTextSearchResult.clear();
                              _editingController.clear();
                              _canShowItem = false;
                              focusNode?.requestFocus();
                              Navigator.of(context).pop();
                            },
                          );
                        } else {
                          widget.controller!.clearSelection();
                          pdfTextSearchResult.nextInstance();
                        }
                      });
                      widget.onTap?.call('Next Instance');
                    },
                    tooltip: widget.canShowTooltip ? 'Next' : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
