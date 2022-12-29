import 'dart:io';

import 'package:http/http.dart' as http;

Future<String> getExternalIP() {
  return http.get(Uri.parse("http://icanhazip.com/")).then((response) {
    if (response.statusCode == 200) {
      return response.body.trim();
    } else {
      return "";
    }
  });
}

Future<List<InternetAddress>> getInternalIPs() {
  return NetworkInterface.list().then((nifLst) {
    List<InternetAddress> addrs = [];
    for (var nif in nifLst) {
      addrs.addAll(nif.addresses);
    }
    return addrs;
  });
}

Future<bool> isValidForProxy() async {
  List<InternetAddress> internalIPs = await getInternalIPs();
  String externalIP = await getExternalIP();
  print(internalIPs);
  print(externalIP);
  for (var internalIP in internalIPs) {
    if (internalIP.address == externalIP) return true;
  }
  return false;
}
