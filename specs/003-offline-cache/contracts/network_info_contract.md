# Interface Contract: `INetworkInfo`

**Target File**: `lib/core/network/network_info.dart`  
**Layer**: Core / Infrastructure  
**Enforces**: Fixsy Constitution Principle IV (Offline-First Mindset & Caching)  

---

## 1. Class Interface Definition

```dart
abstract class INetworkInfo {
  /// Checks whether the device currently has active, routable internet connectivity.
  /// Returns `true` if Wi-Fi, Mobile, Ethernet, or VPN is active.
  /// Returns `false` if in Airplane mode, disconnected, or unsupported interface.
  Future<bool> get isConnected;

  /// Continuous stream broadcasting real-time connectivity status transitions.
  /// Emits `true` when network becomes reachable, `false` when connection drops.
  Stream<bool> get onConnectivityChanged;
}
```

---

## 2. Behavioral Guarantees & Constraints

1. **Non-Throwing Contract**:
   - `isConnected` must never throw uncaught platform exceptions. Any platform channel communication failure must default safely to `false`.
2. **Multi-Interface Evaluation**:
   - Modern mobile platforms (Android 12+, iOS 16+) often return multiple active interfaces simultaneously. The implementation must consider the device connected if **any** interface in `List<ConnectivityResult>` is capable of internet transit.
3. **No UI or Presentation Leakage**:
   - The contract resides strictly in `lib/core/network/` and takes zero dependencies on Flutter UI (`BuildContext`, `Widget`).
