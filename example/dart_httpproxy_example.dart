import 'dart:ffi' as ffi;
import 'dart:io' show Platform, Directory;
import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as path;

typedef RunProxyFunc = ffi.Void Function(
    ffi.Int port, ffi.Pointer<Utf8> user, ffi.Pointer<Utf8> pass);
typedef RunProxy = void Function(
    int port, ffi.Pointer<Utf8> user, ffi.Pointer<Utf8> pass);

void main() {
  // Open the dynamic library
  var libraryPath =
      path.join(Directory.current.path, 'proxy_library', 'libproxy.so');

  // if (Platform.isMacOS) {
  //   libraryPath =
  //       path.join(Directory.current.path, 'proxy_library', 'libproxy.dylib');
  // }

  // if (Platform.isWindows) {
  //   libraryPath = path.join(
  //       Directory.current.path, 'proxy_library', 'Debug', 'hello.dll');
  // }

  final dylib = ffi.DynamicLibrary.open(libraryPath);

  // Look up the C function 'hello_world'
  final RunProxy runProxy =
      dylib.lookup<ffi.NativeFunction<RunProxyFunc>>('RunProxy').asFunction();
  // Call the function
  final port = 8080;
  final user = "test";
  final pass = "1234";
  runProxy(port, user.toNativeUtf8(), pass.toNativeUtf8());
}
