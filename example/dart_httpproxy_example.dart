import 'dart:ffi' as ffi;
import "dart:io";

import 'package:dart_httpproxy/main.dart';
import 'package:dotenv/dotenv.dart';
import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as path;
import 'package:web_socket_channel/web_socket_channel.dart';

// Run
typedef RunProxyFunc = ffi.Void Function(
    ffi.Int port, ffi.Pointer<Utf8> user, ffi.Pointer<Utf8> pass);
typedef RunProxy = void Function(
    int port, ffi.Pointer<Utf8> user, ffi.Pointer<Utf8> pass);
// Stop
typedef StopProxyFunc = ffi.Void Function();
typedef StopProxy = void Function();

void main() async {
  var env = DotEnv()..load([".env"]);

  int port = int.parse(env["PORT"]!);
  String username = env["HARVESTER_NAME"] ?? "testagent";
  String password = env["HARVESTER_KEY"] ?? "testpassword";
  String proxyKey = env["HARVESTER_KEY"] ?? "testpassword";

  String websocketURL = env["WEBSOCKET_URL"]!;
  final channel = WebSocketChannel.connect(
    Uri.parse(websocketURL),
  );

  channel.stream.listen(
    (event) {
      print(event);
      WsMessage msg = WsMessage.fromJson(event);
      switch (msg.type) {
        case WsStatus.proxyClose:
          print("proxyClose");
          break;
        case WsStatus.proxyStart:
          print("ProxyStart");
          proxyRun(port, username, proxyKey);
          break;
        case WsStatus.error:
          print("Error: ${msg.content}");
          proxyClose();
          exit(-1);
        default:
      }
    },
    onDone: () {
      print("websocket was closed");
    },
    onError: (err) {
      print(err);
    },
  );
  String content = ProxyConfig(port, username, proxyKey).toJson();
  WsMessage wsMsg = WsMessage(WsStatus.proxyInfo, content);
  String wsMsgStr = wsMsg.toJson();
  print(wsMsgStr);
  channel.sink.add(wsMsgStr);
  print("websocket connected $websocketURL");

  ProcessSignal.sigint.watch().listen((event) {
    proxyClose();
    exit(0);
  });
}

Future<void> proxyRun(int port, String user, String pass) async {
  // Open the dynamic library
  var libraryPath =
      path.join(Directory.current.path, 'proxy_library', 'libproxy.so');

  final dylib = ffi.DynamicLibrary.open(libraryPath);

  // Look up the go function 'RunProxy'
  final RunProxy runProxy =
      dylib.lookup<ffi.NativeFunction<RunProxyFunc>>('RunProxy').asFunction();
  // Call the function
  runProxy(port, user.toNativeUtf8(), pass.toNativeUtf8());
}

void proxyClose() {
  // Open the dynamic library
  var libraryPath =
      path.join(Directory.current.path, 'proxy_library', 'libproxy.so');
  final dylib = ffi.DynamicLibrary.open(libraryPath);
  // Look up the C function 'hello_world'
  final StopProxy closeProxy =
      dylib.lookup<ffi.NativeFunction<StopProxyFunc>>('StopProxy').asFunction();
  closeProxy();
}
