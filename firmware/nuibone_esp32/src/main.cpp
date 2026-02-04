/**
 * NuiBone - ESP32 Firmware (Basic Version)
 *
 * 15cmぬいぐるみ用ロボット骨格制御
 * - BLE経由でスマホアプリから制御
 * - 3つのSG90サーボ（左腕、右腕、呼吸）
 * - プリセット動作パターン
 *
 * ※音声機能は別途追加予定
 */

#include <Arduino.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#include <ESP32Servo.h>

// ============================================
// ピン設定 (ESP32-C3対応)
// ============================================
// ESP32-C3ではGPIO 1-10, 18-21 がサーボ用に使用可能
#define SERVO_LEFT_ARM_PIN   2   // 左腕サーボ (GPIO2)
#define SERVO_RIGHT_ARM_PIN  3   // 右腕サーボ (GPIO3)
#define SERVO_BREATH_PIN     4   // 呼吸サーボ (GPIO4)

// ============================================
// BLE設定
// ============================================
#define SERVICE_UUID        "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define COMMAND_CHAR_UUID   "beb5483e-36e1-4688-b7f5-ea07361b26a8"
#define STATUS_CHAR_UUID    "beb5483e-36e1-4688-b7f5-ea07361b26a9"

// ============================================
// サーボ設定
// ============================================
#define SERVO_MIN_US    500   // 最小パルス幅 (us)
#define SERVO_MAX_US    2400  // 最大パルス幅 (us)

// 腕の動作範囲
#define ARM_CENTER      90    // 中央位置 (度)
#define ARM_FORWARD     120   // 前方位置 (度)
#define ARM_BACKWARD    60    // 後方位置 (度)

// 呼吸の動作範囲
#define BREATH_MIN      85    // 吸気位置 (度)
#define BREATH_MAX      95    // 呼気位置 (度)

// ============================================
// コマンド定義
// ============================================
enum Command {
    CMD_STOP = 0,           // 全停止
    CMD_WAVE_RIGHT = 1,     // 右手を振る
    CMD_WAVE_LEFT = 2,      // 左手を振る
    CMD_WAVE_BOTH = 3,      // 両手を振る
    CMD_BREATH_ON = 4,      // 呼吸ON
    CMD_BREATH_OFF = 5,     // 呼吸OFF
    CMD_ENERGETIC = 6,      // 元気モード
    CMD_SLEEP = 7,          // おやすみ
    CMD_GREETING = 8,       // 挨拶
};

// ============================================
// グローバル変数
// ============================================
Servo servoLeftArm;
Servo servoRightArm;
Servo servoBreath;

BLEServer* pServer = nullptr;
BLECharacteristic* pCommandChar = nullptr;
BLECharacteristic* pStatusChar = nullptr;

bool deviceConnected = false;
bool oldDeviceConnected = false;

// 動作状態
volatile bool isBreathing = false;
volatile bool isWaving = false;
volatile int currentCommand = CMD_STOP;

// タイミング
unsigned long lastBreathTime = 0;
unsigned long lastWaveTime = 0;
int breathPhase = 0;
int wavePhase = 0;
int waveCount = 0;

// ============================================
// 前方宣言
// ============================================
void updateStatus();
void stopAll();
void startWave(bool right, bool left);
void executeCommand(int cmd);

// ============================================
// ステータス更新
// ============================================
void updateStatus() {
    if (pStatusChar != nullptr) {
        char statusBuf[32];
        snprintf(statusBuf, sizeof(statusBuf), "%d,%d,%d",
                 currentCommand,
                 isBreathing ? 1 : 0,
                 isWaving ? 1 : 0);
        pStatusChar->setValue((uint8_t*)statusBuf, strlen(statusBuf));
        pStatusChar->notify();
    }
}

// ============================================
// 動作制御関数
// ============================================
void stopAll() {
    isBreathing = false;
    isWaving = false;
    servoLeftArm.write(ARM_CENTER);
    servoRightArm.write(ARM_CENTER);
    servoBreath.write(ARM_CENTER);
}

void startWave(bool right, bool left) {
    isWaving = true;
    wavePhase = 0;
    waveCount = 0;
}

// ============================================
// コマンド実行
// ============================================
void executeCommand(int cmd) {
    currentCommand = cmd;

    switch (cmd) {
        case CMD_STOP:
            stopAll();
            break;
        case CMD_WAVE_RIGHT:
            startWave(true, false);
            break;
        case CMD_WAVE_LEFT:
            startWave(false, true);
            break;
        case CMD_WAVE_BOTH:
            startWave(true, true);
            break;
        case CMD_BREATH_ON:
            isBreathing = true;
            break;
        case CMD_BREATH_OFF:
            isBreathing = false;
            servoBreath.write(ARM_CENTER);
            break;
        case CMD_ENERGETIC:
            isBreathing = true;
            startWave(true, true);
            break;
        case CMD_SLEEP:
            stopAll();
            break;
        case CMD_GREETING:
            startWave(true, false);
            break;
        default:
            break;
    }

    updateStatus();
}

// ============================================
// BLE コールバック
// ============================================
class ServerCallbacks : public BLEServerCallbacks {
    void onConnect(BLEServer* pServer) {
        deviceConnected = true;
        Serial.println("Device connected");
    }

    void onDisconnect(BLEServer* pServer) {
        deviceConnected = false;
        Serial.println("Device disconnected");
    }
};

class CommandCallbacks : public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic* pCharacteristic) {
        std::string value = pCharacteristic->getValue();
        if (value.length() > 0) {
            int cmd = value[0];
            Serial.printf("Received command: %d\n", cmd);
            executeCommand(cmd);
        }
    }
};

// ============================================
// サーボ初期化
// ============================================
void setupServos() {
    ESP32PWM::allocateTimer(0);
    ESP32PWM::allocateTimer(1);
    ESP32PWM::allocateTimer(2);

    servoLeftArm.setPeriodHertz(50);
    servoRightArm.setPeriodHertz(50);
    servoBreath.setPeriodHertz(50);

    servoLeftArm.attach(SERVO_LEFT_ARM_PIN, SERVO_MIN_US, SERVO_MAX_US);
    servoRightArm.attach(SERVO_RIGHT_ARM_PIN, SERVO_MIN_US, SERVO_MAX_US);
    servoBreath.attach(SERVO_BREATH_PIN, SERVO_MIN_US, SERVO_MAX_US);

    servoLeftArm.write(ARM_CENTER);
    servoRightArm.write(ARM_CENTER);
    servoBreath.write(ARM_CENTER);

    Serial.println("Servos initialized");
}

// ============================================
// BLE初期化
// ============================================
void setupBLE() {
    BLEDevice::init("NuiBone");

    pServer = BLEDevice::createServer();
    pServer->setCallbacks(new ServerCallbacks());

    BLEService* pService = pServer->createService(SERVICE_UUID);

    pCommandChar = pService->createCharacteristic(
        COMMAND_CHAR_UUID,
        BLECharacteristic::PROPERTY_WRITE |
        BLECharacteristic::PROPERTY_WRITE_NR
    );
    pCommandChar->setCallbacks(new CommandCallbacks());

    pStatusChar = pService->createCharacteristic(
        STATUS_CHAR_UUID,
        BLECharacteristic::PROPERTY_READ |
        BLECharacteristic::PROPERTY_NOTIFY
    );
    pStatusChar->addDescriptor(new BLE2902());

    pService->start();

    // iOS対応のアドバタイズ設定
    BLEAdvertising* pAdvertising = BLEDevice::getAdvertising();
    pAdvertising->addServiceUUID(SERVICE_UUID);
    pAdvertising->setScanResponse(true);

    // iOS接続性向上のための設定
    pAdvertising->setMinPreferred(0x06);  // iPhone接続に必要
    pAdvertising->setMaxPreferred(0x12);  // 接続間隔の最大値

    // アドバタイズデータを設定
    BLEAdvertisementData advData;
    advData.setName("NuiBone");
    advData.setCompleteServices(BLEUUID(SERVICE_UUID));
    pAdvertising->setAdvertisementData(advData);

    // スキャンレスポンスデータ
    BLEAdvertisementData scanData;
    scanData.setName("NuiBone");
    pAdvertising->setScanResponseData(scanData);

    BLEDevice::startAdvertising();

    Serial.println("BLE initialized, waiting for connection...");
    Serial.println("Device name: NuiBone");
}

// ============================================
// 呼吸アニメーション更新
// ============================================
void updateBreathing() {
    if (!isBreathing) return;

    unsigned long now = millis();
    int breathInterval = (currentCommand == CMD_ENERGETIC) ? 750 : 1500;

    if (now - lastBreathTime > breathInterval) {
        lastBreathTime = now;
        breathPhase = (breathPhase + 1) % 2;

        if (breathPhase == 0) {
            servoBreath.write(BREATH_MIN);
        } else {
            servoBreath.write(BREATH_MAX);
        }
    }
}

// ============================================
// 手振りアニメーション更新
// ============================================
void updateWaving() {
    if (!isWaving) return;

    unsigned long now = millis();
    int waveInterval = (currentCommand == CMD_ENERGETIC) ? 200 : 300;

    if (now - lastWaveTime > waveInterval) {
        lastWaveTime = now;
        wavePhase = (wavePhase + 1) % 2;

        bool waveRight = (currentCommand == CMD_WAVE_RIGHT ||
                         currentCommand == CMD_WAVE_BOTH ||
                         currentCommand == CMD_GREETING ||
                         currentCommand == CMD_ENERGETIC);
        bool waveLeft = (currentCommand == CMD_WAVE_LEFT ||
                        currentCommand == CMD_WAVE_BOTH ||
                        currentCommand == CMD_ENERGETIC);

        if (wavePhase == 0) {
            if (waveRight) servoRightArm.write(ARM_FORWARD);
            if (waveLeft) servoLeftArm.write(ARM_BACKWARD);
        } else {
            if (waveRight) servoRightArm.write(ARM_BACKWARD);
            if (waveLeft) servoLeftArm.write(ARM_FORWARD);
            waveCount++;
        }

        if (waveCount >= 3 && currentCommand != CMD_ENERGETIC) {
            isWaving = false;
            servoLeftArm.write(ARM_CENTER);
            servoRightArm.write(ARM_CENTER);
        }
    }
}

// ============================================
// BLE再接続処理
// ============================================
void handleBLEReconnection() {
    if (!deviceConnected && oldDeviceConnected) {
        delay(500);
        pServer->startAdvertising();
        Serial.println("Restarting advertising...");
        oldDeviceConnected = deviceConnected;
    }

    if (deviceConnected && !oldDeviceConnected) {
        oldDeviceConnected = deviceConnected;
    }
}

// ============================================
// セットアップ
// ============================================
void setup() {
    Serial.begin(115200);
    Serial.println("\n=== NuiBone Starting ===");

    setupServos();
    setupBLE();

    Serial.println("=== Ready ===");
}

// ============================================
// メインループ
// ============================================
void loop() {
    handleBLEReconnection();
    updateBreathing();
    updateWaving();

    delay(10);
}
