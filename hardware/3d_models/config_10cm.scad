// ============================================
// NuiBone - 10cm版 共通設定ファイル
// ============================================
// 10cmぬいぐるみ用ロボット骨格の寸法設定
// 実測ベースのサイズ制約に基づく設計
// ============================================

// ============================================
// ぬいぐるみサイズ制約（実測値）
// ============================================
nui_height = 100;            // ぬいぐるみ全高 (mm)
nui_head_dia = 45;           // 頭直径 (mm)
nui_body_height = 35;        // 胴体高さ (mm)
nui_body_width = 35;         // 胴体幅 (mm)
nui_body_depth = 25;         // 胴体厚み (mm)
nui_arm_length = 25;         // 腕長さ (mm)
nui_arm_dia = 12;            // 腕直径 (mm)
nui_leg_length = 25;         // 脚長さ (mm)
nui_leg_dia = 14;            // 脚直径 (mm)

// 内部マージン（布厚み + 綿の余裕）
internal_margin = 6;         // 片側マージン (mm)

// ============================================
// 内部利用可能空間（計算値）
// ============================================
internal_body_width = nui_body_width - internal_margin * 2;   // 23mm
internal_body_depth = nui_body_depth - internal_margin * 2;   // 13mm
internal_body_height = nui_body_height - internal_margin;     // 29mm
internal_arm_space = nui_arm_dia - internal_margin;           // 6mm
internal_leg_space = nui_leg_dia - internal_margin;           // 8mm

// ============================================
// 骨格寸法
// ============================================
bone_thickness = 1.5;        // 骨格基本厚み (mm)
bone_width = 2.0;            // 骨格基本幅 (mm)
spine_width = 3.0;           // 背骨幅 (mm)

// 胴体フレーム
body_height = internal_body_height - 4;  // 25mm
body_width = internal_body_width - 2;    // 21mm
body_depth = internal_body_depth - 2;    // 11mm

// 肩
shoulder_width = 5;          // 肩部品幅 (mm)
shoulder_offset = 7;         // 肩の高さ位置（胴体上端から）

// 腕
arm_length = 18;             // 腕の長さ (mm)
arm_width = 3;               // 腕の幅 (mm)
arm_thickness = 1.5;         // 腕の厚み (mm)

// 足
foot_width = 8;              // 足幅 (mm)
foot_length = 10;            // 足長さ (mm)
foot_height = 3;             // 足高さ (mm)
leg_length = 18;             // 脚の長さ (mm)

// ============================================
// 電子部品寸法（実測値）
// ============================================

// Seeed XIAO ESP32C3
xiao_width = 17.5;           // 幅 (mm)
xiao_height = 21.0;          // 高さ (mm)
xiao_depth = 4.0;            // 厚み (mm)

// LiPo電池 (100mAh 1S 3.7V)
lipo_width = 15;             // 幅 (mm)
lipo_height = 20;            // 高さ (mm)
lipo_depth = 4;              // 厚み (mm)

// 振動モーター（コイン型）
vib_motor_dia = 8;           // 直径 (mm)
vib_motor_height = 3;        // 高さ (mm)

// MAX98357A I2S DAC（超小型版）
dac_width = 14;              // 幅 (mm)
dac_height = 17;             // 高さ (mm)
dac_depth = 3;               // 厚み (mm)

// スピーカー（薄型）
speaker_dia = 15;            // 直径 (mm)
speaker_height = 4;          // 高さ (mm)

// ============================================
// 磁石・重り
// ============================================
magnet_dia = 3;              // ネオジム磁石直径 (mm)
magnet_height = 1.5;         // ネオジム磁石高さ (mm)
weight_hole_dia = 4;         // 重り穴直径 (mm)

// ============================================
// 印刷設定
// ============================================
wall_thick = 0.8;            // 壁厚み (mm)
tolerance = 0.25;            // 組み立て公差 (mm)
$fn = 32;                    // 円の分割数

// ============================================
// 色設定（プレビュー用）
// ============================================
color_bone = [0.95, 0.95, 0.9];
color_pcb = [0.1, 0.4, 0.1];
color_battery = [0.2, 0.2, 0.8];
color_motor = [0.6, 0.4, 0.2];
color_speaker = [0.2, 0.2, 0.2];
color_magnet = [0.7, 0.7, 0.75];
color_servo = [0.2, 0.2, 0.3];

// ============================================
// 10cm版の設計指針
// ============================================
//
// 【重要な制約】
// - SG90サーボ（12.2mm幅）は物理的に入らない
// - 単3電池（φ14.5 x 50mm）は入らない
// - 標準SDカードモジュール（24x32mm）は入らない
//
// 【推奨構成】
// - マイコン: Seeed XIAO ESP32C3 (21x17.5x4mm)
// - 電源: LiPo 1S 100-150mAh (20x15x4mm)
// - 動力: 振動モーター φ8x3mm × 3個
// - 音声: MAX98357A小型版 + φ15mmスピーカー
// - 音声データ: XIAOの内蔵フラッシュ (4MB)
//
// 【配置戦略】
// - XIAO: 背面上部（USB端子を下向き）
// - 電池: 背面中央（交換しやすい位置）
// - スピーカー: 胸部前面（音が前に出る）
// - DAC: 電池の横
// - 振動モーター: 肩関節部と胸部
//
// 【体積計算】
// - 内部空間: 23 x 13 x 29mm ≒ 8.7cm³
// - XIAO: 17.5 x 21 x 4mm ≒ 1.5cm³
// - 電池: 15 x 20 x 4mm ≒ 1.2cm³
// - モーター×3: ≒ 0.5cm³
// - DAC: ≒ 0.7cm³
// - スピーカー: ≒ 0.7cm³
// - 合計: 約4.6cm³ → 利用率約53%
// ============================================
