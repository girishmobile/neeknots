import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:neeknots/service/api_config.dart';

import 'gloable_status_code.dart';

Future callPostMethod(String url, Map<String, dynamic> params) async {
  debugPrint('==Post Method==$url');
  return await http
      .post(
        Uri.parse(url),

        body: json.encode(params),

        headers: await ApiConfig.getCommonHeaders(),
      )
      .timeout(const Duration(seconds: 3))
      .then((http.Response response) {
        return getResponse(response);
      });
}

Future callPatchMethod(String url, Map<String, dynamic> body) async {
  return await http
      .patch(
        Uri.parse(url),
        body: utf8.encode(json.encode(body)),
        headers: await ApiConfig.getCommonHeaders(),
      )
      .then((http.Response response) {
        return getResponse(response);
      });
}

Future callPostMethodWithToken({
  required String url,
  required Map<String, dynamic> body,
  Map<String, String>? headers,
}) async {
  return await http
      .post(
        Uri.parse(url),
        body: utf8.encode(json.encode(body)),
        headers: headers ?? await ApiConfig.getCommonHeaders(),
      )
      .then((http.Response response) {
        return getResponse(response);
      });
}

Future callPutMethodWithToken({
  required String url,
  required Map<String, dynamic> params,
}) async {
  final uri = Uri.parse(url);
  final response = await http
      .put(
        uri,
        body: jsonEncode(params), // utf8.encode not required
        headers: await ApiConfig.getCommonHeaders(),
      )
      .timeout(Duration(seconds: 30));

  return getResponse(response);
}

Future callDeleteMethod({
  required String url,
  Map<String, dynamic>? params,
}) async {
  final request = http.Request("DELETE", Uri.parse(url));
  request.headers.addAll(await ApiConfig.getCommonHeaders());
  if (params != null) {
    request.body = json.encode(params);
  }

  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);

  return getResponse(response);
}

Future callGETMethod({
  required String url,
  Map<String, String>? queryParams,
  String? key,
}) async {
  final uri = Uri.parse(url).replace(queryParameters: queryParams);

  final response = await http.get(
    uri,
    headers: await ApiConfig.getCommonHeaders(),
  );

  return getResponse(response);
}

Future getResponse(Response response) async {
  globalStatusCode = response.statusCode;

  if (globalStatusCode == 500 ||
      globalStatusCode == 502 ||
      globalStatusCode == 503) {
    final parsedJson = jsonDecode(response.body.toString());
    errorMessage = parsedJson['message'].toString();

    return "{\"status\":\"false\",\"message\":\"Internal server issue\"}";
  } else if (globalStatusCode == 401) {
    final parsedJson = jsonDecode(response.body.toString());
    final message = parsedJson['message'].toString();
    errorMessage = parsedJson['message'].toString();
    return "{\"status\":\"false\",\"message\":\"$message\"}";
  } else if (globalStatusCode == 403) {
    final parsedJson = jsonDecode(response.body.toString());
    errorMessage = parsedJson['message'].toString();

    return "{\"status\":\"false\",\"message\":\"Internal server issue\"}";
  } else if (globalStatusCode == 405) {
    //assolyr
    String error = "This Method not allowed.";

    final parsedJson = jsonDecode(response.body.toString());
    errorMessage = parsedJson['message'].toString();
    return "{\"status\":\"0\",\"message\":\"$error\"}";
  } else if (globalStatusCode == 400) {
    final parsedJson = jsonDecode(response.body.toString());
    errorMessage = parsedJson['message'].toString();

    return response.body;
  } else if (globalStatusCode == 404) {
    final parsedJson = jsonDecode(response.body.toString());
    errorMessage = parsedJson['message'].toString();

    return "{\"status\":\"419\",\"message\":\"${errorMessage.toString().replaceAll(RegExp(r'[^\w\s]+'), '')}\"}";
    //return response.body;
  } else if (globalStatusCode == 419) {
    final parsedJson = jsonDecode(response.body.toString());
    errorMessage = parsedJson['message'].toString();

    return "{\"status\":\"false\",\"message\":\"${errorMessage.toString().replaceAll(RegExp(r'[^\w\s]+'), '')}\"}";
    //return response.body;
  } else if (globalStatusCode == 422) {
    final parsedJson = jsonDecode(response.body.toString());
    errorMessage = parsedJson['message'].toString();
    final message = parsedJson['message'].toString();
    return "{\"status\":\"false\",\"message\":\"${message.replaceAll(RegExp(r'[^\w\s]+'), '')}\"}";
  } else if (globalStatusCode == 204) {
    final parsedJson = jsonDecode(response.body.toString());
    final message = parsedJson['message'].toString();
    errorMessage = parsedJson['message'].toString();
    return "{\"status\":\"false\",\"message\":\"${message.replaceAll(RegExp(r'[^\w\s]+'), '')}\"}";
  } else if (globalStatusCode < 200 || globalStatusCode > 404) {
    String error = response.headers['message'].toString();

    final parsedJson = jsonDecode(response.body.toString());
    errorMessage = parsedJson['message'].toString();
    return "{\"status\":\"0\",\"message\":\"$error\"}";
  }
  return response.body;
}
