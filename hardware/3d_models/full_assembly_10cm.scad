// ============================================
// NuiBone - 10cm版 フルアセンブリ
// ============================================
// 10cmぬいぐるみ用骨格の完成形プレビュー
// ============================================

include <config_10cm.scad>

use <body_frame_10cm.scad>
use <arm_bone_10cm.scad>
use <foot_10cm.scad>

// --- フルアセンブリ（10cm版）---
module full_assembly_10cm() {
    // 胴体フレーム
    color(color_bone)
        body_frame_10cm();

    // 左腕
    color(color_bone)
        translate([-body_width/2 - 3, 0, body_height - shoulder_offset])
            rotate([0, -90, 0])
                arm_bone_10cm();

    // 右腕
    color(color_bone)
        translate([body_width/2 + 3, 0, body_height - shoulder_offset])
            rotate([0, 90, 0])
                arm_bone_10cm();

    // 左足
    color(color_bone)
        translate([-body_width/4, -body_depth/2, -4])
            foot_assembly_10cm();

    // 右足
    color(color_bone)
        translate([body_width/4, -body_depth/2, -4])
            foot_assembly_10cm();

    // サーボ（プレビュー用）
    preview_micro_servos();
}

// --- マイクロサーボプレビュー ---
module preview_micro_servos() {
    // 左肩サーボ
    color(color_servo, 0.5)
        translate([-body_width/2 - servo_width/2 - 1, 0, body_height - shoulder_offset])
            cube([servo_width, servo_depth, servo_height], center=true);

    // 右肩サーボ
    color(color_servo, 0.5)
        translate([body_width/2 + servo_width/2 + 1, 0, body_height - shoulder_offset])
            cube([servo_width, servo_depth, servo_height], center=true);
}

// --- 10cmぬいぐるみ外形参考 ---
module nui_outline_10cm() {
    color([1, 0.8, 0.8], 0.2) {
        // 頭
        translate([0, 0, body_height + 15])
            sphere(d=30);

        // 胴体
        translate([0, 0, body_height/2])
            scale([1, 0.6, 1])
                sphere(d=35);
    }
}

// --- 15cm版との比較 ---
module size_comparison() {
    // 10cm版
    full_assembly_10cm();

    // 15cm版（スケール参考）
    color([0.5, 0.5, 1], 0.3)
        translate([60, 0, 0])
            scale([1.5, 1.5, 1.5])
                full_assembly_10cm();

    // ラベル
    echo("Left: 10cm version, Right: 15cm version (scaled)");
}

// --- 寸法確認 ---
module dimension_check_10cm() {
    echo("=== NuiBone 10cm Dimensions ===");
    echo(str("Total height (approx): ", body_height + leg_length + foot_height, " mm"));
    echo(str("Body width: ", body_width, " mm"));
    echo(str("Body depth: ", body_depth, " mm"));
    echo(str("Arm span: ", body_width + arm_length * 2 + 6, " mm"));
    echo("=== Recommended Components ===");
    echo("Servo: SG51R (5g) or HK-5320 (3.7g)");
    echo("Battery: LiPo 1S 100-200mAh");
    echo("Controller: Seeed XIAO ESP32C3");
}

// --- メイン出力 ---
full_assembly_10cm();

// ぬいぐるみ外形（コメントアウトで表示）
// nui_outline_10cm();

// サイズ比較（コメントアウトで表示）
// size_comparison();

// 寸法確認
dimension_check_10cm();
