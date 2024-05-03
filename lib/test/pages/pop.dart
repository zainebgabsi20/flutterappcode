import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../modals/category.dart';

class MultiSelectPopup<T extends Category> extends PopupRoute<List<T>> {
  final List<T> options;
  final List<T> initialValue;
  final Widget Function(BuildContext, T, bool) itemBuilder;

  MultiSelectPopup({
    required this.options,
    required this.initialValue,
    required this.itemBuilder,
  });

  @override
  Duration get transitionDuration => Duration(milliseconds: 300);

  @override
  Color get barrierColor => Colors.black54;

  @override
  bool get barrierDismissible => true;

  @override
  String get barrierLabel => "Dismiss";

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          padding: EdgeInsets.all(20),
          margin: EdgeInsets.symmetric(horizontal: 40, vertical: 80),
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: options.map((option) {
                      bool isSelected = initialValue.contains(option);
                      return ListTile(
                        onTap: () {
                          if (isSelected) {
                            initialValue.remove(option);
                          } else {
                            initialValue.add(option);
                          }
                          // Just rebuild to show the updated selection
                          (context as Element).markNeedsBuild();
                        },
                        title: Text(option!.name),
                        trailing: Icon(isSelected ? Icons.check_box : Icons.check_box_outline_blank),
                      );
                    }).toList(),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, initialValue); // Return the updated list when the user confirms
                },
                child: Text('Confirm'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
