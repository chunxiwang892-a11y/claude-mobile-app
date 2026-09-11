import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'notification_service.dart';

class WebSocketService extends ChangeNotifier {
  WebSocketChannel? _channel;
  bool _isConnected = false;
  String _status = 'idle';
  String _currentTask = '无';
  List<Map<String, dynamic>> _messages = [];
  String _serverUrl = '';

  bool get isConnected => _isConnected;
  String get status => _status;
  String get currentTask => _currentTask;
  List<Map<String, dynamic>> get messages => _messages;

  void connect(String url) {
    try {
      _serverUrl = url.replaceAll('wss://', 'https://').replaceAll('ws://', 'http://');
      _channel = WebSocketChannel.connect(Uri.parse(url));
      _isConnected = true;
      notifyListeners();

      _channel!.stream.listen(
        (data) {
          _handleMessage(data);
        },
        onError: (error) {
          _isConnected = false;
          notifyListeners();
        },
        onDone: () {
          _isConnected = false;
          notifyListeners();
        },
      );

    } catch (e) {
      _isConnected = false;
      notifyListeners();
    }
  }

  void _handleMessage(dynamic data) {
    try {
      final parsed = jsonDecode(data);

      // 解包 {"type": "state_update", "data": {...}} 格式
      Map<String, dynamic> payload = parsed;
      if (parsed is Map && parsed.containsKey('type') && parsed.containsKey('data')) {
        payload = parsed['data'];
      }

      if (payload.containsKey('status')) {
        final oldStatus = _status;
        _status = payload['status'] ?? 'idle';
        _currentTask = payload['current_task'] ?? '无';

        if (payload['message_history'] != null) {
          _messages = List<Map<String, dynamic>>.from(payload['message_history']);
        }

        // 检查状态变化通知
        if (oldStatus == 'running' && _status == 'completed') {
          NotificationService().showNotification(
            '任务完成',
            _currentTask,
          );
        }

        notifyListeners();
      }
    } catch (e) {
      print('解析消息失败: $e');
    }
  }

  Future<void> sendMessage(String message) async {
    if (!_isConnected || _channel == null) {
      print('未连接到服务器');
      return;
    }

    try {
      // 通过WebSocket发送消息
      _channel!.sink.add(jsonEncode({
        'type': 'send_message',
        'message': message,
      }));

      // 添加到本地消息历史
      _messages.add({
        'from': 'user',
        'content': message,
        'timestamp': DateTime.now().toIso8601String(),
      });
      notifyListeners();
    } catch (e) {
      print('发送消息失败: $e');
    }
  }

  void disconnect() {
    _channel?.sink.close();
    _isConnected = false;
    notifyListeners();
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
