// TODO: Put public facing types in this file.

import 'dart:convert';

/// Checks if you are awesome. Spoiler: you are.
class Awesome {
  bool get isAwesome => true;
}

enum WsStatus {
  proxyStart(0),
  proxyInfo(1),
  proxyClose(2),
  connClose(3),
  error(-1);

  const WsStatus(this.value);
  final int value;
  static WsStatus intToWsStatus(int val) {
    switch (val) {
      case 0:
        return WsStatus.proxyStart;
      case 1:
        return WsStatus.proxyInfo;
      case 2:
        return WsStatus.proxyClose;
      case 3:
        return WsStatus.connClose;
      case -1:
        return WsStatus.error;
      default:
        return WsStatus.error;
    }
  }
}

class WsMessage {
  WsStatus type;
  String content;

  WsMessage(this.type, this.content);

  String toJson() {
    Map<String, dynamic> map = {
      "type": type.value,
      "content": content,
    };
    final jsonStr = jsonEncode(map);
    return jsonStr;
  }

  static WsMessage fromJson(String jsonStr) {
    final myMap = jsonDecode(jsonStr);

    return WsMessage(WsStatus.intToWsStatus(myMap["type"]), myMap["content"]);
  }
}
