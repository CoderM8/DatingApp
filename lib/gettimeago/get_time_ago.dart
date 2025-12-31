
import 'package:eypop/ui/notification_pages/filter_message_screen.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import './messages/languages/en_msg.dart';
import './messages/languages/es_msg.dart';
import 'messages/languages/ar_msg.dart';
import 'messages/languages/de_msg.dart';
import 'messages/languages/fr_msg.dart';
import 'messages/languages/hi_msg.dart';
import 'messages/languages/id_msg.dart';
import 'messages/languages/ja_msg.dart';
import 'messages/languages/ko_msg.dart';
import 'messages/languages/oc_msg.dart';
import 'messages/languages/pt_br_msg.dart';
import 'messages/languages/tr_msg.dart';
import 'messages/languages/ur_msg.dart';
import 'messages/languages/zh_cn_msg.dart';
import 'messages/languages/zh_tw_msg.dart';
import 'messages/messages.dart';

class GetTimeAgo {
  static String defaultLocale = 'es';

  static final Map<String, Messages> _messageMap = {
    'en': EnglishMessages(),
    'es': EspanaMessages(),
    'ar': ArabicMessages(),
    'fr': FrenchMessages(),
    'hi': HindiMessages(),
    'pt': PortugueseBrazilMessages(),
    'br': PortugueseBrazilMessages(),
    'zh': SimplifiedChineseMessages(),
    'zh_tr': TraditionalChineseMessages(),
    'ja': JapaneseMessages(),
    'oc': OccitanMessages(),
    'ko': KoreanMessages(),
    'de': GermanMessages(),
    'id': IndonesianMessages(),
    'tr': TurkishMessages(),
    'ur': UrduMessages(),
  };

  static void setDefaultLocale(String locale) {
    assert(_messageMap.containsKey(locale), '[locale] must be a valid locale');
    defaultLocale = locale;
  }

  static String parse(DateTime dateTime, {required String locale, String? pattern}) {
    final locale0 = locale;
    final message = _messageMap[locale0] ?? EnglishMessages();
    final pattern0 = pattern ?? "dd MMM, yyyy hh:mm aa";
    final date = DateFormat(pattern0).format(dateTime);
    var elapsed = DateTime.now().millisecondsSinceEpoch - dateTime.millisecondsSinceEpoch;

    var prefix = message.prefixAgo();
    var suffix = message.suffixAgo();

    final num seconds = elapsed / 1000;
    final num minutes = seconds / 60;
    final num hours = minutes / 60;
    final num days = hours / 24;
    final num week = days / 7;
    final num month = days / 30;
    final num year = days / 365;

    String msg;
    String result;
    if (seconds < 59) {
      msg = message.secsAgo(seconds.round());
      result = [prefix, msg, suffix].where((res) => res.isNotEmpty).join(message.wordSeparator());
    } else if (seconds < 119) {
      msg = message.minAgo(minutes.round());
      result = [prefix, msg, suffix].where((res) => res.isNotEmpty).join(message.wordSeparator());
    } else if (minutes < 59) {
      msg = message.minsAgo(minutes.round());
      result = [prefix, msg, suffix].where((res) => res.isNotEmpty).join(message.wordSeparator());
    } else if (minutes < 119) {
      msg = message.hourAgo(hours.round());
      result = [prefix, msg, suffix].where((res) => res.isNotEmpty).join(message.wordSeparator());
    } else if (hours < 24) {
      msg = message.hoursAgo(hours.round());
      result = [prefix, msg, suffix].where((res) => res.isNotEmpty).join(message.wordSeparator());
    } else if (hours < 48) {
      msg = message.dayAgo(hours.round());
      result = [prefix, msg, suffix].where((res) => res.isNotEmpty).join(message.wordSeparator());
    } else if (days < 7) {
      msg = message.daysAgo(days.round());
      result = [prefix, msg, suffix].where((res) => res.isNotEmpty).join(message.wordSeparator());
    } else if (days < 28) {
      msg = message.weekAgo(week.round());
      result = [prefix, msg, suffix].where((res) => res.isNotEmpty).join(message.wordSeparator());
    } else if (days < 365) {
      msg = message.monthAgo(month.round());
      result = [prefix, msg, suffix].where((res) => res.isNotEmpty).join(message.wordSeparator());
    } else if (days > 364) {
      msg = message.yearAgo(year.round());
      result = [prefix, msg, suffix].where((res) => res.isNotEmpty).join(message.wordSeparator());
    } else {
      msg = date;
      result = date;
    }

    return result;
  }

  static String getTimeAgo(DateTime dateTime, {required String locale, String? pattern}) {
    final locale0 = locale;
    final message = _messageMap[locale0] ?? EnglishMessages();
    final pattern0 = pattern ?? "dd MMM, yyyy hh:mm aa";
    final date = DateFormat(pattern0).format(dateTime);
    int elapsed = DateTime.now().millisecondsSinceEpoch - dateTime.millisecondsSinceEpoch;
    var prefix = message.prefixAgo();
    var suffix = message.suffixAgo();

    final num seconds = elapsed / 1000;
    final num minutes = seconds / 60;
    final num hours = minutes / 60;
    final num days = hours / 24;

    String msg;
    String result;
    if (seconds < 59) {
      msg = message.secsAgo(seconds.round());
      result = [prefix, msg, suffix].where((res) => res.isNotEmpty).join(message.wordSeparator());
    } else if (seconds < 119) {
      msg = message.minAgo(minutes.round());
      result = [prefix, msg, suffix].where((res) => res.isNotEmpty).join(message.wordSeparator());
    } else if (minutes < 59) {
      msg = message.minsAgo(minutes.round());
      result = [prefix, msg, suffix].where((res) => res.isNotEmpty).join(message.wordSeparator());
    } else if (minutes < 119) {
      msg = message.hourAgo(hours.round());
      result = [prefix, msg, suffix].where((res) => res.isNotEmpty).join(message.wordSeparator());
    } else if (hours < 24) {
      msg = message.hoursAgo(hours.round());
      result = [prefix, msg, suffix].where((res) => res.isNotEmpty).join(message.wordSeparator());
    } else if (hours < 48) {
      msg = getDateAndDay(
        Get.context,
        datetime: dateTime,
      );
      result = msg;
    } else if (days < 7) {
      msg = '${'last'.tr} ${getDateAndDay(
        Get.context,
        datetime: dateTime,
      )}';
      result = msg;
    } else if (days < 31) {
      msg = 'more_than_7_days_ago'.tr;
      result = 'more_than_7_days_ago'.tr;
    } else if (days > 31) {
      msg = 'more_than_month_ago'.tr;
      result = 'more_than_month_ago'.tr;
    } else {
      msg = date;
      result = date;
    }
    return result;
  }
}
