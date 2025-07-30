// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:developer';
import 'package:swapbuy/Constant/url.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:swapbuy/Services/ServicesProvider.dart';

enum RequestType { GET, POST, PUT, DELETE }

enum RequestTypeImage { POST_WITH_IMAGE, POST_WITH_MULTI_IMAGE }

class NetworkClient {
  static final String _baseUrl = AppApi.url;

  final http.Client _client;
  final ServicesProvider _services;

  NetworkClient(this._client, this._services);

  NetworkClient.defaultClient()
    : _client = http.Client(),
      _services = ServicesProvider();

  Future<StreamedResponse> requestwithfile({
    required String path,
    Map<String, String>? body,
    bool withfile = false,
    http.MultipartFile? file,
  }) async {
    // log(_services.token);
    var req =
        http.MultipartRequest("PUT", Uri.parse('$_baseUrl$path'))
          ..fields.addAll(body!)
          ..headers.addAll({
            "Accept": "application/json",
            // 'Authorization': 'Bearer ${_services.token}',
          });
    if (withfile) {
      req.files.add(file!);
    }

    var res = await req.send();
    return res;
  }

  Future<http.StreamedResponse> requestwithmultifile({
    required String path,
    Map<String, String>? body,
    required List<http.MultipartFile> files,
    required RequestType requestType,
  }) async {
    late final http.MultipartRequest req;

    switch (requestType) {
      case RequestType.PUT:
        req = http.MultipartRequest("PUT", Uri.parse('$_baseUrl$path'));
        break;

      case RequestType.POST:
        req = http.MultipartRequest("POST", Uri.parse('$_baseUrl$path'));
        break;

      default:
        throw Exception("Unsupported request type");
    }

    if (body != null) {
      req.fields.addAll(body);
    }

    req.headers.addAll({
      "Accept": "application/json",
      // 'Authorization': 'Bearer ${_services.token}',
    });

    req.files.addAll(files);

    final response = await req.send();
    return response;
  }

  Future<Response> request({
    required RequestType requestType,
    required String path,
    bool withtoken = false,
    bool pageination = false,

    String? body,
    int TimeOut = 60,
  }) async {
    log("$_baseUrl$path");
    // log(_services.token);

    switch (requestType) {
      case RequestType.GET:
        return _client
            .get(
              Uri.parse(pageination ? "$path" : "$_baseUrl$path"),

              headers:
                  withtoken
                      ? {
                        'Accept': 'application/json',
                        'Content-Type': 'application/json',
                        // 'Authorization': 'Bearer ${_services.token}',
                      }
                      : {
                        'Accept': 'application/json',
                        'Content-Type': 'application/json',
                      },
            )
            .timeout(Duration(seconds: TimeOut));
      case RequestType.POST:
        return _client
            .post(
              Uri.parse("$_baseUrl$path"),
              headers:
                  withtoken
                      ? {
                        'Accept': 'application/json',
                        'Content-Type': 'application/json',
                        // 'Authorization': 'Bearer ${_services.token}',
                      }
                      : {
                        'Accept': 'application/json',
                        'Content-Type': 'application/json',
                      },
              body: body,
            )
            .timeout(Duration(seconds: TimeOut));
      case RequestType.PUT:
        return _client
            .put(
              Uri.parse("$_baseUrl$path"),
              headers:
                  withtoken
                      ? {
                        'Accept': 'application/json',
                        'Content-Type': 'application/json',
                        // 'Authorization': 'Bearer ${_services.token}',
                      }
                      : {
                        'Accept': 'application/json',
                        'Content-Type': 'application/json',
                      },
              body: body,
            )
            .timeout(Duration(seconds: TimeOut));
      case RequestType.DELETE:
        return _client
            .delete(
              Uri.parse("$_baseUrl$path"),
              headers:
                  withtoken
                      ? {
                        'Accept': 'application/json',
                        'Content-Type': 'application/json',
                        // 'Authorization': 'Bearer ${_services.token}',
                      }
                      : {
                        'Accept': 'application/json',
                        'Content-Type': 'application/json',
                      },
              body: body,
            )
            .timeout(Duration(seconds: TimeOut));
    }
  }
}
