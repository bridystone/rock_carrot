import 'package:http/http.dart' as http;

class WebHelper {
  /// handle bad answers from http response
  ///
  /// TODO: implement as logging
  bool isResponseValid(http.Response response) {
    if (response.body.isEmpty) {
      throw Exception('Empty data container' + response.request.toString());
    }
    // Text:'null' from json indicates, that no data is available
    if (response.body == 'null') {
      throw Exception('null container' + response.request.toString());
    }
    if (response.statusCode != 200) {
      throw Exception('wrong status code: ${response.statusCode}' +
          response.request.toString());
    }
    return true;
  }
}
