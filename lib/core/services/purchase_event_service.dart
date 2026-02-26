import 'dart:async';

class PurchaseEventBus {
  PurchaseEventBus._();

  static final PurchaseEventBus instance = PurchaseEventBus._();

  final StreamController<int> _controller =
      StreamController<int>.broadcast();

  Stream<int> get onPurchase => _controller.stream;

  void notifyPurchase(int anuncioId) {
    _controller.add(anuncioId);
  }

  void dispose() {
    _controller.close();
  }
}
