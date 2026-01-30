/**
 * NuiBone - ESP32 Firmware
 *
 * 15cmぬいぐるみ用ロボット骨格制御
 * - BLE経由でスマホアプリから制御
 * - 3つのSG90サーボ（左腕、右腕、呼吸）
 * - プリセット動作パターン
 */

#include <Arduino.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#include <ESP32Servo.h>

// ============================================
// ピン設定
// ============================================
#define SERVO_LEFT_ARM_PIN   13  // 左腕サーボ
#define SERVO_RIGHT_ARM_PIN  12  // 右腕サーボ
#define SERVO_BREATH_PIN     14  // 呼吸サーボ

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
        String value = pCharacteristic->getValue();
        if (value.length() > 0) {
            int cmd = value[0];
            Serial.printf("Received command: %d\n", cmd);
            executeCommand(cmd);
        }
    }

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
        // 左右フラグは後続のwaveUpdate()で使用
    }

    void updateStatus() {
        if (pStatusChar != nullptr) {
            String status = String(currentCommand) + "," +
                           String(isBreathing ? 1 : 0) + "," +
                           String(isWaving ? 1 : 0);
            pStatusChar->setValue(status);
            pStatusChar->notify();
        }
    }
};

// ============================================
// サーボ初期化
// ============================================
void setupServos() {
    // ESP32Servoの設定
    ESP32PWM::allocateTimer(0);
    ESP32PWM::allocateTimer(1);
    ESP32PWM::allocateTimer(2);

    servoLeftArm.setPeriodHertz(50);
    servoRightArm.setPeriodHertz(50);
    servoBreath.setPeriodHertz(50);

    servoLeftArm.attach(SERVO_LEFT_ARM_PIN, SERVO_MIN_US, SERVO_MAX_US);
    servoRightArm.attach(SERVO_RIGHT_ARM_PIN, SERVO_MIN_US, SERVO_MAX_US);
    servoBreath.attach(SERVO_BREATH_PIN, SERVO_MIN_US, SERVO_MAX_US);

    // 初期位置
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

    // コマンド受信用キャラクタリスティック
    pCommandChar = pService->createCharacteristic(
        COMMAND_CHAR_UUID,
        BLECharacteristic::PROPERTY_WRITE |
        BLECharacteristic::PROPERTY_WRITE_NR
    );
    pCommandChar->setCallbacks(new CommandCallbacks());

    // ステータス通知用キャラクタリスティック
    pStatusChar = pService->createCharacteristic(
        STATUS_CHAR_UUID,
        BLECharacteristic::PROPERTY_READ |
        BLECharacteristic::PROPERTY_NOTIFY
    );
    pStatusChar->addDescriptor(new BLE2902());

    pService->start();

    BLEAdvertising* pAdvertising = BLEDevice::getAdvertising();
    pAdvertising->addServiceUUID(SERVICE_UUID);
    pAdvertising->setScanResponse(true);
    pAdvertising->setMinPreferred(0x06);
    pAdvertising->setMinPreferred(0x12);
    BLEDevice::startAdvertising();

    Serial.println("BLE initialized, waiting for connection...");
}

// ============================================
// 呼吸アニメーション更新
// ============================================
void updateBreathing() {
    if (!isBreathing) return;

    unsigned long now = millis();

    // 呼吸周期: 約3秒（通常モード）/ 1.5秒（元気モード）
    int breathInterval = (currentCommand == CMD_ENERGETIC) ? 750 : 1500;

    if (now - lastBreathTime > breathInterval) {
        lastBreathTime = now;
        breathPhase = (breathPhase + 1) % 2;

        if (breathPhase == 0) {
            // 吸気
            servoBreath.write(BREATH_MIN);
        } else {
            // 呼気
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

    // 手振り周期: 約300ms
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

        // 3回振ったら停止（元気モードは継続）
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

    delay(10);  // CPU負荷軽減
}
