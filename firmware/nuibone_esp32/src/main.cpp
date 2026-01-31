/**
 * NuiBone - ESP32 Firmware
 *
 * 15cmぬいぐるみ用ロボット骨格制御
 * - BLE経由でスマホアプリから制御
 * - 3つのSG90サーボ（左腕、右腕、呼吸）
 * - プリセット動作パターン
 * - 音声再生（WAVファイル）
 */

#include <Arduino.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>
#include <ESP32Servo.h>
#include "AudioFileSourceSD.h"
#include "AudioGeneratorWAV.h"
#include "AudioOutputI2S.h"
#include <SD.h>
#include <SPI.h>

// ============================================
// ピン設定
// ============================================
// サーボ
#define SERVO_LEFT_ARM_PIN   13  // 左腕サーボ
#define SERVO_RIGHT_ARM_PIN  12  // 右腕サーボ
#define SERVO_BREATH_PIN     14  // 呼吸サーボ

// I2S オーディオ出力（MAX98357A等）
#define I2S_BCLK_PIN         26  // ビットクロック
#define I2S_LRC_PIN          25  // LRクロック（ワードセレクト）
#define I2S_DOUT_PIN         22  // データ出力

// SDカード（SPI）
#define SD_CS_PIN            5   // SDカード CS

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

    // 音声コマンド (10番台)
    CMD_VOICE_HELLO = 10,   // 「こんにちは」
    CMD_VOICE_THANKS = 11,  // 「ありがとう」
    CMD_VOICE_LOVE = 12,    // 「だいすき」
    CMD_VOICE_SLEEPY = 13,  // 「ねむい」
    CMD_VOICE_HAPPY = 14,   // 「うれしい」
    CMD_VOICE_CUSTOM1 = 15, // カスタム音声1
    CMD_VOICE_CUSTOM2 = 16, // カスタム音声2
    CMD_VOICE_CUSTOM3 = 17, // カスタム音声3
    CMD_VOICE_STOP = 19,    // 音声停止
};

// ============================================
// 音声ファイル定義
// ============================================
// SDカードのルートに配置するWAVファイル名
const char* voiceFiles[] = {
    "/hello.wav",    // CMD_VOICE_HELLO (10)
    "/thanks.wav",   // CMD_VOICE_THANKS (11)
    "/love.wav",     // CMD_VOICE_LOVE (12)
    "/sleepy.wav",   // CMD_VOICE_SLEEPY (13)
    "/happy.wav",    // CMD_VOICE_HAPPY (14)
    "/custom1.wav",  // CMD_VOICE_CUSTOM1 (15)
    "/custom2.wav",  // CMD_VOICE_CUSTOM2 (16)
    "/custom3.wav",  // CMD_VOICE_CUSTOM3 (17)
};
#define VOICE_FILE_COUNT 8

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

// オーディオ
AudioGeneratorWAV *wav = nullptr;
AudioFileSourceSD *file = nullptr;
AudioOutputI2S *out = nullptr;
bool isPlaying = false;
bool sdCardAvailable = false;

// ============================================
// 音声再生関数
// ============================================
void playVoice(int voiceIndex) {
    if (!sdCardAvailable) {
        Serial.println("SD card not available");
        return;
    }

    if (voiceIndex < 0 || voiceIndex >= VOICE_FILE_COUNT) {
        Serial.printf("Invalid voice index: %d\n", voiceIndex);
        return;
    }

    // 再生中なら停止
    stopVoice();

    const char* filename = voiceFiles[voiceIndex];
    Serial.printf("Playing: %s\n", filename);

    if (!SD.exists(filename)) {
        Serial.printf("File not found: %s\n", filename);
        return;
    }

    file = new AudioFileSourceSD(filename);
    wav = new AudioGeneratorWAV();

    if (wav->begin(file, out)) {
        isPlaying = true;
        Serial.println("Playback started");
    } else {
        Serial.println("Failed to start playback");
        delete wav;
        delete file;
        wav = nullptr;
        file = nullptr;
    }
}

void stopVoice() {
    if (wav != nullptr) {
        if (wav->isRunning()) {
            wav->stop();
        }
        delete wav;
        wav = nullptr;
    }
    if (file != nullptr) {
        delete file;
        file = nullptr;
    }
    isPlaying = false;
}

void updateAudio() {
    if (isPlaying && wav != nullptr) {
        if (wav->isRunning()) {
            if (!wav->loop()) {
                // 再生完了
                stopVoice();
                Serial.println("Playback finished");
            }
        }
    }
}

// ============================================
// オーディオ初期化
// ============================================
void setupAudio() {
    // SDカード初期化
    SPI.begin();
    if (!SD.begin(SD_CS_PIN)) {
        Serial.println("SD card initialization failed!");
        sdCardAvailable = false;
    } else {
        Serial.println("SD card initialized");
        sdCardAvailable = true;

        // ファイル一覧表示
        Serial.println("Voice files on SD:");
        for (int i = 0; i < VOICE_FILE_COUNT; i++) {
            if (SD.exists(voiceFiles[i])) {
                Serial.printf("  [OK] %s\n", voiceFiles[i]);
            } else {
                Serial.printf("  [--] %s (not found)\n", voiceFiles[i]);
            }
        }
    }

    // I2S出力初期化
    out = new AudioOutputI2S();
    out->SetPinout(I2S_BCLK_PIN, I2S_LRC_PIN, I2S_DOUT_PIN);
    out->SetGain(0.5);  // 音量 (0.0 - 1.0)

    Serial.println("Audio initialized");
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
        String value = pCharacteristic->getValue();
        if (value.length() > 0) {
            int cmd = value[0];
            Serial.printf("Received command: %d\n", cmd);
            executeCommand(cmd);
        }
    }

    void executeCommand(int cmd) {
        currentCommand = cmd;

        // 動作コマンド
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
                playVoice(4);  // happy.wav
                break;
            case CMD_SLEEP:
                stopAll();
                playVoice(3);  // sleepy.wav
                break;
            case CMD_GREETING:
                startWave(true, false);
                playVoice(0);  // hello.wav
                break;

            // 音声コマンド
            case CMD_VOICE_HELLO:
            case CMD_VOICE_THANKS:
            case CMD_VOICE_LOVE:
            case CMD_VOICE_SLEEPY:
            case CMD_VOICE_HAPPY:
            case CMD_VOICE_CUSTOM1:
            case CMD_VOICE_CUSTOM2:
            case CMD_VOICE_CUSTOM3:
                playVoice(cmd - CMD_VOICE_HELLO);
                break;
            case CMD_VOICE_STOP:
                stopVoice();
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
        stopVoice();
    }

    void startWave(bool right, bool left) {
        isWaving = true;
        wavePhase = 0;
        waveCount = 0;
    }

    void updateStatus() {
        if (pStatusChar != nullptr) {
            String status = String(currentCommand) + "," +
                           String(isBreathing ? 1 : 0) + "," +
                           String(isWaving ? 1 : 0) + "," +
                           String(isPlaying ? 1 : 0);
            pStatusChar->setValue(status);
            pStatusChar->notify();
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
    setupAudio();
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
    updateAudio();

    delay(10);
}
