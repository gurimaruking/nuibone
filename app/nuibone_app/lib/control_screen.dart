import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ble_service.dart';

/// メイン制御画面
class ControlScreen extends StatelessWidget {
  const ControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NuiBone'),
        actions: [
          Consumer<BleService>(
            builder: (context, ble, _) => IconButton(
              icon: Icon(
                ble.isConnected ? Icons.bluetooth_connected : Icons.bluetooth,
                color: ble.isConnected ? Colors.green : null,
              ),
              onPressed: () => _showConnectionDialog(context),
            ),
          ),
        ],
      ),
      body: Consumer<BleService>(
        builder: (context, ble, _) => Column(
          children: [
            // 接続状態バー
            _ConnectionStatusBar(ble: ble),

            // コントロールパネル
            Expanded(
              child: ble.isConnected
                  ? const _ControlPanel()
                  : const _NotConnectedView(),
            ),
          ],
        ),
      ),
    );
  }

  void _showConnectionDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const _ConnectionSheet(),
    );
  }
}

/// 接続状態バー
class _ConnectionStatusBar extends StatelessWidget {
  final BleService ble;

  const _ConnectionStatusBar({required this.ble});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: ble.isConnected
          ? Colors.green.withOpacity(0.2)
          : Colors.grey.withOpacity(0.2),
      child: Row(
        children: [
          Icon(
            ble.isConnected ? Icons.check_circle : Icons.info_outline,
            size: 16,
            color: ble.isConnected ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              ble.statusMessage,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

/// 未接続時の表示
class _NotConnectedView extends StatelessWidget {
  const _NotConnectedView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bluetooth_disabled,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'NuiBoneに接続してください',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _showConnectionSheet(context),
            icon: const Icon(Icons.bluetooth_searching),
            label: const Text('デバイスを探す'),
          ),
        ],
      ),
    );
  }

  void _showConnectionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const _ConnectionSheet(),
    );
  }
}

/// 接続シート
class _ConnectionSheet extends StatefulWidget {
  const _ConnectionSheet();

  @override
  State<_ConnectionSheet> createState() => _ConnectionSheetState();
}

class _ConnectionSheetState extends State<_ConnectionSheet> {
  @override
  void initState() {
    super.initState();
    // 開いたらすぐスキャン開始
    Future.microtask(() {
      context.read<BleService>().startScan();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BleService>(
      builder: (context, ble, _) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'デバイス接続',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (ble.isScanning)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => ble.startScan(),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // 接続中のデバイス
            if (ble.isConnected && ble.connectedDevice != null) ...[
              ListTile(
                leading: const Icon(Icons.bluetooth_connected, color: Colors.green),
                title: Text(ble.connectedDevice!.platformName),
                subtitle: const Text('接続中'),
                trailing: TextButton(
                  onPressed: () {
                    ble.disconnect();
                    Navigator.pop(context);
                  },
                  child: const Text('切断'),
                ),
              ),
              const Divider(),
            ],

            // スキャン結果
            if (ble.scanResults.isEmpty && !ble.isScanning)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Text('NuiBoneが見つかりません\n電源が入っているか確認してください'),
                ),
              )
            else
              ...ble.scanResults.map((result) => ListTile(
                    leading: const Icon(Icons.bluetooth),
                    title: Text(result.device.platformName.isNotEmpty
                        ? result.device.platformName
                        : "Unknown"),
                    subtitle: Text('RSSI: ${result.rssi}'),
                    trailing: FilledButton(
                      onPressed: () async {
                        await ble.connect(result.device);
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('接続'),
                    ),
                  )),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// コントロールパネル
class _ControlPanel extends StatelessWidget {
  const _ControlPanel();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 手振りセクション
          _SectionCard(
            title: '手振り',
            icon: Icons.waving_hand,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: '右手',
                      icon: Icons.back_hand,
                      command: NuiBoneCommand.waveRight,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ActionButton(
                      label: '左手',
                      icon: Icons.back_hand,
                      command: NuiBoneCommand.waveLeft,
                      mirrorIcon: true,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ActionButton(
                      label: '両手',
                      icon: Icons.celebration,
                      command: NuiBoneCommand.waveBoth,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 呼吸セクション
          _SectionCard(
            title: '呼吸',
            icon: Icons.air,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: '呼吸ON',
                      icon: Icons.play_arrow,
                      command: NuiBoneCommand.breathOn,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ActionButton(
                      label: '呼吸OFF',
                      icon: Icons.stop,
                      command: NuiBoneCommand.breathOff,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // プリセットセクション
          _SectionCard(
            title: 'プリセット',
            icon: Icons.auto_awesome,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: '挨拶',
                      icon: Icons.emoji_people,
                      command: NuiBoneCommand.greeting,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ActionButton(
                      label: '元気',
                      icon: Icons.mood,
                      command: NuiBoneCommand.energetic,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: 'おやすみ',
                      icon: Icons.bedtime,
                      command: NuiBoneCommand.sleep,
                      color: Colors.indigo,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ActionButton(
                      label: '停止',
                      icon: Icons.stop_circle,
                      command: NuiBoneCommand.stop,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 音声セクション
          _SectionCard(
            title: 'ボイス',
            icon: Icons.record_voice_over,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: 'こんにちは',
                      icon: Icons.waving_hand,
                      command: NuiBoneCommand.voiceHello,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ActionButton(
                      label: 'ありがとう',
                      icon: Icons.volunteer_activism,
                      command: NuiBoneCommand.voiceThanks,
                      color: Colors.pink,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ActionButton(
                      label: 'だいすき',
                      icon: Icons.favorite,
                      command: NuiBoneCommand.voiceLove,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: 'ねむい',
                      icon: Icons.bedtime,
                      command: NuiBoneCommand.voiceSleepy,
                      color: Colors.indigo,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ActionButton(
                      label: 'うれしい',
                      icon: Icons.sentiment_very_satisfied,
                      command: NuiBoneCommand.voiceHappy,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ActionButton(
                      label: '停止',
                      icon: Icons.volume_off,
                      command: NuiBoneCommand.voiceStop,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // カスタム音声
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: 'カスタム1',
                      icon: Icons.music_note,
                      command: NuiBoneCommand.voiceCustom1,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ActionButton(
                      label: 'カスタム2',
                      icon: Icons.music_note,
                      command: NuiBoneCommand.voiceCustom2,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ActionButton(
                      label: 'カスタム3',
                      icon: Icons.music_note,
                      command: NuiBoneCommand.voiceCustom3,
                      color: Colors.teal,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// セクションカード
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// アクションボタン
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final int command;
  final Color? color;
  final bool mirrorIcon;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.command,
    this.color,
    this.mirrorIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    final ble = context.read<BleService>();

    return FilledButton.tonal(
      onPressed: () => ble.sendCommand(command),
      style: FilledButton.styleFrom(
        backgroundColor: color?.withOpacity(0.2),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()..scale(mirrorIcon ? -1.0 : 1.0, 1.0),
            child: Icon(icon, size: 28),
          ),
          const SizedBox(height: 4),
          Text(label),
        ],
      ),
    );
  }
}
