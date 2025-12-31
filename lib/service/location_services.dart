// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:convert';
import 'package:http/http.dart';
import 'package:flutter/foundation.dart';

import '../main.dart';

class PlaceApiProvider {
  final client = Client();

  PlaceApiProvider();

  Future<List<Suggestion>?> fetchSuggestions(String input, String lang) async {
    try {
      final request = 'https://maps.googleapis.com/maps/api/place/queryautocomplete/json?input=$input&types=address&language=$lang&key=$kGoogleAPIKey';
      final response = await client.get(Uri.parse(request));
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['status'] == 'OK') {
          // compose suggestions in a list
          return result['predictions'].map<Suggestion>((p) => Suggestion(p['place_id'], p['description'])).toList();
        }
        if (result['status'] == 'ZERO_RESULTS') {
          return [];
        }
        throw Exception(result['error_message']);
      } else {
        throw Exception('Failed to fetch suggestion');
      }
    } catch (e) {
      if (kDebugMode) {
        print('ERROR IN GOOGLE API E: $e');
      }
    }
    return null;
  }
}

class Suggestion {
  final String placeId;
  final String description;

  Suggestion(this.placeId, this.description);

  @override
  String toString() {
    return 'Suggestion(description: $description, placeId: $placeId)';
  }
}
