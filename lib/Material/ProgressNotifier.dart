import 'package:flutter/material.dart';

class ProgressNotifier extends ValueNotifier<ProgressStruct> {
  final ProgressStruct _currentProgressState;
  ProgressNotifier(this._currentProgressState) : super(_currentProgressState);

  String shownText = '';

  /// set a static value without progress indication
  void setStaticValue(int value) {
    _currentProgressState._inProgress = false;
    _currentProgressState._value = value;
    _currentProgressState._currentThreadName = '';

    shownText = '';
    notifyListeners();
  }

  /// check, if progess is performed
  bool get isInProgress {
    return _currentProgressState._inProgress;
  }

  /// start new Progress
  void startProgress([String progressName = '']) {
    _currentProgressState._inProgress = true;
    _currentProgressState._value = 0;
    _currentProgressState._currentThreadName = progressName;

    notifyListeners();
  }

  /// set/update progress indication
  void updatePercentage(int percentage) {
    _currentProgressState._inProgress = true;
    _currentProgressState._value = percentage;

    final newShownText = _currentProgressState.Text;
    if (newShownText == shownText) {
      // dont nofity listeners
      return;
    } else {
      shownText = newShownText;
      notifyListeners();
    }
  }

  /// start new Progress
  void finishProgress() {
    _currentProgressState._value = 100;

    notifyListeners();
  }
}

class ProgressStruct {
  bool _inProgress;
  int _value;
  String _currentThreadName;

  String _formatShownText() {
    //is progress in process
    if (_inProgress) {
      if (_currentThreadName != '') {
        return '$_currentThreadName: $_value%';
      } else {
        return '$_value%';
      }
    }
    return '$_value';
  }

  String get Text {
    return _formatShownText();
  }

  bool get isInProgress {
    return _inProgress;
  }

  ProgressStruct(
    this._value, [
    this._inProgress = false,
    this._currentThreadName = '',
  ]);
}
