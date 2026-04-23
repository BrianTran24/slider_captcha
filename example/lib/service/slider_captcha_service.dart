import 'dart:convert';

import 'package:example/model/result.dart';
import 'package:http/http.dart' as http;

import '../model/captcha_model.dart';

class Solution {
  String? id;
  int? x;

  Solution({this.id, this.x});

  Solution.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    x = json['x'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['x'] = x;
    return data;
  }
}

class SliderCaptchaService {
  /// Base URL of the captcha server. Must use the HTTPS scheme.
  ///
  /// Example: `'https://api.example.com'`
  final String baseUrl;

  /// Creates a [SliderCaptchaService] that communicates with [baseUrl].
  ///
  /// Throws an [ArgumentError] immediately if [baseUrl] does not use HTTPS,
  /// preventing accidental plain-HTTP usage in production.
  SliderCaptchaService({required this.baseUrl}) {
    _assertHttps(baseUrl);
  }

  /// Throws an [ArgumentError] when [url] does not use the HTTPS scheme,
  /// preventing accidental transmission of captcha answers over plain HTTP.
  static void _assertHttps(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.scheme != 'https') {
      throw ArgumentError(
        'SliderCaptchaService requires an HTTPS base URL to prevent '
        'man-in-the-middle attacks. Received: $url',
      );
    }
  }

  Future<CaptchaModel?> getCaptcha() async {
    final uri = Uri.parse('$baseUrl/puzzle');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      var result = CaptchaModel.fromJson(json);
      return result;
    }
    return null;
  }

  Future<R<String>> postAnswer(Solution solution) async {
    final url = Uri.parse('$baseUrl/puzzle/solution');
    final response = await http.post(
      url,
      body: jsonEncode(solution.toJson()),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    final status = response.statusCode;
    final body = response.body;
    if (status == 200) {
      return R(result: body.toString());
    } else {
      return R(error: body.toString());
    }
  }
}
