library find_dropdown;

import 'package:select_dialog/select_dialog.dart';
import 'package:flutter/material.dart';

import 'find_dropdown_bloc.dart';

typedef Future<List<T>> FindDropdownFindType<T>(String text);
typedef void FindDropdownChangedType<T>(T selectedItem);
typedef Widget FindDropdownBuilderType<T>(BuildContext context, T selectedText);
typedef String FindDropdownValidationType<T>(T selectedText);
typedef Widget FindDropdownItemBuilderType<T>(
  BuildContext context,
  T item,
  bool isSelected,
);

class FindDropdown<T> extends StatefulWidget {
  final String label;
  final Function onClose;
  final bool showClearButton;
  final TextStyle labelStyle;
  final List<T> items;
  final T selectedItem;
  final FindDropdownFindType<T> onFind;
  final FindDropdownChangedType<T> onChanged;
  final FindDropdownBuilderType<T> dropdownBuilder;
  final FindDropdownItemBuilderType<T> dropdownItemBuilder;
  final FindDropdownValidationType<T> validate;
  final Color backgroundColor;
  final WidgetBuilder emptyBuilder;
  final WidgetBuilder loadingBuilder;
  final ErrorBuilderType errorBuilder;
  final bool autofocus;

  ///![image](https://user-images.githubusercontent.com/16373553/80187339-db365f00-85e5-11ea-81ad-df17d7e7034e.png)
  final bool showSearchBox;

  ///![image](https://user-images.githubusercontent.com/16373553/80187339-db365f00-85e5-11ea-81ad-df17d7e7034e.png)
  final InputDecoration searchBoxDecoration;

  ///![image](https://user-images.githubusercontent.com/16373553/80187103-72e77d80-85e5-11ea-9349-e4dc8ec323bc.png)
  final TextStyle titleStyle;

  ///|**Max width**: 90% of screen width|**Max height**: 70% of screen height|
  ///|---|---|
  ///|![image](https://user-images.githubusercontent.com/16373553/80189438-0a020480-85e9-11ea-8e63-3fabfa42c1c7.png)|![image](https://user-images.githubusercontent.com/16373553/80190562-e2ac3700-85ea-11ea-82ef-3383ae32ab02.png)|
  final BoxConstraints constraints;

  const FindDropdown({
    Key key,
    @required this.onChanged,
    this.label,
    this.onClose,
    this.labelStyle,
    this.items,
    this.selectedItem,
    this.onFind,
    this.dropdownBuilder,
    this.dropdownItemBuilder,
    this.showSearchBox = true,
    this.showClearButton = false,
    this.validate,
    this.searchBoxDecoration,
    this.backgroundColor,
    this.titleStyle,
    this.emptyBuilder,
    this.loadingBuilder,
    this.errorBuilder,
    this.constraints,
    this.autofocus,
  })  : assert(onChanged != null),
        super(key: key);
  @override
  _FindDropdownState<T> createState() => _FindDropdownState<T>();
}

class _FindDropdownState<T> extends State<FindDropdown<T>> {
  FindDropdownBloc<T> bloc;

  @override
  void initState() {
    super.initState();
    bloc = FindDropdownBloc<T>(
      seedValue: widget.selectedItem,
      validate: widget.validate,
    );
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: [
            Visibility(
              visible: widget.label != null,
              child: Text(
                widget.label,
                style: widget.labelStyle ?? Theme.of(context).textTheme.subhead,
              ),
            ),
          ],
        ),
        if (widget.label != null) SizedBox(height: 5),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            StreamBuilder<T>(
              stream: bloc.selected$,
              builder: (context, snapshot) {
                return GestureDetector(
                  onTap: () {
                    SelectDialog.showModal(
                      context,
                      items: widget.items,
                      label: widget.label,
                      onClose: widget.onClose,
                      onFind: widget.onFind,
                      showSearchBox: widget.showSearchBox,
                      itemBuilder: widget.dropdownItemBuilder,
                      selectedValue: snapshot.data,
                      searchBoxDecoration: widget.searchBoxDecoration,
                      backgroundColor: widget.backgroundColor,
                      titleStyle: widget.titleStyle,
                      autofocus: widget.autofocus,
                      constraints: widget.constraints,
                      emptyBuilder: widget.emptyBuilder,
                      errorBuilder: widget.errorBuilder,
                      loadingBuilder: widget.loadingBuilder,
                      onChange: (item) {
                        bloc.selected$.add(item);
                        widget.onChanged(item);
                      },
                    );
                  },
                  child: (widget.dropdownBuilder != null)
                      ? widget.dropdownBuilder(context, snapshot.data)
                      : Container(
                          padding: EdgeInsets.fromLTRB(15, 5, 5, 5),
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              width: 1,
                              color: Theme.of(context).dividerColor,
                            ),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(snapshot.data?.toString() ?? ""),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Row(
                                  children: <Widget>[
                                    if (snapshot.data != null &&
                                        widget.showClearButton)
                                      GestureDetector(
                                        onTap: () {
                                          bloc.selected$.add(null);
                                          widget.onChanged(null);
                                        },
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(right: 0),
                                          child: Icon(
                                            Icons.clear,
                                            size: 25,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ),
                                    if (snapshot.data == null ||
                                        !widget.showClearButton)
                                      Icon(
                                        Icons.arrow_drop_down,
                                        size: 25,
                                        color: Colors.black54,
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                );
              },
            ),
            if (widget.validate != null)
              StreamBuilder<String>(
                stream: bloc.validateMessageOut,
                builder: (context, snapshot) {
                  return ConstrainedBox(
                    constraints: BoxConstraints(minHeight: 15),
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Text(
                        snapshot.data ?? "",
                        style: Theme.of(context).textTheme.body1.copyWith(
                            color: snapshot.hasData
                                ? Theme.of(context).errorColor
                                : Colors.transparent),
                      ),
                    ),
                  );
                },
              )
          ],
        ),
      ],
    );
  }
}
