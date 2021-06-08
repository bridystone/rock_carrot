class Performance {
  /// id, startTime, Difference
  final Map<String, DateTime> _start = {};
  final Map<String, Duration> _duration = {};

  /// register start time
  void start(String id) {
    _start[id] = DateTime.now();
  }

  void stop(String id) {
    if (!_start.containsKey(id)) throw Exception('id not initialised');
    _duration[id] = Duration(
      microseconds: (_duration[id] == null
              ? Duration(microseconds: 0).inMicroseconds
              : _duration[id]!.inMicroseconds) +
          DateTime.now().difference(_start[id]!).inMicroseconds,
    );
  }

  void printAnalysis([String? title]) {
    if (title != null) {
      print(title);
      print('---------------------------------');
    }
    _duration.forEach((key, value) {
      print('$key : $value');
    });
  }
}
