# Claude Code Mobile

<div align="center">
  <h3>📱 原生移动应用 - 随时随地监控你的Claude Code</h3>
  
  <img src="https://img.shields.io/badge/Flutter-3.24.0-blue?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Platform-Android-green?logo=android" alt="Android">
  <img src="https://img.shields.io/github/workflow/status/chunxiwang892-a11y/claude-mobile-app/build" alt="Build">
</div>

## ✨ 功能特性

- 🎯 **实时状态监控** - 自动检测Claude Code运行状态
- 💬 **双向消息对话** - 手机发送指令，电脑自动回复
- 🔔 **任务完成通知** - 推送到系统通知栏
- 🎨 **现代化UI** - 渐变色、动画、卡片式设计
- ⚡ **原生性能** - 60fps流畅体验
- 🔄 **自动重连** - WebSocket断线自动恢复

## 📦 安装

### 方式1: 下载APK（推荐）

前往 [Releases](https://github.com/chunxiwang892-a11y/claude-mobile-app/releases) 下载最新版本的APK文件，安装到手机即可。

### 方式2: 自己构建

```bash
git clone https://github.com/chunxiwang892-a11y/claude-mobile-app.git
cd claude-mobile-app
flutter pub get
flutter build apk --release
```

## 🚀 使用方法

1. **启动电脑端服务**
   ```bash
   cd D:\claude_mobile_bridge
   python start_all_services.py
   ```

2. **打开手机应用**
   
   应用会自动连接到 `ws://10.151.10.27:5678`（需要同一WiFi）

3. **开始使用**
   
   - 查看实时状态
   - 发送消息对话
   - 接收任务通知

## 📸 界面预览

- 渐变色状态卡片
- 实时呼吸灯效果
- 流畅的消息气泡动画
- 现代化输入框设计

## 🔧 技术栈

- Flutter 3.24.0
- WebSocket实时通信
- 本地推送通知
- Provider状态管理

## 📝 开发计划

- [ ] iOS版本
- [ ] 内网穿透配置
- [ ] 语音消息支持
- [ ] 深色/浅色主题切换
- [ ] 多设备管理

## 🤝 贡献

欢迎提交Issue和Pull Request！

## 📄 许可

MIT License

---

<div align="center">
  Made with ❤️ by Claude & You
</div>
