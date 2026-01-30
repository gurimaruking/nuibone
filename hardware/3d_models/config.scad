// ============================================
// NuiBone - 共通設定ファイル
// ============================================
// 15cmぬいぐるみ用ロボット骨格の寸法設定
// ============================================

// --- ぬいぐるみサイズ制約 ---
nui_height = 150;        // ぬいぐるみ全高 (mm)
nui_body_width = 40;     // 胴体最大幅 (mm)
nui_body_depth = 25;     // 胴体最大厚み (mm)

// --- 骨格寸法 ---
bone_thickness = 2.5;    // 骨格基本厚み (mm)
bone_width = 3;          // 骨格基本幅 (mm)

// 胴体フレーム
body_height = 45;        // 胴体高さ (mm)
body_width = 35;         // 胴体幅 (mm)
body_depth = 20;         // 胴体奥行き (mm)

// 肩
shoulder_width = 8;      // 肩部品幅 (mm)
shoulder_offset = 15;    // 肩の高さ位置（胴体上端から）

// 腕
arm_length = 35;         // 腕の長さ (mm)
arm_width = 4;           // 腕の幅 (mm)
arm_thickness = 2;       // 腕の厚み (mm)

// 足
foot_width = 12;         // 足幅 (mm)
foot_length = 15;        // 足長さ (mm)
foot_height = 5;         // 足高さ (mm)
leg_length = 30;         // 脚の長さ (mm)

// --- SG90サーボ寸法 ---
sg90_width = 12.2;       // サーボ幅 (mm)
sg90_height = 22.5;      // サーボ高さ (mm)
sg90_depth = 22.5;       // サーボ奥行き (mm)
sg90_shaft_height = 4;   // 出力軸高さ (mm)
sg90_shaft_dia = 4.8;    // 出力軸直径 (mm)
sg90_mount_hole = 2;     // 取付穴径 (mm)
sg90_mount_dist = 28;    // 取付穴間距離 (mm)
sg90_flange_width = 32.5; // フランジ幅 (mm)
sg90_flange_thick = 2.5; // フランジ厚み (mm)

// --- 磁石・重り ---
magnet_dia = 5;          // ネオジム磁石直径 (mm)
magnet_height = 2;       // ネオジム磁石高さ (mm)
weight_hole_dia = 6;     // 重り穴直径 (mm)

// --- 呼吸機構 ---
breath_stroke = 3;       // 呼吸ストローク (mm)
breath_plate_size = 15;  // 呼吸プレートサイズ (mm)

// --- 印刷設定 ---
wall_thick = 1.2;        // 壁厚み (mm)
tolerance = 0.3;         // 組み立て公差 (mm)
$fn = 32;                // 円の分割数

// --- 色設定（プレビュー用）---
color_bone = [0.9, 0.9, 0.85];
color_servo = [0.2, 0.2, 0.3];
color_magnet = [0.7, 0.7, 0.7];
