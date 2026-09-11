import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
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
      _serverUrl = url.replaceAll('ws://', 'http://');
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

      // 请求初始状态
      _requestState();
    } catch (e) {
      _isConnected = false;
      notifyListeners();
    }
  }

  void _handleMessage(dynamic data) {
    try {
      final parsed = jsonDecode(data);

      if (parsed.containsKey('status')) {
        final oldStatus = _status;
        _status = parsed['status'] ?? 'idle';
        _currentTask = parsed['current_task'] ?? '无';

        if (parsed['message_history'] != null) {
          _messages = List<Map<String, dynamic>>.from(parsed['message_history']);
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

  Future<void> _requestState() async {
    try {
      final response = await http.get(Uri.parse('$_serverUrl/api/state'));
      if (response.statusCode == 200) {
        _handleMessage(response.body);
      }
    } catch (e) {
      print('请求状态失败: $e');
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
