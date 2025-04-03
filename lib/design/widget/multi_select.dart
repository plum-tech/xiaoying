library multiselect_scope;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Steal from: "https://github.com/flankb/multiselect_scope/blob/master/lib/multiselect_scope.dart"

/// An object that stores the selected indexes and also allows you to change them
class MultiselectController<T> extends ChangeNotifier {
  List<int> _selectedIndexes = [];
  List<T> _dataSource = [];

  List<int> get selectedIndexes => _selectedIndexes;

  bool get selectedAny => _selectedIndexes.any((element) => true);

  late int _itemsCount;

  void select(int index) {
    assert(index >= 0 && index < _dataSource.length);
    if (index < 0 || index >= _dataSource.length) return;
    final indexContains = _selectedIndexes.contains(index);
    if (!indexContains) {
      _selectedIndexes.add(index);
      notifyListeners();
    }
  }

  void unselect(int index) {
    assert(index >= 0 && index < _dataSource.length);
    if (index < 0 || index >= _dataSource.length) return;
    final indexContains = _selectedIndexes.contains(index);
    if (indexContains) {
      _selectedIndexes.remove(index);
      notifyListeners();
    }
  }

  void toggle(int index) {
    assert(index >= 0 && index < _dataSource.length);
    if (index < 0 || index >= _dataSource.length) return;
    final indexContains = _selectedIndexes.contains(index);
    final doSelect = indexContains ? false : true;

    if (doSelect) {
      if (!indexContains) {
        _selectedIndexes.add(index);
        notifyListeners();
      }
    } else {
      if (indexContains) {
        _selectedIndexes.remove(index);
        notifyListeners();
      }
    }
  }

  void selectItem(T item) {
    final index = _dataSource.indexOf(item);
    if (index < 0) return;
    select(index);
  }

  void unselectItem(T item) {
    final index = _dataSource.indexOf(item);
    if (index < 0) return;
    unselect(index);
  }

  void toggleItem(T item) {
    final index = _dataSource.indexOf(item);
    if (index < 0) return;
    toggle(index);
  }

  /// Get current selected items in [dataSource]
  List<T> getSelectedItems() {
    final selectedItems = selectedIndexes.map((e) => _dataSource[e]).toList();
    return selectedItems;
  }

  /// Set all selection to empty
  void clearSelection() {
    if (selectedIndexes.any((element) => true)) {
      selectedIndexes.clear();
      notifyListeners();
    }
  }

  /// Replace selection by all not selected items
  void invertSelection() {
    _selectedIndexes = List<int>.generate(_itemsCount, (i) => i).toSet().difference(_selectedIndexes.toSet()).toList();

    notifyListeners();
  }

  /// Select all items in [dataSource]
  void selectAll() {
    _selectedIndexes = List<int>.generate(_itemsCount, (i) => i);
    notifyListeners();
  }

  bool isSelectedAll() {
    return _selectedIndexes.length == _dataSource.length;
  }

  /// Check selection of item by it index
  bool isSelectedIndex(int index) {
    return _selectedIndexes.contains(index);
  }

  /// Check selection of item by it index
  bool isSelectedItem(T item) {
    final index = _dataSource.indexOf(item);
    return index >= 0 && _selectedIndexes.contains(index);
  }

  /// Set selection by specified indexes
  /// Replace existing selected indexes by [newIndexes]
  void setSelectedIndexes(List<int> newIndexes) {
    _setSelectedIndexes(newIndexes, true);
  }

  void setSelectedItems(List<T> newItems) {
    _setSelectedItems(newItems, true);
  }

  void _setDataSource(List<T> dataSource) {
    _dataSource = dataSource;
    _itemsCount = dataSource.length;
  }

  void _setSelectedIndexes(List<int> newIndexes, bool notifyListeners) {
    _selectedIndexes = newIndexes;
    if (notifyListeners) {
      this.notifyListeners();
    }
  }

  void _setSelectedItems(List<T> items, bool notifyListeners) {
    _selectedIndexes = items.map((item) => _dataSource.indexOf(item)).where((index) => index >= 0).toList();
    if (notifyListeners) {
      this.notifyListeners();
    }
  }

  T operator [](int index) {
    return _dataSource[index];
  }
}

typedef SelectionChangedCallback<T> = void Function(List<int> selectedIndexes, List<T> selectedItems);

/// Widget to manage item selection
class MultiselectScope<T> extends StatefulWidget {
  /// A child widget that usually contains in its subtree a list
  /// of items whose selection you want to control
  final Widget child;

  /// Function that invoked when selected indexes changes.
  /// Builds appropriate listeners on stage of init [MultiselectScope] widget
  /// and then does not change.
  /// This function will not invoke on first load of this widget.
  final SelectionChangedCallback<T>? onSelectionChanged;

  /// An object that stores the selected indexes and also allows you to change them
  /// This object may be set once and can not be replaced
  /// when updating the widget configuration
  final MultiselectController<T>? controller;

  /// Data for selection tracking
  /// For example list of `Cars` or `Employees`
  final List<T> dataSource;

  /// Clear selection if user push back button
  final bool clearSelectionOnPop;

  /// If [true]: when you update [dataSource] then selected indexes will update
  /// so that the same elements in new [dataSource] are selected
  /// If [false]: selected indexes will have not automatically updates during [dataSource] update
  final bool keepSelectedItemsBetweenUpdates;

  /// Selected indexes, which will be initialized
  /// when the widget is inserted into the widget tree
  final List<int>? initialSelectedIndexes;

  const MultiselectScope({
    super.key,
    required this.dataSource,
    this.controller,
    this.onSelectionChanged,
    this.clearSelectionOnPop = false,
    this.keepSelectedItemsBetweenUpdates = true,
    this.initialSelectedIndexes,
    required this.child,
  });

  @override
  State<MultiselectScope<T>> createState() => _MultiselectScopeState<T>();

  static MultiselectController<T> controllerOf<T>(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_InheritedMultiselectNotifier>()!.controller
        as MultiselectController<T>;
  }
}

class _MultiselectScopeState<T> extends State<MultiselectScope<T>> {
  late List<int> _hashesCopy;
  late MultiselectController<T> _multiselectController;

  void _onSelectionChangedFunc() {
    if (widget.onSelectionChanged != null) {
      widget.onSelectionChanged!(
          _multiselectController.selectedIndexes, _multiselectController.getSelectedItems().cast<T>());
    }
  }

  List<int> _createHashesCopy(MultiselectScope widget) {
    return widget.dataSource.map((e) => e.hashCode).toList();
  }

  @override
  void initState() {
    super.initState();

    _multiselectController = widget.controller ?? MultiselectController<T>();

    _hashesCopy = _createHashesCopy(widget);
    _multiselectController._setDataSource(widget.dataSource);

    if (widget.initialSelectedIndexes != null) {
      _multiselectController._setSelectedIndexes(widget.initialSelectedIndexes!, false);
    }

    if (widget.onSelectionChanged != null) {
      _multiselectController.addListener(_onSelectionChangedFunc);
    }
  }

  @override
  void dispose() {
    _multiselectController.removeListener(_onSelectionChangedFunc);
    super.dispose();
  }

  @override
  void didUpdateWidget(MultiselectScope<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    debugPrint('didUpdateWidget GreatMultiselect');

    if (widget.keepSelectedItemsBetweenUpdates) {
      _updateController(oldWidget);
    }

    _multiselectController._setDataSource(widget.dataSource);
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('build GreatMultiselect');
    return widget.clearSelectionOnPop
        ? PopScope(
            canPop: !_multiselectController.selectedAny,
            onPopInvokedWithResult: (didPop, result) {
              if (!didPop) {
                _multiselectController.clearSelection();
              }
            },
            child: _buildMultiselectScope(),
          )
        : _buildMultiselectScope();
  }

  _InheritedMultiselectNotifier _buildMultiselectScope() =>
      _InheritedMultiselectNotifier(controller: _multiselectController, child: widget.child);

  void _updateController(MultiselectScope oldWidget) {
    if (!oldWidget.keepSelectedItemsBetweenUpdates && widget.keepSelectedItemsBetweenUpdates) {
      // Recalculate hashes of previous state
      _hashesCopy = _createHashesCopy(oldWidget);
    }

    final newHashesCopy = _createHashesCopy(widget);

    //debugPrint(
    //    "Old dataSource: ${_hashesCopy} new dataSource: ${newHashesCopy}");
    final oldSelectedHashes = _multiselectController.selectedIndexes.map((e) => _hashesCopy[e]).toList();

    final newIndexes = <int>[];
    newHashesCopy.asMap().forEach((index, value) {
      //debugPrint("$index $value");
      if (oldSelectedHashes.contains(value)) {
        newIndexes.add(index);
      }
    });

    _multiselectController._setSelectedIndexes(newIndexes, false);
    _hashesCopy = newHashesCopy;
  }
}

class _InheritedMultiselectNotifier extends InheritedNotifier<MultiselectController> {
  final MultiselectController controller;

  const _InheritedMultiselectNotifier({super.key, required super.child, required this.controller})
      : super(notifier: controller);
}
