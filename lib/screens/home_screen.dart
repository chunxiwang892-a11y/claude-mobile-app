import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/websocket_service.dart';
import '../widgets/status_card.dart';
import '../widgets/message_bubble.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // 连接WebSocket
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WebSocketService>().connect('ws://10.151.10.27:5678');
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    context.read<WebSocketService>().sendMessage(message);
    _messageController.clear();

    // 滚动到底部
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 顶部状态栏
            _buildHeader(),

            // 主内容区
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 状态卡片
                    Consumer<WebSocketService>(
                      builder: (context, ws, _) => StatusCard(
                        status: ws.status,
                        currentTask: ws.currentTask,
                        isConnected: ws.isConnected,
                      ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2),
                    ),

                    const SizedBox(height: 16),

                    // 消息历史
                    _buildMessageHistory(),
                  ],
                ),
              ),
            ),

            // 底部输入框
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6B35).withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(Icons.code, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Claude Code',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'Mobile Control Center',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
          const Spacer(),
          Consumer<WebSocketService>(
            builder: (context, ws, _) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: ws.isConnected
                    ? Colors.green.withOpacity(0.2)
                    : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: ws.isConnected ? Colors.green : Colors.red,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: ws.isConnected ? Colors.green : Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ).animate(onPlay: (controller) => controller.repeat())
                    .fade(begin: 1, end: 0.3, duration: 1.seconds),
                  const SizedBox(width: 6),
                  Text(
                    ws.isConnected ? '已连接' : '已断开',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: ws.isConnected ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageHistory() {
    return Consumer<WebSocketService>(
      builder: (context, ws, _) {
        if (ws.messages.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(40),
            child: Column(
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 64,
                  color: Colors.white24,
                ).animate(onPlay: (controller) => controller.repeat())
                  .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 2.seconds),
                const SizedBox(height: 16),
                const Text(
                  '暂无消息',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white38,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '发送消息开始对话',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white24,
                  ),
                ),
              ],
            ),
          );
        }

        return Card(
          color: Theme.of(context).colorScheme.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Colors.white.withOpacity(0.05),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.history, size: 18, color: Colors.white54),
                    SizedBox(width: 8),
                    Text(
                      '消息历史',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...ws.messages.asMap().entries.map((entry) {
                  final index = entry.key;
                  final msg = entry.value;
                  return MessageBubble(
                    message: msg['content'] ?? '',
                    isUser: msg['from'] == 'user',
                    timestamp: msg['timestamp'] ?? '',
                  ).animate(delay: (index * 50).ms).fadeIn().slideX(begin: 0.2);
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: const Color(0xFFFF6B35).withOpacity(0.3),
            width: 2,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF3A3A3A),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                decoration: const InputDecoration(
                  hintText: '输入消息...',
                  hintStyle: TextStyle(color: Colors.white38),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6B35).withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat())
            .shimmer(duration: 2.seconds, color: Colors.white24),
        ],
      ),
    );
  }
}
