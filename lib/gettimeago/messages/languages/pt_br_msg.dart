import '../messages.dart';

/// Portuguese-Brazil Messages
class PortugueseBrazilMessages implements Messages {
  @override
  String prefixAgo() => 'Há';

  @override
  String suffixAgo() => '';

  @override
  String secsAgo(int seconds) => '$seconds segundos';

  @override
  String minAgo(int minutes) => 'um minuto';

  @override
  String minsAgo(int minutes) => '$minutes minutos';

  @override
  String hourAgo(int minutes) => 'uma hora';

  @override
  String hoursAgo(int hours) => '$hours horas';

  @override
  String dayAgo(int hours) => 'um dia';

  @override
  String daysAgo(int days) => '$days dias';

  @override
  String wordSeparator() => ' ';

  @override
  String monthAgo(int month) {
    return '$month mês';
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
    return '$week semana';
  }

  @override
  String yearAgo(int year) {
    return '$year ano';
  }
}
