// Format the time in hours:minutes:seconds
String formatRecordTime(int seconds) {
  final int hours = seconds ~/ 3600;
  final int minutes = (seconds % 3600) ~/ 60;
  final int displaySeconds = seconds % 60;
  return '${hours.toString().padLeft(2, '0')}時'
          '${minutes.toString().padLeft(2, '0')}分'
          '${displaySeconds.toString().padLeft(2, '0')}秒';
}