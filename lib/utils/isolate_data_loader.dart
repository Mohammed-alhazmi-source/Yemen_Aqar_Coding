import 'dart:async';
import 'dart:developer';
import 'dart:isolate';

class IsolateDataLoader<T> {
  IsolateDataLoader({
    required Future<T> Function() loadingFunction,
  }) : _loadingFunction = loadingFunction;
  final Future<T> Function() _loadingFunction;

  Future<T> load() async {
    final receivePort = ReceivePort('Receive');
    final isolate = await Isolate.spawn(
      _isolateEntryPoint,
      receivePort.sendPort,
      debugName: 'DataLoaderIsolate',
    );

    final completer = Completer<T>();

    receivePort.listen((message) {
      if (message is SendPort) {
        message.send(_loadingFunction);
      } else if (message is T) {
        completer.complete(message);
        receivePort.close();
        isolate.kill();
      } else {
        completer.completeError(message);
        receivePort.close();
        isolate.kill();
      }
    });

    return completer.future;
  }

  static void _isolateEntryPoint(SendPort sendPort) {
    final port = ReceivePort();
    sendPort.send(port.sendPort);
    port.listen((message) async {
      try {
        log(message.runtimeType.toString(), name: 'RUT');

        final loadingFunction = message as Function;

        final result = await loadingFunction();
        sendPort.send(result);
      } catch (error) {
        log('ERROR is $error');
        sendPort.send(error);
      }
    });
  }
}
