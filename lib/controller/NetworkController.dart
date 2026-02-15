import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NetworkController extends Cubit<bool> {
  final Connectivity connectivity;
  StreamSubscription<List<ConnectivityResult>>? subscription;

  NetworkController({Connectivity? service})
      : connectivity = service ?? Connectivity(),
        super(true) {
    init();
  }

  // start listening internet
  Future<void> init() async {
    List<ConnectivityResult> result =
        await connectivity.checkConnectivity();

    emit(checkOnline(result));

    subscription =
        connectivity.onConnectivityChanged.listen((results) {
      emit(checkOnline(results));
    });
  }

  // check if connected
  bool checkOnline(List<ConnectivityResult> results) {
    return results.any((e) => e != ConnectivityResult.none);
  }

  @override
  Future<void> close() async {
    // stop listening
    await subscription?.cancel();
    return super.close();
  }
}