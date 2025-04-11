import 'dart:async';

class TimerController {
  Timer? _timer;
  final Stopwatch _stopwatch = Stopwatch();
  Function(int)? _onTimeChanged;

  int get elapsedSeconds =>
      (_stopwatch.elapsedMilliseconds / 1000).floor(); // 초 단위 반환

  bool get isRunning => _stopwatch.isRunning;

  void initialize(Function(int) onTimeChanged) {
    _onTimeChanged = onTimeChanged;
  }

  void start() {
    if (!_stopwatch.isRunning) {
      _stopwatch.start();
      _timer = Timer.periodic(const Duration(milliseconds: 100), _updateTime);
    }
  }

  void stop() {
    _stopwatch.stop();
    _timer?.cancel();
    _timer = null;
  }

  void reset() {
    _stopwatch.reset();
    if (_onTimeChanged != null) {
      _onTimeChanged!(0); // 초기화 시 초 단위로 전달
    }
  }

  void _updateTime(Timer timer) {
    if (_onTimeChanged != null) {
      // 초 단위로 변환하여 콜백 호출
      _onTimeChanged!(elapsedSeconds);
    }
  }

  void dispose() {
    _timer?.cancel();
    _stopwatch.stop();
  }
}
