import '../messages.dart';

/// German Messages
class GermanMessages implements Messages {
  @override
  String prefixAgo() => 'vor';

  @override
  String suffixAgo() => '';

  @override
  String secsAgo(int seconds) => '$seconds Sekunden';

  @override
  String minAgo(int minutes) => 'einer Minute';

  @override
  String minsAgo(int minutes) => '$minutes Minuten';

  @override
  String hourAgo(int minutes) => 'einer Stunde';

  @override
  String hoursAgo(int hours) => '$hours Stunden';

  @override
  String dayAgo(int hours) => 'einem Tag';

  @override
  String daysAgo(int days) => '$days Tagen';

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
