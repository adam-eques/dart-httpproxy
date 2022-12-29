import 'dart:convert';

class ProxyConfig {
  int port;
  String username;
  String password;
  ProxyConfig(this.port, this.username, this.password);

  String toJson() {
    Map<String, dynamic> map = {
      "port": port,
      "user": username,
      "pass": password,
    };
    final jsonStr = jsonEncode(map);
    return jsonStr;
  }

  static ProxyConfig fromJson(String jsonStr) {
    final myMap = jsonDecode(jsonStr);
    return ProxyConfig(myMap["port"], myMap["user"], myMap["pass"]);
  }
}
