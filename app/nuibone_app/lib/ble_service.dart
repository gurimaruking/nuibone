import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// BLE通信サービス
class BleService extends ChangeNotifier {
  // BLE UUIDs (ESP32ファームウェアと一致させる)
  static const String serviceUuid = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  static const String commandCharUuid = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
  static const String statusCharUuid = "beb5483e-36e1-4688-b7f5-ea07361b26a9";

  // 接続状態
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _commandChar;
  BluetoothCharacteristic? _statusChar;

  bool _isScanning = false;
  bool _isConnected = false;
  String _statusMessage = "未接続";
  List<ScanResult> _scanResults = [];

  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;

  // ゲッター
  bool get isScanning => _isScanning;
  bool get isConnected => _isConnected;
  String get statusMessage => _statusMessage;
  List<ScanResult> get scanResults => _scanResults;
  BluetoothDevice? get connectedDevice => _connectedDevice;

  /// スキャン開始
  Future<void> startScan() async {
    if (_isScanning) return;

    _scanResults = [];
    _isScanning = true;
    _statusMessage = "スキャン中...";
    notifyListeners();

    try {
      // 既存のスキャンをキャンセル
      await FlutterBluePlus.stopScan();

      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        // NuiBoneデバイスのみフィルタリング
        _scanResults = results
            .where((r) =>
                r.device.platformName.contains("NuiBone") ||
                r.advertisementData.serviceUuids
                    .any((uuid) => uuid.toString().toLowerCase() == serviceUuid))
            .toList();
        notifyListeners();
      });

      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 10),
        withServices: [Guid(serviceUuid)],
      );
    } catch (e) {
      _statusMessage = "スキャンエラー: $e";
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  /// スキャン停止
  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
    _scanSubscription?.cancel();
    _isScanning = false;
    notifyListeners();
  }

  /// デバイスに接続
  Future<void> connect(BluetoothDevice device) async {
    _statusMessage = "接続中...";
    notifyListeners();

    try {
      await device.connect(timeout: const Duration(seconds: 10));
      _connectedDevice = device;

      // 接続状態を監視
      _connectionSubscription = device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          _onDisconnected();
        }
      });

      // サービスを探索
      List<BluetoothService> services = await device.discoverServices();

      for (var service in services) {
        if (service.uuid.toString().toLowerCase() == serviceUuid) {
          for (var char in service.characteristics) {
            String charUuid = char.uuid.toString().toLowerCase();
            if (charUuid == commandCharUuid) {
              _commandChar = char;
            } else if (charUuid == statusCharUuid) {
              _statusChar = char;
              // 通知を有効化
              await char.setNotifyValue(true);
              char.lastValueStream.listen(_onStatusReceived);
            }
          }
        }
      }

      if (_commandChar == null) {
        throw Exception("コマンドキャラクタリスティックが見つかりません");
      }

      _isConnected = true;
      _statusMessage = "接続済み: ${device.platformName}";
      notifyListeners();
    } catch (e) {
      _statusMessage = "接続エラー: $e";
      _isConnected = false;
      notifyListeners();
    }
  }

  /// 切断
  Future<void> disconnect() async {
    await _connectedDevice?.disconnect();
    _onDisconnected();
  }

  void _onDisconnected() {
    _connectedDevice = null;
    _commandChar = null;
    _statusChar = null;
    _connectionSubscription?.cancel();
    _isConnected = false;
    _statusMessage = "切断されました";
    notifyListeners();
  }

  void _onStatusReceived(List<int> value) {
    // ステータス受信処理
    String status = String.fromCharCodes(value);
    debugPrint("Status received: $status");
  }

  /// コマンド送信
  Future<void> sendCommand(int command) async {
    if (_commandChar == null || !_isConnected) {
      _statusMessage = "未接続";
      notifyListeners();
      return;
    }

    try {
      await _commandChar!.write(Uint8List.fromList([command]));
      debugPrint("Command sent: $command");
    } catch (e) {
      _statusMessage = "送信エラー: $e";
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _connectionSubscription?.cancel();
    _connectedDevice?.disconnect();
    super.dispose();
  }
}

/// コマンド定義（ESP32と一致させる）
class NuiBoneCommand {
  static const int stop = 0;
  static const int waveRight = 1;
  static const int waveLeft = 2;
  static const int waveBoth = 3;
  static const int breathOn = 4;
  static const int breathOff = 5;
  static const int energetic = 6;
  static const int sleep = 7;
  static const int greeting = 8;
}
