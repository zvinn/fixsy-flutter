import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

enum SyncTaskType { booking, rating, message, profileUpdate, other }

class SyncTask {

  SyncTask({
    required this.id,
    required this.type,
    required this.title,
    required this.createdAt, this.description,
    this.payload = const {},
    this.isSynced = false,
    this.isFailed = false,
    this.retryCount = 0,
  });
  final String id;
  final SyncTaskType type;
  final String title;
  final String? description;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  bool isSynced;
  bool isFailed;
  int retryCount;

  String get typeLabel {
    switch (type) {
      case SyncTaskType.booking:
        return 'حجز خدمة';
      case SyncTaskType.rating:
        return 'تقييم فني';
      case SyncTaskType.message:
        return 'رسالة محادثة';
      case SyncTaskType.profileUpdate:
        return 'تحديث الملف';
      case SyncTaskType.other:
        return 'إجراء عام';
    }
  }

  IconData get icon {
    switch (type) {
      case SyncTaskType.booking:
        return Icons.calendar_today_rounded;
      case SyncTaskType.rating:
        return Icons.star_rate_rounded;
      case SyncTaskType.message:
        return Icons.chat_bubble_outline_rounded;
      case SyncTaskType.profileUpdate:
        return Icons.person_outline_rounded;
      case SyncTaskType.other:
        return Icons.sync_rounded;
    }
  }
}

class ConnectivityProvider extends ChangeNotifier {

  ConnectivityProvider({
    bool initialOnline = true,
    Connectivity? connectivity,
    bool autoInit = true,
  })  : _isOnline = initialOnline,
        _connectivity = connectivity {
    if (autoInit) {
      _init();
    }
  }
  bool _isOnline = true;
  bool _justReconnected = false;
  bool _isSyncing = false;
  Timer? _reconnectedTimer;
  final Connectivity? _connectivity;

  final List<SyncTask> _syncQueue = [];

  bool get isOnline => _isOnline;
  bool get justReconnected => _justReconnected;
  bool get isSyncing => _isSyncing;
  List<SyncTask> get syncQueue => List.unmodifiable(_syncQueue);
  int get pendingCount => _syncQueue.where((task) => !task.isSynced).length;

  void _init() {
    try {
      final conn = _connectivity ?? Connectivity();
      conn.checkConnectivity().then((List<ConnectivityResult> result) {
        _updateStatus(result);
      }).catchError((_) {
        // Silently ignore channel errors in tests or platforms without connectivity plugin
      });

      conn.onConnectivityChanged.listen(
        (result) {
          _updateStatus(result);
        },
        onError: (_) {
          // Silently ignore stream errors
        },
      );
    } catch (_) {
      // In test or non-platform environments, gracefully ignore
    }
  }

  void _updateStatus(List<ConnectivityResult> result) {
    final newStatus = !result.contains(ConnectivityResult.none);
    setOnlineStatus(newStatus);
  }

  void setOnlineStatus(bool online) {
    if (_isOnline != online) {
      final wasOffline = !_isOnline;
      _isOnline = online;

      if (online && wasOffline) {
        // Transitioned from offline to online
        _justReconnected = true;
        _reconnectedTimer?.cancel();
        _reconnectedTimer = Timer(const Duration(seconds: 3), () {
          _justReconnected = false;
          notifyListeners();
        });

        // Trigger automatic sync if items are pending
        if (pendingCount > 0) {
          syncAllPendingTasks();
        }
      } else if (!online) {
        _justReconnected = false;
        _reconnectedTimer?.cancel();
      }

      notifyListeners();
    }
  }

  void enqueueTask(SyncTask task) {
    _syncQueue.add(task);
    notifyListeners();

    // If online, immediately sync
    if (_isOnline) {
      syncAllPendingTasks();
    }
  }

  Future<void> syncAllPendingTasks() async {
    if (_isSyncing || pendingCount == 0) return;

    _isSyncing = true;
    notifyListeners();

    try {
      // Simulate network syncing
      await Future.delayed(const Duration(milliseconds: 600));

      for (var task in _syncQueue) {
        if (!task.isSynced) {
          task.isSynced = true;
          task.isFailed = false;
        }
      }
    } catch (_) {
      for (var task in _syncQueue.where((t) => !t.isSynced)) {
        task.isFailed = true;
        task.retryCount++;
      }
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  void removeTask(String taskId) {
    _syncQueue.removeWhere((task) => task.id == taskId);
    notifyListeners();
  }

  void clearCompleted() {
    _syncQueue.removeWhere((task) => task.isSynced);
    notifyListeners();
  }

  @override
  void dispose() {
    _reconnectedTimer?.cancel();
    super.dispose();
  }
}
