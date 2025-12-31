
import '../messages.dart';
import '../utils/utility.dart';

/// Arabic Messages
class ArabicMessages extends Messages {
  @override
  String prefixAgo() => 'قبل';

  @override
  String suffixAgo() => '';

  @override
  String secsAgo(int seconds) {
    if (seconds == 2) {
      return 'ثانيتين';
    }
    return '${convertToUrduNumbers(seconds)} ثوان';
  }

  @override
  String minAgo(int minutes) => 'دقيقة واحدة';

  @override
  String minsAgo(int minutes) {
    if (minutes == 2) {
      return 'دقيقتين';
    }
    return '${convertToUrduNumbers(minutes)} دقائق';
  }

  @override
  String hourAgo(int minutes) => 'ساعة واحدة';

  @override
  String hoursAgo(int hours) {
    if (hours == 2) {
      return 'ساعتين';
    }
    return '${convertToUrduNumbers(hours)} ساعات';
  }

  @override
  String dayAgo(int hours) => 'يوم واحد';

  @override
  String daysAgo(int days) {
    if (days == 2) {
      return 'يومين';
    }
    return '${convertToUrduNumbers(days)} أيام';
  }

  @override
  String wordSeparator() => ' ';

  @override
  String monthAgo(int month) {
    throw UnimplementedError();
  }

  @override
  String prefixFromNow() {
    throw UnimplementedError();
  }

  @override
  String suffixFromNow() {
    throw UnimplementedError();
  }

  @override
  String weekAgo(int week) {
    throw UnimplementedError();
  }

  @override
  String yearAgo(int year) {
    throw UnimplementedError();
  }
}
