import 'dart:async';

/// Global singleton event bus for purchase-related events.
///
/// Fire [notifyPurchase] after any successful purchase to trigger
/// an app-wide refresh (catalog, profile, search, etc.).
class PurchaseEventBus {
  PurchaseEventBus._();

  static final PurchaseEventBus instance = PurchaseEventBus._();

  final StreamController<int> _controller =
      StreamController<int>.broadcast();

  /// Stream of purchased anuncio IDs.
  Stream<int> get onPurchase => _controller.stream;

  /// Call this after a purchase is confirmed to notify all listeners.
  void notifyPurchase(int anuncioId) {
    _controller.add(anuncioId);
  }

  void dispose() {
    _controller.close();
  }
}
